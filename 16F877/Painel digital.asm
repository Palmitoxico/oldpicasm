;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Painel automotivo digital            			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;                                              ;;
;;Versão: 1.02                                  ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;Data de inínico: 7/10/2010					;;
;;Data de término:                              ;;
;;PIC 16F877A                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _XT_OSC

									;Define as constantes de endereço 
cblock	0x20
byte
Nibble
Letra
DSP1
DSP2
DSP3
DSP4
DSP5
DSP6
delay1
delay2	
delay3	
p_lcd
Endereco_RTC
Valor
Segundos
Minutos
Horas
Select_U
Dado
Temp1
Temp2
Temp3
endc

DESATIVAR_INT macro
bcf		INTCON,GIE
Endm

ATIVAR_INT macro
bsf		INTCON,GIE
Endm

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3


#Define Endereco_RTC_escrita b'10100000'
#Define Endereco_RTC_leitura b'10100001'

#Define Endereco_Segundos_RTC		0x02
#Define Endereco_Minutos_RTC		0x03
#Define Endereco_Horas_RTC			0x04

#Define	Para_cima		PORTD,0
#Define	Para_baixo		PORTD,1
#Define	Esquerda		PORTD,2
#Define	Direita			PORTD,3
#Define	Enter			PORTD,4


org 0x0000
								;Definição de macro-comandos
BANK1 macro						;
bsf    STATUS,RP0 			    ;Muda para o banco 1
Endm							;
								;
BANK0 macro						;
bcf   STATUS,RP0  			    ;Volta ao banco 0
Endm							;
								;

Ativar_cursor	macro
movlw	b'00001111'
call	Enviar_byte_lcd
endm

Desativar_cursor	macro
movlw	b'00001100'
call	Enviar_byte_lcd
endm


Main
movlw	b'00101000'
movwf	SSPCON
clrf	PORTB				;Limpa a porta B	
clrf	PORTE				;Limpa a porta E

BANK1						;Vai para o banco 1 da memória
clrf	TRISB				;Toda a porta B como saída
clrf	TRISE				;Toda a porta E como saída
bcf		SSPSTAT,CKE
movlw	0x02
movwf	SSPADD
BANK0
bcf		SSPSTAT,2
call	Delay_200ms

call	Init_LCD

movlw	'E'
call	Enviar_char_lcd
movlw	'r'
call	Enviar_char_lcd
movlw	'r'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
movlw	' '
call	Enviar_char_lcd
movlw	'R'
call	Enviar_char_lcd
movlw	'T'
call	Enviar_char_lcd
movlw	'C'
call	Enviar_char_lcd

movlw	Endereco_Horas_RTC
movwf	Endereco_RTC
call	Ler_RTC
movwf	Horas

call	Limpar_LCD

movf	Horas,W
sublw	0x19
btfsc	STATUS,C
goto	Fim_19
movlw	'B'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
movlw	'a'
call	Enviar_char_lcd
movlw	' '
call	Enviar_char_lcd
movlw	'n'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
movlw	'i'
call	Enviar_char_lcd
movlw	't'
call	Enviar_char_lcd
movlw	'e'
call	Enviar_char_lcd
movlw	'!'
call	Enviar_char_lcd
goto	Fim_mensagem
Fim_19

movf	Horas,W
sublw	0x12
btfsc	STATUS,C
goto	Fim_12
movlw	'B'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
movlw	'a'
call	Enviar_char_lcd
movlw	' '
call	Enviar_char_lcd
movlw	't'
call	Enviar_char_lcd
movlw	'a'
call	Enviar_char_lcd
movlw	'r'
call	Enviar_char_lcd
movlw	'd'
call	Enviar_char_lcd
movlw	'e'
call	Enviar_char_lcd
movlw	'!'
call	Enviar_char_lcd
goto	Fim_mensagem
Fim_12


movlw	'B'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
movlw	'm'
call	Enviar_char_lcd
movlw	' '
call	Enviar_char_lcd
movlw	'd'
call	Enviar_char_lcd
movlw	'i'
call	Enviar_char_lcd
movlw	'a'
call	Enviar_char_lcd
movlw	'!'
call	Enviar_char_lcd

