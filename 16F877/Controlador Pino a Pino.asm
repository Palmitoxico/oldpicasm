;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Controlador Pino a Pino                      ;;
;;                                                              ;;
;;Interface: RS232                                              ;;
;;Baud rate: 19200 bps                                          ;;
;;                                                              ;;
;;Comandos:                                                     ;;
;;         TA [Byte] Escreve no registrador TRISA               ;;
;;         TB [Byte] Escreve no registrador TRISB               ;;
;;         TC [Byte] Escreve no registrador TRISC               ;;
;;         TD [Byte] Escreve no registrador TRISD               ;;
;;         TE [Byte] Escreve no registrador TRISE               ;;
;;                                                              ;;
;;         WPA [Byte] Escreve no registrador PORTA              ;;
;;         WPB [Byte] Escreve no registrador PORTB              ;;
;;         WPC [Byte] Escreve no registrador PORTC              ;;
;;         WPD [Byte] Escreve no registrador PORTD              ;;
;;         WPE [Byte] Escreve no registrador PORTE              ;;
;;                                                              ;;
;;         RPA [Byte] Le o registrador PORTA                    ;;
;;         RPB [Byte] Le o registrador PORTB                    ;;
;;         RPC [Byte] Le o registrador PORTC                    ;;
;;         RPD [Byte] Le o registrador PORTD                    ;;
;;         RPE [Byte] Le o registrador PORTE                    ;;
;;                                                              ;;
;;                                                              ;;
;;                                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF

#Define Data_pin PORTA,0
#Define Clock_pin PORTA,1

org 0x0000
Dado		EQU 0x20
Valor_p		EQU 0x21
W2			EQU 0x22
Teste		EQU 0x23
DSP1		EQU 0x24
DSP2		EQU 0x25
DSP3		EQU 0x26
Resultado	EQU 0x27
Cont1		EQU 0x28
Cont2		EQU 0x29
Cont3		EQU 0x2A
RX_Byte		EQU 0x2B
TRISD2		EQU 0x20





org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm



Main

	clrf	PORTA
	clrf	PORTB
	clrf	PORTC
	clrf	PORTD
	clrf	PORTE


	BANK1
	movlw	0x06			;Configura a porta a para  digital 

	movwf	ADCON1  	 	  

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
							; RECEP€ŽO DE 8 BITS
							; RECEP€ŽO CONT‹NUA
							; DESABILITA ADDRESS DETECT


	Inicio1
	btfss	PIR1 , RCIF
	goto	$-1

	btfss	PIR1 , RCIF
	goto	$-1


	movlw	'W'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_RP

	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_RP

	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'A'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WPA
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTA
	goto	Inicio1
	Fim_WPA

	movlw	'B'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WPB
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTB
	goto	Inicio1
	Fim_WPB

	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WPC
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG,0
	movwf	PORTC
	goto	Inicio1
	Fim_WPC

	movlw	'D'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WPD
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTD
	goto	Inicio1
	Fim_WPD

	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Inicio1
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTE
	goto	Inicio1
	Fim_RP



	movlw	'R'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WP

	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_WP

	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'A'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PA
	movf	PORTA,0
	call	enviar_byte_rs232
	goto	Inicio1
	Fim_PA

	movlw	'B'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PB
	movf	PORTB,0
	call	enviar_byte_rs232
	goto	Inicio1
	Fim_PB

	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PC
	movf	PORTC,0
	call	enviar_byte_rs232
	goto	Inicio1
	Fim_PC

	movlw	'D'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PD
	movf	PORTD,0
	call	enviar_byte_rs232
	goto	Inicio1
	Fim_PD

	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Inicio1
	movf	PORTE,0
	call	enviar_byte_rs232
	goto	Inicio1
	Fim_WP

	movlw	'T'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_T

	btfss	PIR1 , RCIF
	goto	$-1


	movlw	'A'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_TA
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	BANK1
	movwf	TRISA
	BANK0
	goto	Inicio1
	Fim_TA

	movlw	'B'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_TB
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	BANK1
	movwf	TRISB
	BANK0
	goto	Inicio1
	Fim_TB

	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_TC
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG,0
	iorlw	b'11000000'
	BANK1
	movwf	TRISC
	BANK0
	goto	Inicio1
	Fim_TC

	movlw	'D'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_TD
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	BANK1
	movwf	TRISD
	BANK0
	goto	Inicio1
	Fim_TD

	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Inicio1
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	BANK1
	movwf	TRISE
	BANK0
	goto	Inicio1
	Fim_T



	goto	Inicio1

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return






END