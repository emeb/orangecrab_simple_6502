; ---------------------------------------------------------------------------
; usb.s
; orangecrab_simple_6502 USB interface routines
; 07-13-20 E. Brombaugh
; ---------------------------------------------------------------------------
;
; Write a string to the USB TX

.export         _usb_tx_str
.export         _usb_tx_chr
.export         _usb_rx_chr
.exportzp       _usb_data: near

.include  "fpga.inc"

.zeropage

_usb_data:     .res 2, $00        ;  Reserve a local zero page pointer

.segment  "CODE"

; ---------------------------------------------------------------------------
; send a string to the USB

.proc _usb_tx_str: near

; ---------------------------------------------------------------------------
; Store pointer to zero page memory and load first character

        sta     _usb_data        ;  Set zero page pointer to string address
        stx     _usb_data+1      ;    (pointer passed in via the A/X registers)
        ldy     #00              ;  Initialize Y to 0
        lda     (_usb_data),y    ;  Load first character

; ---------------------------------------------------------------------------
; Main loop:  read data and store to USB tx pipe until \0 is encountered

loop:   jsr     _usb_tx_chr      ;  Loop:  send char to USB
        iny                      ;         Increment Y index
        lda     (_usb_data),y    ;         Get next character
        bne     loop             ;         If character == 0, exit loop
        rts                      ;  Return
.endproc
        
; ---------------------------------------------------------------------------
; wait for TX empty and send single character to USB

.proc _usb_tx_chr: near

        pha                      ; temp save char to send
txw:    lda      USB_CTRL        ; wait for TX empty
        and      #$02
        beq      txw
        pla                      ; restore char
        sta      USB_DATA        ; send
        rts

.endproc

; ---------------------------------------------------------------------------
; wait for RX full and get single character from USB

.proc _usb_rx_chr: near

rxw:    lda      USB_CTRL        ; wait for RX full
        and      #$01
        beq      rxw
        lda      USB_DATA        ; receive
        rts

.endproc