Fim_mensagem
call	Delay_2S
call	Limpar_LCD

;	movlw	0x04
;	movwf	Endereco
;	movlw	0x08
;	call	Gravar_RTC
Init

	movlw	Endereco_Minutos_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	movwf	Minutos

	movlw	Endereco_Horas_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	movwf	Horas

	clrw
	call	Endereco_LCD

	movf	Horas,0
	call	Converter_BCD_CHAR
	movlw	':'
	call	Enviar_char_lcd
	movf	Minutos,0
	call	Converter_BCD_CHAR

	btfsc	Direita
	goto	Init

	movlw	Endereco_Segundos_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	movwf	Segundos

	movlw	Endereco_Minutos_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	movwf	Minutos

	movlw	Endereco_Horas_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	movwf	Horas

	clrw
	call	Endereco_LCD
	movlw	'A'
	call	Enviar_char_lcd
	movlw	'j'
	call	Enviar_char_lcd
	movlw	'u'
	call	Enviar_char_lcd
	movlw	's'
	call	Enviar_char_lcd
	movlw	't'
	call	Enviar_char_lcd
	movlw	'a'
	call	Enviar_char_lcd
	movlw	'r'
	call	Enviar_char_lcd
	movlw	':'
	call	Enviar_char_lcd

	movlw	.8
	call	Endereco_LCD

	movf	Horas,0
	call	Converter_BCD_CHAR
	movlw	':'
	call	Enviar_char_lcd
	movf	Minutos,0
	call	Converter_BCD_CHAR
	movlw	':'
	call	Enviar_char_lcd
	movf	Segundos,0
	call	Converter_BCD_CHAR
	clrf	Select_U

	movlw	.15
	call	Endereco_LCD

	Init_Ajustar


	btfss	Direita
	goto	$-1

	Ativar_cursor



	btfsc	Para_baixo
	goto	Fim_Para_baixo

	movf	Select_U,1
	btfss	STATUS,Z
	goto	Fim_dec_segundos
	movf	Segundos,0
	call	Decrementar_BCD
	movwf	Segundos
	sublw	0x99
	btfss	STATUS,Z
	goto	$+3
	movlw	0x59
	movwf	Segundos
	movlw	.14
	call	Endereco_LCD
	movf	Segundos,W
	call	Converter_BCD_CHAR
	movlw	.15
	call	Endereco_LCD
	Fim_dec_segundos
	
	movlw	0x01
	subwf	Select_U,0
	btfss	STATUS,Z
	goto	Fim_dec_minutos
	movf	Minutos,0
	call	Decrementar_BCD
	movwf	Minutos
	sublw	0x99
	btfss	STATUS,Z
	goto	$+3
	movlw	0x59
	movwf	Minutos
	movlw	.11
	call	Endereco_LCD
	movf	Minutos,W
	call	Converter_BCD_CHAR
	movlw	.12
	call	Endereco_LCD
	Fim_dec_minutos

	movlw	0x02
	subwf	Select_U,0
	btfss	STATUS,Z
	goto	Fim_dec_horas
	movf	Horas,0
	call	Decrementar_BCD
	movwf	Horas
	sublw	0x99
	btfss	STATUS,Z
	goto	$+3
	movlw	0x23
	movwf	Horas
	movlw	.8
	call	Endereco_LCD
	movf	Horas,W
	call	Converter_BCD_CHAR
	movlw	.9
	call	Endereco_LCD
	Fim_dec_horas
	call	Delay_300ms

	Fim_Para_baixo

	btfsc	Para_cima
	goto	Fim_Para_cima

	movf	Select_U,1
	btfss	STATUS,Z
	goto	Fim_inc_segundos
	movf	Segundos,0
	call	Incrementar_BCD
	movwf	Segundos
	sublw	0x60
	btfss	STATUS,Z
	goto	$+2
	clrf	Segundos
	movlw	.14
	call	Endereco_LCD
	movf	Segundos,W
	call	Converter_BCD_CHAR
	movlw	.15
	call	Endereco_LCD
	Fim_inc_segundos

	movlw	0x01
	subwf	Select_U,0
	btfss	STATUS,Z
	goto	Fim_inc_minutos
	movf	Minutos,0
	call	Incrementar_BCD
	movwf	Minutos
	sublw	0x60
	btfss	STATUS,Z
	goto	$+2
	clrf	Minutos
	movlw	.11
	call	Endereco_LCD
	movf	Minutos,W
	call	Converter_BCD_CHAR
	movlw	.12
	call	Endereco_LCD
	Fim_inc_minutos

	movlw	0x02
	subwf	Select_U,0
	btfss	STATUS,Z
	goto	Fim_inc_horas
	movf	Horas,0
	call	Incrementar_BCD
	movwf	Horas
	sublw	0x24
	btfss	STATUS,Z
	goto	$+2
	clrf	Horas
	movlw	.8
	call	Endereco_LCD
	movf	Horas,W
	call	Converter_BCD_CHAR
	movlw	.9
	call	Endereco_LCD
	Fim_inc_horas

	call	Delay_300ms

	Fim_Para_cima

	btfsc	Esquerda
	goto	Fim_esquera
	btfss	Esquerda
	goto	$-1
	btfss	Select_U,1
	goto	$+3
	clrf	Select_U
	goto	Fim_esquera
	incf	Select_U,1
	Fim_esquera

	btfsc	Direita
	goto	Fim_direita
	btfss	Direita
	goto	$-1
	movf	Select_U,1
	btfss	STATUS,Z
	goto	$+3
	bsf		Select_U,1
	goto	Fim_direita
	decf	Select_U,1
	Fim_direita

	movf	Select_U, F
	btfss	STATUS, Z
	goto	$+3
	movlw	.15
	call	Endereco_LCD

	movf	Select_U, W
	sublw	.1
	btfss	STATUS, Z
	goto	$+3
	movlw	.12
	call	Endereco_LCD

	movf	Select_U, W
	sublw	.2
	btfss	STATUS, Z
	goto	$+3
	movlw	.9
	call	Endereco_LCD



	btfsc	Enter
	goto	Init_Ajustar
	Desativar_cursor

	movlw	Endereco_Segundos_RTC
	movwf	Endereco_RTC
	movf	Segundos,0
	call	Gravar_RTC

	movlw	Endereco_Minutos_RTC
	movwf	Endereco_RTC
	movf	Minutos,0
	call	Gravar_RTC

	movlw	Endereco_Horas_RTC
	movwf	Endereco_RTC
	movf	Horas,0
	call	Gravar_RTC

	call	Limpar_LCD
	goto	Init
	sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas:
