processor 16F73
include <p16f73.inc>
__config _WDT_OFF & _PWRTE_ON & _HS_OSC 


org 0x0000
Dado		EQU 0x20
DSP1		EQU 0x21
DSP2		EQU 0x22
DSP3		EQU 0x23
Resultado	EQU 0x24
Cont1		EQU 0x25
Cont2		EQU 0x26
Cont3		EQU 0x27





org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm



Main


	movlw	b'10000101'
	movwf	ADCON0

	BANK1
	clrf	ADCON1
	bcf		TRISC , 4

	movlw	B'00100100'
	movwf	TXSTA			; CONFIGURA USART
							; HABILITA TX
							; MODO ASSINCRONO
							; TRANSMISSÃO DE 8 BITS
							; LOW SPEED BAUD RATE
	movlw	.128
	movwf	SPBRG			; ACERTA BAUD RATE -> 9600bps
	
	BANK0					; SELECIONA BANCO 0 DA RAM

	movlw	B'10010000'
	movwf	RCSTA			; CONFIGURA USART
							; HABILITA RX
							; RECEPÇÃO DE 8 BITS
							; RECEPÇÃO CONTÍNUA
							; DESABILITA ADDRESS DETECT


	

	movlw	'T'
	call	enviar_byte_rs232


	movlw	'e'
	call	enviar_byte_rs232

	movlw	's'
	call	enviar_byte_rs232

	movlw	't'
	call	enviar_byte_rs232

	movlw	'e'
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232

	movlw	'R'
	call	enviar_byte_rs232

	movlw	'S'
	call	enviar_byte_rs232


	movlw	'2'
	call	enviar_byte_rs232


	movlw	'3'
	call	enviar_byte_rs232

	movlw	'2'
	call	enviar_byte_rs232


	movlw	' '
	call	enviar_byte_rs232

	movlw	0x0D
	call	enviar_byte_rs232


	Inicio1
	bsf		PORTC , 4
	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$-5


	
	bcf		PORTC , 4
	Inicio_AD

	movlw	0xA0
	movwf	Cont1
	movlw	0x25
	movwf	Cont2
	movlw	0x23
	movwf	Cont3

	decfsz	Cont1 , 1
	goto	$-1
	decfsz	Cont2 , 1
	goto	$-3
	decfsz	Cont3 , 1
	goto	$-5
	

	btfss	PIR1 , RCIF
	goto	$+6
	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$+2
	goto	Inicio1

	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$+2
	goto	Inicio_AD2

	movf	ADRES , 0
	movwf	Dado
	call	Converter
	
	movlw	0x30
	addwf	DSP1 , 0	
	call	enviar_byte_rs232

	movlw	0x30
	addwf	DSP2 , 0	
	call	enviar_byte_rs232

	movlw	0x30
	addwf	DSP3 , 0	
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232

	movlw	0x0D
	call	enviar_byte_rs232

	btfss	PIR1 , RCIF
	goto	Inicio_AD
	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$+2
	goto	Inicio1
	goto	Inicio_AD


	Inicio_AD2
	

	movlw	b'10000101'
	movwf	ADCON0

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$+2
	goto	$+6
	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$+2
	goto	Inicio1


	movf	ADRES , 0
	movwf	Dado
	call	Converter
;	btfss	PIR1 , RCIF
;	goto	$+6
;	movlw	'P'
;	subwf	RCREG , 0
;	btfss	STATUS , 2
;	goto	$+2
;	goto	Inicio1

	movlw	0x30
	addwf	DSP1 , 0	
	call	enviar_byte_rs232

	movlw	0x30
	addwf	DSP2 , 0	
	call	enviar_byte_rs232

	movlw	0x30
	addwf	DSP3 , 0	
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232

	movlw	0x0D
	call	enviar_byte_rs232
	goto	Inicio_AD2
	sleep

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return



	Converter
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP1 , 1
	goto	$-4
	movlw	.100
	addwf	Dado , 1
	movlw	.10
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	Dado , 0
	movwf	DSP3
	return

END