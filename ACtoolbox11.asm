#include "p18F4520.inc"
    CONFIG OSC = HS	; Oscillator Selecion bits (HS oscillator)
    CONFIG PWRT = OFF	; Power-up Timer Enable bit (PWRT disabled)
    CONFIG WDT = OFF	; Watchdog Timer Enable bit
    CONFIG PBADEN = OFF	; PORT A/D Enable bit
    CONFIG LVP = OFF	; Single-Supply ICSP Enable bit (disabled)

;*******************************************************************************
;*****************************KEY Tool Box *************************************
;*******************************************************************************
IKTEMP	equ	0x003
IKPREV	equ	0x004
IKTIME	equ	0x005
	
EKINIT	BSF	TRISB, RB0	    ; Configure kbd sense lines
	BSF	TRISB, RB2	    ; B = input
	BSF	TRISB, RB4
	BSF	TRISB, RB5
	SETF	IKPREV		    ; IKPREV=FF, no pressed key
	MOVLW	0x01		    ; Last key 'none'
	MOVWF	IKTIME		    ; No bounce
	RETURN

EKDOWNQ	CALL	EC8COLQ		    ; Every 8th time
	DECFSZ	WREG
	GOTO	LKDOWNQ
	DCFSNZ	IKTIME		    ; dec repeat counter
	INCF	IKTIME		    ; but only to one
LKDOWNQ	SETF	WREG		    ; Key pressed? (Assume not)
	BTFSS	PORTB, RB0
	CLRF	WREG
	BTFSS	PORTB, RB2
	MOVLW	0x01
	BTFSS	PORTB, RB4
	MOVLW	0x02
	BTFSS	PORTB, RB5
	MOVLW	0x03
	BTFSC	WREG, 7
	RETURN			    ; No? return to hell
	
	MOVWF	IKTEMP		    ; Yz which? Bestäm col
	CALL	EC8COLQ
	RLNCF	WREG
	RLNCF	WREG
	IORWF	IKTEMP		    ; add row
	MOVF	IKPREV, W
	XORWF	IKTEMP, W	    ; same???? kollar om den är 0 eller ej
	BNZ	LKNEW
	
	MOVF	IKPREV, W	    ; repeat?
	DECFSZ	IKTIME
LKSAME	SETF	WREG
	RETURN
	    
LKNEW	DECFSZ	IKTIME, W	    ; No! Monkey check	om man trycker ner på 2 olika rader
	GOTO	LKSAME		    ; Two plus keys - ignore
	MOVF	IKTEMP, W	    ; New key
	MOVWF	IKPREV		    ; remember it!
	CLRF	IKTIME		    ; reset repeat cnt
	RETURN
;******************END KEY TOOLBOX******************************************
