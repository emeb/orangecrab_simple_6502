// orangecrab_6502.v - top level for tst_6502 on an orangecrab
// 07-12-20 E. Brombaugh

`default_nettype none

module orangecrab_6502(
	input  CLK,
	input  RX,
	output TX,
	output LED1,
	output LED2,
	output LED3
);
	// reset generator waits > 10us
	reg [7:0] reset_cnt;
	reg reset;
	initial
        reset_cnt <= 6'h00;
    
	always @(posedge CLK)
	begin
		if(reset_cnt != 6'hff)
        begin
            reset_cnt <= reset_cnt + 6'h01;
            reset <= 1'b1;
        end
        else
            reset <= 1'b0;
	end
    
	// test unit
	wire [7:0] gpio_o, gpio_i;
	assign gpio_i = 8'h00;
	tst_6502 uut(
		.clk(CLK),
		.reset(reset),
		
		.gpio_o(gpio_o),
		.gpio_i(gpio_i),
		
		.RX(RX),
		.TX(TX)
	);
    
	// drive LEDs from GPIO
	assign {LED1,LED2,LED3} = gpio_o[5:3];
endmodule
