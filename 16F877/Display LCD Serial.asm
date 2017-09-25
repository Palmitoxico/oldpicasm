processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF


cblock 0x20
byte
Nibble
VAR_BIT
delay1
delay2
delay3
Chr_count
endc

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
								;
BANK0 macro						;
bcf		STATUS,RP0 			    ;Muda para o banco 0
bcf		STATUS,RP1				;
Endm							;
								;
BANK1 macro						;
bsf		STATUS,RP0  			;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK2 macro						;
bcf		STATUS,RP0  			;Muda para o banco 2
bsf		STATUS,RP1				;
Endm							;
								;
BANK3 macro						;
bsf		STATUS,RP0  			;Muda para o banco 3
bsf		STATUS,RP1				;
Endm							;
								;
E_1 macro						;Coloca o pino enable em 1
bsf		PORTE,2					;
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
bcf		PORTE,2					;
Endm							;
								;
RS_1 macro						;Coloca o pino RS em 1
bsf		PORTE,0					;
Endm							;
								;
RS_0 macro						;Coloca o pino RS em 0
bcf		PORTE,0					;
Endm							;
								;
RW_1 macro						;Coloca o pino RW em 1
bsf		PORTE,1					;
Endm							;
								;
RW_0 macro						;Coloca o pino RW em 0
bcf		PORTE,1					;
Endm							;
								;
RB7_E macro						;Configura como entrada o pino RB7
BANK1							;
bsf		TRISB, 7				;
BANK0							;
Endm							;
								;
RB7_S macro						;Configura como saida o pino RB7
BANK1							;
bcf		TRISB, 7				;
BANK0							;
Endm							;
								;
ORG  0X0000						;

Main

	clrf	PORTB				;Limpa a porta B
	clrf	PORTE				;Limpa a porta E
	clrf	Chr_count


	BANK1						;Seleciona o banco 1 da RAM
	clrf	TRISB				;Define a porta B como saida
	clrf	TRISE				;Defina a porta E como saida
	movlw	B'00100100'
	movwf	TXSTA			; CONFIGURA USART
							; HABILITA TX
							; MODO ASSINCRONO
							; TRANSMISSÃO DE 8 BITS
							; LOW SPEED BAUD RATE
	movlw	.12
	movwf	SPBRG			; ACERTA BAUD RATE -> 19200bps

	BANK0						;Seleciona o banco 0 da RAM

	movlw	B'10010000'
	movwf	RCSTA			; CONFIGURA USART


	call	Delay_200ms
	call	Init_LCD

Loop:
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG, W
	call	enviar_byte_rs232
	movf	RCREG, F
	btfss	STATUS, Z
	goto	$+4
	call	Limpar_LCD
	clrf	Chr_count
	goto	Loop

	movf	Chr_count, W
	sublw	.16
	btfss	STATUS,Z
	goto	End_ajuste
	movlw	0x40
	movwf	Chr_count
	call	Endereco_LCD
End_ajuste:

	movf	RCREG, W
	sublw	0x08
	btfss	STATUS,Z
	goto	Fim_backsapce

	movf	Chr_count, F
	btfsc	STATUS, Z
	goto	Loop

	movf	Chr_count, W
	sublw	0x40
	btfss	STATUS, Z
	goto	$+3
	movlw	.16
	movwf	Chr_count

	decf	Chr_count, F
	movf	Chr_count, W
	call	Endereco_LCD
	movlw	' '
	call	Enviar_char_lcd
	movf	Chr_count, W
	call	Endereco_LCD
	goto	Loop

Fim_backsapce:

	incf	Chr_count
	movf	Chr_count, W
	sublw	0x51
	btfss	STATUS,Z
	goto	$+3
	decf	Chr_count
	goto	Loop

	movf	RCREG, W
	call	Enviar_char_lcd
	goto	Loop

sleep
									;Termina a rotina principal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;Começo das sub-rotinas

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return


	Init_LCD
	BANK1
	clrf	TRISB
	BANK0
	clrf	PORTB
	bsf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x02
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x28
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	0x0c
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	b'00000001'
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	0x06
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	return

	Enviar_byte_lcd				;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	swapf	byte, W
	call	Enviar_nibble_lcd
	movf	byte, W
	call	Enviar_nibble_lcd

	return						;Retorna da sub-rotina

	Enviar_nibble_lcd
	movwf	Nibble
	movlw	b'00001111'
	andwf	PORTB
	andwf	Nibble
	swapf	Nibble, W
	iorwf	PORTB
	bcf		LCD_E				;Coloca o pino enable em 0
	nop
	nop
	bsf		LCD_E				;Volta o pino enable em 1	
	return

	Enviar_char_lcd				;Sub-rotina para enviar um caracter para o display lcd
	bsf		LCD_RS
	call	Enviar_byte_lcd
	bcf		LCD_RS
	call	Delay_5mS			;
	return						;Retorna da sub-rotina
								;
								;
	Endereco_LCD
	iorlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return

	Linha_1_LCD
	movlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return	

	Linha_2_LCD
	movlw	b'11000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return

	Limpar_LCD					;
	movlw	b'00000001'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_5mS			;	
	return



Delay_40uS
	call	Delay_5mS
			;34 cycles
	movlw	0x0B
	movwf	delay1
Delay_40uS_0
	decfsz	delay1, f
	goto	Delay_40uS_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


Delay_5mS
			;4993 cycles
	movlw	0xE6
	movwf	delay1
	movlw	0x04
	movwf	delay2
Delay_5ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_5ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return



Delay_200ms
			;199993 cycles
	movlw	0x3E
	movwf	delay1
	movlw	0x9D
	movwf	delay2
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_200ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return
									;Fim do programa
END