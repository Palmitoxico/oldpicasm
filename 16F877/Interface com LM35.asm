;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Interface com LM35 e DS1307          			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;                               				;;
;;                        						;;
;;												;;
;;                    							;;
;;												;;
;;Data: 30/06/2011  							;;
;;												;;
;;PIC 16F877									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877A
include <p16f877A.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _XT_OSC & _CP_OFF


cblock 0x20
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
Endereco_RTC
Valor
Segundos
Minutos
Horas
Select_U
Media_Temp_L
Media_Temp_H
Temperatura
Media_Count
Multiplicador_L
Multiplicador_H
Multiplicando_L
Multiplicando_H
Resultado_L
Resultado_H
Base_Index_L
Base_Index_H
Temp1
VAR
VAR_L
VAR_H
cont_d
Endereco_L
Endereco_H
Disp
Dado
Backlight_Delay
W_2
STATUS_2
Count_L
Count_H
endc

#define	Divisor_L	Multiplicador_L
#define	Divisor_H	Multiplicador_H
#define	Dividendo_L	Multiplicando_L
#define	Dividendo_H	Multiplicando_H

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

#Define Endereco_RTC_escrita b'11010000'
#Define Endereco_RTC_leitura b'11010001'

#Define Endereco_Segundos_RTC		0x00
#Define Endereco_Minutos_RTC		0x01
#Define Endereco_Horas_RTC			0x02
#Define Endereco_Semana_RTC			0x03
#Define Endereco_Dia_RTC			0x04
#Define Endereco_Mes_RTC			0x05
#Define Endereco_Ano_RTC			0x06

#Define Endereco_EEPROM_escrita b'10100010'
#Define Endereco_EEPROM_leitura b'10100011'

								;Definição de macro-comandos	
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

DESATIVAR_INT macro
bcf		INTCON,GIE
Endm

ATIVAR_INT macro
bsf		INTCON,GIE
Endm

org 0x0000
goto	Main

ORG  0X0004						;Rotina da interrupção
movwf	W_2
movf	STATUS, W
movwf	STATUS_2
BANK0
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1

clrw
call	Endereco_LCD

call	Ler_RTC_Horas
call	Converter_BCD_CHAR
movf	DSP2, W
call	Enviar_char_lcd
movf	DSP1, W
call	Enviar_char_lcd


movlw	':'
call	Enviar_char_lcd
call	Ler_RTC_Minutos
call	Converter_BCD_CHAR
movf	DSP2, W
call	Enviar_char_lcd
movf	DSP1, W
call	Enviar_char_lcd

movlw	':'
call	Enviar_char_lcd
call	Ler_RTC_Segundos
call	Converter_BCD_CHAR
movf	DSP2, W
call	Enviar_char_lcd
movf	DSP1, W
call	Enviar_char_lcd

movlw	0x40
call	Endereco_LCD

movf	Temperatura, W
call	Converter_Bin_Dec_8bit

movf	DSP2, W
call	Enviar_char_lcd
movf	DSP1, W
call	Enviar_char_lcd
movlw	0xDF
call	Enviar_char_lcd
movlw	'C'
call	Enviar_char_lcd

movf	Backlight_Delay, F
btfsc	STATUS, Z
goto	Backlight_Fim
movlw	0xFF
movwf	PORTE
decfsz	Backlight_Delay, F
goto	Backlight_Fim
clrf	PORTE

Backlight_Fim
								;
INT_FIM							;
movlw	low(.63036)
movwf	TMR1L
movlw	high(.63036)
movwf	TMR1H


movf	STATUS_2,W
movwf	STATUS
movf	W_2
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Fim do tratamento das interrupções, começo da rotina princiapal.
Main
BANK0

clrf	PORTA
clrf	PORTB
clrf	PORTC
clrf	PORTD
clrf	PORTE
clrf	Count_L
clrf	Count_H

movlw	b'01000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
movwf	ADCON0

clrf	Media_Temp_L
clrf	Media_Temp_H
clrf	Temperatura
clrf	Media_Count
clrf	Endereco_L
clrf	Endereco_H
clrf	Backlight_Delay


movlw	b'00101000'
movwf	SSPCON
BANK1
bcf		OPTION_REG , 7
movlw	b'110'
movwf	TRISE
movlw	b'10000010'			;Configura a porta A como entrada analógica
movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
bcf		SSPSTAT,CKE
movlw	.9
movwf	SSPADD
BANK0

bcf		SSPSTAT,2


movlw	low(.63036)
movwf	TMR1L
movlw	high(.63036)
movwf	TMR1H

call	Delay_200ms
call	Init_LCD

btfsc	PORTC, 2
goto	Fim_atualizar_horario
movlw	0x00
call	Gravar_RTC_Segundos
movlw	0x52
call	Gravar_RTC_Minutos
movlw	0x19
call	Gravar_RTC_Horas
movlw	0x02
call	Gravar_RTC_Dia
movlw	0x05
call	Gravar_RTC_Mes
movlw	0x12
call	Gravar_RTC_Ano
Fim_atualizar_horario

movlw	'0'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd
movlw	':'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd
movlw	':'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd

movlw	0x40
call	Endereco_LCD

movf	Temperatura, W
call	Converter_Bin_Dec_8bit

movlw	'0'
call	Enviar_char_lcd
movlw	'0'
call	Enviar_char_lcd
movlw	0xDF
call	Enviar_char_lcd
movlw	'C'
call	Enviar_char_lcd



movlw	b'11000000'			;
movwf	INTCON				;

movlw	b'00110001'			;
movwf	T1CON				;

BANK1
bsf		PIE1 , TMR1IE
BANK0

