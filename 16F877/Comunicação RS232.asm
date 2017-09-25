processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


dado EQU 0x20




org 0x0000
BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
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
	movlw	.12
	movwf	SPBRG			; ACERTA BAUD RATE -> 19200bps

	BANK0					; SELECIONA BANCO 0 DA RAM

	movlw	B'10010000'
	movwf	RCSTA			; CONFIGURA USART
							; HABILITA RX
							; RECEPÇÃO DE 8 BITS
							; RECEPÇÃO CONTÍNUA
							; DESABILITA ADDRESS DETECT
movlw	'A'
call	enviar_byte_rs232
movlw	'B'
call	enviar_byte_rs232
movlw	'C'
call	enviar_byte_rs232

Init_1
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG , 0
call	enviar_byte_rs232
goto	Init_1


sleep

enviar_byte_rs232
BANK1						; ALTERA P/ BANCO 1 DA RAM
btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
goto	$-1					; NÃO - AGUARDA ESVAZIAR
BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
return



END