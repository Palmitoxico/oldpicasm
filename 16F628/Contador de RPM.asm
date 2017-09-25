processor 16F628
include <p16f628.inc>
__config _WDT_OFF & _PWRTE_ON







org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm

Cont1 		EQU 0x20
Cont2 		EQU 0x21
byte  		EQU 0x22
Letra 		EQU 0x23
Dado		EQU 0x24
DSP1		EQU 0x25
DSP2		EQU 0x26
DSP3		EQU 0x27






E_1 macro
bsf  PORTB , 0
Endm

E_0 macro
bcf  PORTB , 0
Endm

RS_1 macro
bsf  PORTB , 1
Endm

RS_0 macro
bcf  PORTB , 1
Endm

RW_1 macro
bsf  PORTB , 2
Endm

RW_0 macro
bcf  PORTB , 2
Endm

BF_E macro
BANK1
movlw 0xF0
movwf TRISB
BANK0
Endm

BF_S macro
BANK1
clrf  TRISB
BANK0
Endm




Main

	BANK1  	 	  		       
	clrf	TRISB			   
	BANK0					   
	clrf	PORTB
	movlw	0x31
	movwf	DSP1

	movlw	0x32
	movwf	DSP2

	movlw	0x33
	movwf	DSP3

	inicio
	movlw	0x20
	call	enviar_nibble
	call	ler_BF
	movlw	0x28
	call	enviar_byte_lcd
	call	ler_BF	
	movlw	0x0C
	call	enviar_byte_lcd
	call	ler_BF
	RS_1

	movf	DSP1
	call	enviar_nibble
	call	ler_BF

	movf	DSP2
	call	enviar_nibble
	call	ler_BF

	movf	DSP3
	call	enviar_nibble
	call	ler_BF

	movf	DSP1
	call	enviar_nibble
	call	ler_BF

	movf	DSP2
	call	enviar_nibble
	call	ler_BF

	movf	DSP3
	call	enviar_nibble
	call	ler_BF

	call	limpar_nibble
	RS_0
	sleep
	goto    inicio			   ;Loop infinito

	Converter
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	Dado , F
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP1 , F
	goto	$-4
	movlw	.100
	addwf	Dado , F
	movlw	.10
	subwf	Dado , F
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	Dado , 0
	movwf	DSP3
	return

	limpar_nibble
	movlw  0x07
	andwf  PORTB , 1	
	return

	enviar_nibble
	movwf  byte
	E_1
	call   limpar_nibble
	btfsc  byte , 4
	bsf	   PORTB , 4
	btfsc  byte , 5
	bsf	   PORTB , 5
	btfsc  byte , 6
	bsf	   PORTB , 6
	btfsc  byte , 7
	bsf	   PORTB , 7
	movlw  0xFF	
	call   delay_us
	E_0
	movlw  0xFF	
	call   delay_us
	E_1
	return
	
	enviar_byte_lcd
	movwf  byte
	E_1
	call   limpar_nibble
	btfsc  byte , 4
	bsf	   PORTB , 4
	btfsc  byte , 5
	bsf	   PORTB , 5
	btfsc  byte , 6
	bsf	   PORTB , 6
	btfsc  byte , 7
	bsf	   PORTB , 7
	E_0
	movlw  0xFF
	call   delay_us
	E_1
	call   limpar_nibble
	btfsc  byte , 0
	bsf	   PORTB , 4
	btfsc  byte , 1
	bsf	   PORTB , 5
	btfsc  byte , 2
	bsf	   PORTB , 6
	btfsc  byte , 3
	bsf	   PORTB , 7
	movlw  0xFF
	call   delay_us
	E_0
	movlw  0xFF
	call   delay_us
	E_1
	return
	
	ler_BF
	movlw  0xFF
	call   delay_us
	;BF_E
	;RW_1
	;cond1
	;btfsc  PORTD , 4
	;goto   cond1
	;RW_0
	;BF_S
	return
	
	delay_us
	movwf  Cont1
	goto   delay_2
	delay_1
	nop
	nop
	nop
	delay_2
	nop
	decfsz Cont1 , 1
	goto   delay_1
	return


END