// usb_serial.v - Wrapper for USB serial device
// 07-13-20 E. Brombaugh

`default_nettype none

module usb_serial(
	input clk,				// system clock
	input rst,				// system reset
	input cs,				// chip select
	input we,				// write enable
	input [2:0] addr,		// address bus
	input rx,				// serial receive
	input [7:0] din,		// data bus input
	output reg [7:0] dout,	// data bus output
	inout USB_DP,			// USB D+
	inout USB_DM,			// USB D-
	inout USB_PULLUP,		// USB Pullup
	output IRQ				// interrupt request
);
`ifdef LOOPBACK
	assign dout = 8'h00;
	
	// temporary tie the pipes together for loopback
	wire [7:0] uart_in_data;
	wire       uart_in_valid;
	wire      uart_in_ready;
	// uart pipeline out (into the device, out of the host)
	wire [7:0] uart_out_data;
	wire       uart_out_valid;
	wire        uart_out_ready;
	
	assign uart_in_data = uart_out_data;
	assign uart_in_valid = uart_out_valid;
	assign uart_out_ready = uart_in_ready;
`else
	// CPU interface to USB pipes	
	// uart pipeline in (out of the device, into the host)
	reg [7:0] uart_in_data;
	reg       uart_in_valid;
	wire      uart_in_ready;
	// uart pipeline out (into the device, out of the host)
	wire [7:0] uart_out_data;
	wire       uart_out_valid;
	reg        uart_out_ready;
	
	// receive from host
	reg [7:0] rx_data;
	always @(posedge clk)
	begin
		if(rst)
		begin
			rx_data <= 8'h00;
			uart_out_ready <= 1'b1;
		end
		else
		begin
			if(uart_out_ready)
			begin
				if(uart_out_valid)
				begin
					// grab data and stall pipe
					rx_data <= uart_out_data;
					uart_out_ready <= 1'b0;
				end
			end
			else
			begin
				if(cs & ~we & addr[0])
				begin
					// accept data and enable pipe
					uart_out_ready <= 1'b1;
				end
			end
		end
	end
		
	// transmit to host
	always @(posedge clk)
	begin
		if(rst)
		begin
			uart_in_data <= 8'h00;
			uart_in_valid <= 1'b0;
		end
		else
		begin
			if(cs & we & addr[0])
			begin
				// accept data and enable pipe
				uart_in_data <= din;
				uart_in_valid <= 1'b1;
			end
			
			// valid holds until ready
			if(uart_in_valid & uart_in_ready)
				uart_in_valid <= 1'b0;
		end
	end
	
	// CPU READ
	always @(posedge clk)
	begin
		if(rst)
		begin
			dout <= 8'h00;
		end
		else
		begin
			// load dout with either status or receive pipe
			if(cs & ~we)
			begin
				if(addr[0])
					dout <= rx_data;
				else
					dout <= {6'd0,~uart_in_valid,~uart_out_ready};
			end
		end
	end
`endif
	
	// the USB UART device
    wire usb_p_tx;
    wire usb_n_tx;
    wire usb_p_rx;
    wire usb_n_rx;
    wire usb_tx_en;
    wire [11:0] debug;
	usb_uart_core uart (
		.clk_48mhz  (clk),
		.reset      (rst),

		// pins - these must be connected properly to the outside world.  See below.
		.usb_p_tx(usb_p_tx),
		.usb_n_tx(usb_n_tx),
		.usb_p_rx(usb_p_rx),
		.usb_n_rx(usb_n_rx),
		.usb_tx_en(usb_tx_en),

		// uart pipeline in
		.uart_in_data( uart_in_data ),
		.uart_in_valid( uart_in_valid ),
		.uart_in_ready( uart_in_ready ),

		// uart pipeline out
		.uart_out_data( uart_out_data ),
		.uart_out_valid( uart_out_valid ),
		.uart_out_ready( uart_out_ready ),

		.debug( debug )
	);
	
	// I/O Pin drivers
    wire usb_p_in;
    wire usb_n_in;

    assign usb_p_rx = usb_tx_en ? 1'b1 : usb_p_in;
    assign usb_n_rx = usb_tx_en ? 1'b0 : usb_n_in;

	// T = TRISTATE (not transmit)
	BB io_p( .I( usb_p_tx ), .T( !usb_tx_en ), .O( usb_p_in ), .B( USB_DP ) );
	BB io_n( .I( usb_n_tx ), .T( !usb_tx_en ), .O( usb_n_in ), .B( USB_DM ) );

	// Assert the pullup
	assign USB_PULLUP = 1'b1;
	
	// no interrupt for now
	assign IRQ = 1'b0;
endmodule
