processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF
 


org 0x0000
Dado		EQU 0x20
Letra		EQU 0x21
Cont1		EQU 0x22
Cont2		EQU 0x23
Cont3		EQU 0x24





org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm



Main



	BANK1


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


	


	Inicio1
	movlw	0x40
	movwf	Letra
	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	$-5


	movlw	0xFF
	movwf	Cont2
	movlw	0xFF
	movwf	Cont3

	decfsz	Cont2 , 1
	goto	$-1
	decfsz	Cont3 , 1
	goto	$-3

	Inicio_T
	

	incf	Letra,1
	
	movf	Letra,0	
	call	enviar_byte_rs232

	movlw	'Z'
	subwf	Letra , 0
	btfss	STATUS , Z
	goto	Inicio_T
	goto	Inicio1



	sleep

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return



END