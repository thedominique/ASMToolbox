#include "p18F4520.inc"
    CONFIG OSC = HS	; Oscillator Selecion bits (HS oscillator)
    CONFIG PWRT = OFF	; Power-up Timer Enable bit (PWRT disabled)
    CONFIG WDT = OFF	; Watchdog Timer Enable bit
    CONFIG PBADEN = OFF	; PORT A/D Enable bit
    CONFIG LVP = OFF	; Single-Supply ICSP Enable bit (disabled)
    
	org	0x0000000
PORST   GOTO	MAIN
	org	0x0000020
	
;*******************************************************************************
;*****************************Col Tool Box *************************************
;*******************************************************************************
IC8COL	equ	0x000
	
EC8INIT	BCF	TRISA, RA1
	BCF	TRISA, RA2
	BCF	TRISA, RA3
	BCF	TRISA, RA5
	BCF	TRISE, RE0
	BCF	TRISE, RE1
	BCF	TRISE, RE2
	BCF	TRISC, RC0
	CLRF	IC8COL		; next col is col1
	CALL	EC8FREE		; Make sure colX are...
	RETURN

EC8COLQ	MOVF	IC8COL, W	; return current col
	RETURN
	
EC8NEXTQ    
	INCF	IC8COL,	W	; return next col
	BTFSC	WREG, 3		; wrap around
	CLRF	WREG
	RETURN
	
EC8FREE	BCF	PORTA, RA1
	BCF	PORTA, RA2
	BCF	PORTA, RA3
	BCF	PORTA, RA5
	BCF	PORTE, RE0
	BCF	PORTE, RE1
	BCF	PORTE, RE2
	BCF	PORTC, RC0
	RETURN

EC8NEXT	CALL	EC8NEXTQ
	MOVWF	IC8COL	
	RLNCF	WREG
	RLNCF	WREG
	ADDWF	PCL		; Unsafe calc, no PCH
	BSF	PORTA, RA1
	RETURN
	BSF	PORTA, RA2
	RETURN
	BSF	PORTA, RA3
	RETURN
	BSF	PORTA, RA5
	RETURN
	BSF	PORTE, RE0
	RETURN
	BSF	PORTE, RE1
	RETURN
	BSF	PORTE, RE2
	RETURN
	BSF	PORTC, RC0
	RETURN

;*****************************End Tool Box *************************************
;*******************************************************************************

MAIN	CALL	EC8INIT
	SETF	TRISB
	CLRF	TRISD

LOOP	CALL	EC8NEXT	
	
	MOVF	PORTB, W    
	NOP
	ANDLW	0x35
	MOVWF	PORTD
	
	CALL	ED500MS
CONT	CALL	EC8FREE
	GOTO	LOOP
	
	end
