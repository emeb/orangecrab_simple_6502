/*
 * usb.h - C interface to the usb assembly routines
 * 07-13-20 E. Brombaugh
 */

#ifndef __USB__
#define __USB__

extern void __fastcall__ usb_tx_str (char *str);
extern void __fastcall__ usb_tx_chr (char c);
extern char __fastcall__ usb_rx_chr (void);

#endif