Adress_Table_LCD
	addwf PCL,f
	retlw	.15
	retlw	.12
	retlw	.9


Init_LCD
	clrf	PORTB
	BANK1
	movlw	b'00000001'
	movwf	TRISB
	BANK0
	call	Delay_5mS
	bsf		LCD_E				;Coloca o pino enable em 1
	nop
	nop
	bcf		LCD_E				;Volta o pino enable em 0
	nop
	nop	
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

Enviar_byte_lcd					;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	DESATIVAR_INT
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd
	ATIVAR_INT
	return						;Retorna da sub-rotina

Enviar_nibble_lcd
	movwf	Nibble
	movlw	b'00001111'
	andwf	PORTB
	andwf	Nibble
	swapf	Nibble,0
	iorwf	PORTB
	nop
	nop
	bsf		LCD_E				;Coloca o pino enable em 1
	nop
	nop
	bcf		LCD_E				;Volta o pino enable em 0	
	return

Enviar_char_lcd					;Sub-rotina para enviar um caracter para o display lcd
	movwf	Temp1
	call	Aguardar_BF_LCD			;
	movfw	Temp1
	bsf		LCD_RS
	nop
	nop
	call	Enviar_byte_lcd
	nop
	nop
	bcf		LCD_RS
	nop
	nop
	return						;Retorna da sub-rotina
								;
								;
