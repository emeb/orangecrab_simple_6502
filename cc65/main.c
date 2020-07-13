/*
 * main.c - top level 6502 C code for icestick_6502
 * 03-04-19 E. Brombaugh
 * based on example code from https://cc65.github.io/doc/customizing.html
 */
 
#include <stdio.h>
#include <string.h>
#include "fpga.h"
#include "acia.h"
#include "usb.h"

unsigned long cnt;
unsigned char x = 0, uc;
char txt_buf[32];
unsigned long i;

int main()
{
	// Send startup messages
	acia_tx_str("\n\n\rOrangeCrab 6502 cc65 serial test\n\n\r");
	
	// test some C stuff
	for(i=0;i<26;i++)
		txt_buf[i] = 'A'+i;
	txt_buf[i] = 0;
	acia_tx_str(txt_buf);
	acia_tx_str("\n\r");
	
	// wait for key on USB and send response
	acia_tx_str("Waiting for USB...\n\r");
	while(usb_rx_chr()!=' ');
	acia_tx_str("Connected\n\r");
	usb_tx_str("\n\n\rOrangeCrab 6502 cc65 usb test\n\n\r");
	
	// enable ACIA IRQ for serial echo in background
	ACIA_CTRL = 0x80;
	asm("CLI");
	
    // Run forever with GPIO blink
    while(1)
    {
		// delay
		cnt = 1024L;
		while(cnt--)
		{
			// echo USB
			if(USB_CTRL & 1)
			{
				// received a byte
				uc = USB_DATA;
				
				// wait for ready
				while((USB_CTRL & 2)==0);
				USB_DATA = uc;
				acia_tx_chr(uc);
			}
		}
		
        // write counter msbyte to GPIO
        GPIO_DATA = x;
        x++;
		//usb_tx_chr('.');
    }

    //  We should never get here!
    return (0);
}