loop:
btfsc	PORTC, 2			;Caso o botão seja precionado, o backlight permanecerá
goto	$+3					;aceso durante 5 segundos -->250 x 0,020 S(perído do timer1) = 5s
movlw	.250
movwf	Backlight_Delay

bsf		ADCON0,2






btfsc	ADCON0,2
goto	$-1


BANK1
movf	ADRESL, W
BANK0
addwf	Media_Temp_L, F
btfsc	STATUS, C
incf	Media_Temp_H, F

movf	ADRESH, W
addwf	Media_Temp_H

incf	Media_Count, F
movf	Media_Count, W
sublw	.16
btfss	STATUS, Z
goto	Fim_media

bcf		STATUS, C

rrf		Media_Temp_H, F
rrf		Media_Temp_L, F
bcf		STATUS, C
rrf		Media_Temp_H, F
rrf		Media_Temp_L, F
bcf		STATUS, C
rrf		Media_Temp_H, F
rrf		Media_Temp_L, F
bcf		STATUS, C
rrf		Media_Temp_H, F
rrf		Media_Temp_L, F

bcf		STATUS, C

movf	Media_Temp_H, W
movwf	Multiplicando_H

movf	Media_Temp_L, W
movwf	Multiplicando_L

movlw	high(.125)
movwf	Multiplicador_H

movlw	low(.125)
movwf	Multiplicador_L

call	MULV16

bcf		STATUS, C

rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C
rrf		Resultado_H, F
rrf		Resultado_L, F
bcf		STATUS, C



movf	Resultado_L, W
movwf	Temperatura

clrf	Media_Temp_H
clrf	Media_Temp_L
clrf	Media_Count





Fim_media:

DESATIVAR_INT
call	Delay_40uS
ATIVAR_INT
goto	loop





sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas
Init_LCD
	clrf	PORTB
	BANK1
	movlw	b'00000001'
	movwf	TRISB
	BANK0
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
	return		
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

Delay_500ms
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_500ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_500ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return

Converter_Bin_Dec_8bit
	movwf	VAR
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	VAR, 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP3 , 1
	goto	$-4
	movlw	.100
	addwf	VAR, 1
	movlw	.10
	subwf	VAR, 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	VAR, 0
	movwf	DSP1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	return

Converter_Bin_Dec_16bit

	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	clrf	DSP4
	clrf	DSP5


	Ajuste_DSP5

	movlw	0x10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0x10
	addwf	VAR_L, F
	goto	FIM_DSP5


	movlw	0x27
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP5
	goto	Ajuste_DSP5

	movlw	0x10
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x27
	addwf	VAR_H, F


	FIM_DSP5




	Ajuste_DSP4

	movlw	0xE8
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0xE8
	addwf	VAR_L, F
	goto	FIM_DSP4


	movlw	0x03
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP4
	goto	Ajuste_DSP4

	movlw	0xE8
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x03
	addwf	VAR_H, F


	FIM_DSP4


	Ajuste_DSP3

	movlw	.100
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.100
	addwf	VAR_L, F
	goto	FIM_DSP3

	incf	DSP3, F
	goto	Ajuste_DSP3

	FIM_DSP3


	Ajuste_DSP2

	movlw	.10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.10
	addwf	VAR_L, F
	goto	FIM_DSP2

	incf	DSP2, F
	goto	Ajuste_DSP2

	FIM_DSP2


	Ajuste_DSP1

	movf	VAR_L, W
	movwf	DSP1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
	addwf	DSP4, F
	addwf	DSP5, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	return

MULV16 
	clrf    Resultado_L
	clrf    Resultado_H
MULU16LOOP
	btfsc	Multiplicando_L,0
	call	ADD16
	bcf		STATUS,C
	rrf 	Multiplicando_H,F
	rrf 	Multiplicando_L,F
	bcf 	STATUS,C
	rlf 	Multiplicador_L,F
	rlf 	Multiplicador_H,F
	movf	Multiplicando_L,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	movf	Multiplicando_H,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	return

ADD16
	movf	Multiplicador_L,W
	addwf	Resultado_L
	btfsc	STATUS,C
	incf	Resultado_H
	movf	Multiplicador_H,W
	addwf	Resultado_H
	return

Gravar_RTC_Segundos
movwf	Valor
movlw	Endereco_Segundos_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Minutos
movwf	Valor
movlw	Endereco_Minutos_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Horas
movwf	Valor
movlw	Endereco_Horas_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Semana
movwf	Valor
movlw	Endereco_Semana_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Dia
movwf	Valor
movlw	Endereco_Dia_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Mes
movwf	Valor
movlw	Endereco_Mes_RTC
movwf	Endereco_RTC
goto	Gravar_RTC
Gravar_RTC_Ano
movwf	Valor
movlw	Endereco_Ano_RTC
movwf	Endereco_RTC
Gravar_RTC
BANKSEL	PIE1
bcf		PIE1, RCIE
BANK0
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
BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0
	return




Ler_RTC_Segundos
movlw	Endereco_Segundos_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Minutos
movlw	Endereco_Minutos_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Horas
movlw	Endereco_Horas_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Semana
movlw	Endereco_Semana_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Dia
movlw	Endereco_Dia_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Mes
movlw	Endereco_Mes_RTC
movwf	Endereco_RTC
goto	Ler_RTC
Ler_RTC_Ano
movlw	Endereco_Ano_RTC
movwf	Endereco_RTC
Ler_RTC
BANKSEL	PIE1
bcf		PIE1, RCIE
BANK0
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
	movf	Valor,W
BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0
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
	movwf	DSP2
	swapf	Valor,1
	movlw	0x0F
	andwf	Valor,0
	addlw	0x30
	movwf	DSP1
	return


sleep
nop
END