Endereco_LCD
	movwf	Temp1
	call	Aguardar_BF_LCD
	movfw	Temp1
	iorlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	return

Linha_1_LCD
	call	Aguardar_BF_LCD
	movlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	return	

Linha_2_LCD
	call	Aguardar_BF_LCD
	movlw	b'11000000'
	call	Enviar_byte_lcd		;Envia o comando
	return

Limpar_LCD					;
	call	Aguardar_BF_LCD
	movlw	b'00000001'
	call	Enviar_byte_lcd		;Envia o comando
	return

Ler_byte_LCD					;Sub-rotina para ler uma byte do display LCD
	DESATIVAR_INT
	clrf	byte
	BANK1
	movlw	0xF0
	movwf	TRISB
	BANK0
	bsf		LCD_RW
	nop
	nop
	bsf		LCD_E
	nop
	nop
	movwf	0xF0
	andwf	PORTB, W	
	iorwf	byte, F
	bcf		LCD_E
	nop
	nop
	swapf	byte, F
	bsf		LCD_E
	nop
	nop
	movwf	0xF0
	andwf	PORTB, W	
	iorwf	byte, F
	bcf		LCD_E
	swapf	byte, F
	bcf		LCD_RW
	BANK1
	clrf	TRISB
	BANK0
	movfw	byte
	ATIVAR_INT
	return

Aguardar_BF_LCD					;Sub-rotina para esperar o display LCD ficar desocupado
	call	Ler_byte_LCD
	btfsc	byte, 7
	goto	Aguardar_BF_LCD
	return



Delay_40uS
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
Gravar_RTC
	movwf	Valor
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_RTC,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Valor,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	return




Ler_RTC
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_RTC,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,RSEN
	btfsc	SSPCON2,RSEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_leitura
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,RCEN
	BANK0


	call	Espera_I2C
	movf	SSPBUF,0
	movwf	Valor
	call	Enviar_NACK
	call	Espera_I2C
	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	movf	Valor,0
	return

Espera_I2C
	BANK1
	btfsc	SSPSTAT,R_W
	goto	$-1
	movf	SSPCON2,0
	andlw	B'00011111'
	btfss	STATUS,Z
	goto	$-3
	BANK0
	return

Enviar_NACK
	BANK1
	bsf		SSPCON2,ACKDT
	bsf		SSPCON2,ACKEN
	BANK0
	return

Converter_BCD_CHAR
	movwf	Valor
	swapf	Valor,1
	movlw	0x0F
	andwf	Valor,0
	addlw	0x30
	call	Enviar_char_lcd
	swapf	Valor,1
	movlw	0x0F
	andwf	Valor,0
	addlw	0x30
	call	Enviar_char_lcd
	return

Delay_300ms
			;299993 cycles
	movlw	0x5E
	movwf	delay1
	movlw	0xEB
	movwf	delay2
Delay_300ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_300ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

Incrementar_BCD
	movwf	Valor
	sublw	0x99
	btfss	STATUS,Z
	goto	$+3
	clrf	Valor
	goto	Fim_inc
	movf	Valor,0
	andlw	0x0F
	sublw	.9
	btfss	STATUS,Z
	goto	$+6
	movlw	0x10
	addwf	Valor
	movlw	0xF0
	andwf	Valor
	goto	Fim_inc
	incf	Valor,1
Fim_inc
	movf	Valor,0
	return

Decrementar_BCD
	movwf	Valor
	movf	Valor,1
	btfss	STATUS,Z
	goto	$+4
	movlw	0x99
	movwf	Valor
	goto	Fim_dec

	movf	Valor,0
	andlw	0x0F
	sublw	.0
	btfss	STATUS,Z
	goto	$+6
	movlw	0x10
	subwf	Valor
	movlw	.9
	addwf	Valor
	goto	Fim_dec
	decf	Valor,1
Fim_dec
	movf	Valor,0
	return

Delay_2S
			;1999996 cycles
	movlw	0x11
	movwf	delay1
	movlw	0x5D
	movwf	delay2
	movlw	0x05
	movwf	delay3
Delay_2S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_2S_0

			;4 cycles (including call)
	return


END