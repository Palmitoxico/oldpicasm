;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Data Logger LM35 + DS1307            			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 11.0592MHz							;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;Versão: 1.0                                   ;;
;;Data de início: 03/05/2011					;;
;;Data de término:                              ;;
;;                                              ;;
;;PIC 16F877									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _HS_OSC & _DEBUG_OFF


cblock 0x20
byte
Letra
DSP1
DSP2
DSP3
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
VAR
cont_d
Endereco_L
Endereco_H
Disp
Dado
cont2
W_2
STATUS_2
STATUS_3
Horas_Temp
VAR_BIT
Var_Temp
Count_endereco
PM_ADDRH
PM_ADDRL
DATAADDR:8
NumeroDeBytes
EnderecoInicial_H
EnderecoInicial_L
endc

#define	Stop_I2C			VAR_BIT,0
#define	I2C_Started			VAR_BIT,1
#define	Data_logger_mode	VAR_BIT,2
#define BootLoaderAcess		VAR_BIT,3

#define	Divisor_L	Multiplicador_L
#define	Divisor_H	Multiplicador_H
#define	Dividendo_L	Multiplicando_L
#define	Dividendo_H	Multiplicando_H

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

#Define Endereco_RTC_escrita b'11010000'
#Define Endereco_RTC_leitura b'11010001'

#Define Endereco_EEPROM_escrita b'10100010'
#Define Endereco_EEPROM_leitura b'10100011'

#Define Endereco_Segundos_RTC		0x00
#Define Endereco_Minutos_RTC		0x01
#Define Endereco_Horas_RTC			0x02
#Define Endereco_Semana_RTC			0x03
#Define Endereco_Dia_RTC			0x04
#Define Endereco_Mes_RTC			0x05
#Define Endereco_Ano_RTC			0x06

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

org 0x0000
goto	Main
nop
nop
nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina da interrupção
ORG  0X0004
BANKSEL	PIE1
btfsc	PIE1, RCIF
goto	Int_USART
retfie

Int_USART

BANK0
movwf	W_2
movf	STATUS, W
movwf	STATUS_2

movf	RCREG, W
andlw	b'11011111'
sublw	'P'
btfss	STATUS,Z
goto	Fim_GravarPrograma
BANK2
movlw	0x00
movwf	PM_ADDRH
movlw	0x00
movwf	PM_ADDRL

movlw	0x00
movwf 	DATAADDR

movlw	high(Bootloader)
movwf	PCLATH
goto	Bootloader
BANK0
goto	Int_USART_Fim	
Fim_GravarPrograma:

Ativar_DataLogger:
movf	RCREG, W
andlw	b'11011111'
sublw	'A'
btfss	STATUS,Z
goto	Fim_Ativar_DataLogger
bsf		Data_logger_mode
goto	Int_USART_Fim
Fim_Ativar_DataLogger:

Desativar_DataLogger:
movf	RCREG, W
andlw	b'11011111'
sublw	'D'
btfss	STATUS,Z
goto	Fim_desativar_DataLogger
bcf		Data_logger_mode
goto	Int_USART_Fim
Fim_desativar_DataLogger:

movf	RCREG, W
andlw	b'11011111'
sublw	'T'
btfss	STATUS,Z
goto	Fim_Temp

movf	Temperatura, W
call	Converter_Bin_Dec_8bit

movf	DSP2, W
call	Enviar_byte_rs232
movf	DSP1, W
call	Enviar_byte_rs232
movlw	'°'
call	Enviar_byte_rs232
movlw	'C'
call	Enviar_byte_rs232

movlw	0x0D
call	Enviar_byte_rs232

goto	Int_USART_Fim	
Fim_Temp:

EEPROM_LG
movf	RCREG, W
andlw	b'11011111'
sublw	'M'
btfss	STATUS,Z
goto	Fim_EEPROM_LG
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
andlw	b'11011111'
sublw	'G'
btfss	STATUS,Z
goto	Fim_Gravar_EEPROM_RS232

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
movwf	Endereco_L

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
movwf	Endereco_H

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W

call	Gravar_EEPROM
call	Delay_5ms
movlw	0x0D
call	Enviar_byte_rs232
goto	Int_USART_Fim
Fim_Gravar_EEPROM_RS232:

movf	RCREG, W
andlw	b'11011111'
sublw	'L'
btfss	STATUS,Z
goto	Fim_EEPROM_LG

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
movwf	Endereco_L

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
movwf	Endereco_H

call	Ler_EEPROM

call	Enviar_byte_rs232
goto	Int_USART_Fim
Fim_EEPROM_LG:


Fim_Ler:

Horas_LG
movf	RCREG, W
andlw	b'11011111'
sublw	'H'
btfss	STATUS,Z
goto	Erro_Sintaxe

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
andlw	b'11011111'
sublw	'G'
btfss	STATUS,Z
goto	$+2
goto	Gravar_Horas

movf	RCREG, W
andlw	b'11011111'
sublw	'L'
btfss	STATUS,Z
goto	Fim_Horas

call	Ler_RTC_Horas
call	Converter_BCD_CHAR_RS232
movlw	':'
call	Enviar_byte_rs232
call	Ler_RTC_Minutos
call	Converter_BCD_CHAR_RS232
movlw	':'
call	Enviar_byte_rs232
call	Ler_RTC_Segundos
andlw	b'01111111'
call	Converter_BCD_CHAR_RS232
movlw	','
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232

call	Ler_RTC_Dia
call	Converter_BCD_CHAR_RS232
movlw	'/'
call	Enviar_byte_rs232
call	Ler_RTC_Mes
call	Converter_BCD_CHAR_RS232
movlw	'/'
call	Enviar_byte_rs232
call	Ler_RTC_Ano
call	Converter_BCD_CHAR_RS232

movlw	0x0D
call	Enviar_byte_rs232
goto	Int_USART_Fim

Gravar_Horas:

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Horas


btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Minutos


btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
andlw	b'01111111'
call	Gravar_RTC_Segundos

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Semana

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Dia


btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Mes

btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
call	Gravar_RTC_Ano

goto	Int_USART_Fim

Fim_Horas:


Erro_Sintaxe:
movlw	'E'
call	Enviar_byte_rs232
movlw	'r'
call	Enviar_byte_rs232
movlw	'r'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	'd'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	's'
call	Enviar_byte_rs232
movlw	'i'
call	Enviar_byte_rs232
movlw	'n'
call	Enviar_byte_rs232
movlw	't'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'x'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	0x0D
call	Enviar_byte_rs232


Int_USART_Fim:
movf	STATUS_2,W
movwf	STATUS
movf	W_2
retfie
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal:
Main
bsf		Stop_I2C
bcf		I2C_Started
bcf		Data_logger_mode
movlw	b'00101000'
movwf	SSPCON
clrf	PORTB				;Limpa a porta B	
clrf	PORTE				;Limpa a porta E
movlw	b'11000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
movwf	ADCON0
clrf	Media_Temp_L
clrf	Media_Temp_H
clrf	Temperatura
clrf	Media_Count
clrf	Endereco_L
clrf	Endereco_H
BANK1						;Vai para o banco 1 da memória
clrf	TRISB				;Toda a porta B como saída
bcf		SSPSTAT,CKE
movlw	.28
movwf	SSPADD
movlw	b'10000010'			;Configura a porta A como entrada analógica
movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
movlw	B'00100100'
movwf	TXSTA				; CONFIGURA USART
							; HABILITA TX
							; MODO ASSINCRONO
							; TRANSMISSÃO DE 8 BITS
							; LOW SPEED BAUD RATE
movlw	.5
movwf	SPBRG				; ACERTA BAUD RATE -> 115200bps

BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0

movlw	b'11000000'			;
movwf	INTCON				;
movlw	B'10010000'
movwf	RCSTA				; CONFIGURA USART

bcf		BootLoaderAcess
bcf		SSPSTAT,2
call	Delay_200ms

movlw	'D'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	't'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'-'
call	Enviar_byte_rs232
movlw	'L'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	'g'
call	Enviar_byte_rs232
movlw	'g'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	'r'
call	Enviar_byte_rs232
movlw	0x0D
call	Enviar_byte_rs232



Loop:	



btfss	Data_logger_mode
goto	Fim_gravar
movlw	Endereco_Horas_RTC
movwf	Endereco_RTC
call	Ler_RTC
subwf	Horas_Temp, W
btfsc	STATUS,Z
goto	Fim_gravar

movf	Temperatura, W
call	Converter_Bin_Dec_8bit

BANKSEL	PIE1
bcf		PIE1, RCIE
BANK0

movf	DSP2,W
bsf		Stop_I2C
call	Gravar_EEPROM
incfsz	Endereco_L, F
goto	$+2
incf	Endereco_H, F
call	Delay_5ms

movf	DSP1,W
bsf		Stop_I2C
call	Gravar_EEPROM
incfsz	Endereco_L, F
goto	$+2
incf	Endereco_H, F	
call	Delay_5ms

movlw	' '
bsf		Stop_I2C
call	Gravar_EEPROM
incfsz	Endereco_L, F
goto	$+2
incf	Endereco_H, F	
call	Delay_5ms

BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0

movlw	Endereco_Horas_RTC
movwf	Endereco_RTC

call	Ler_RTC
movwf	Horas_Temp

Fim_gravar:
bsf		ADCON0,2
btfsc	ADCON0,2
goto	$-1
call	Delay_5ms


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

	goto	Loop
	sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas:
	Enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
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

Converter_BCD_CHAR_RS232
	movwf	Valor
	swapf	Valor,1
	movlw	0x0F
	andwf	Valor,0
	addlw	0x30
	call	Enviar_byte_rs232
	swapf	Valor,1
	movlw	0x0F
	andwf	Valor,0
	addlw	0x30
	call	Enviar_byte_rs232
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

Ler_EEPROM
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_EEPROM_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_H,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_L,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,RSEN
	btfsc	SSPCON2,RSEN
	goto	$-1
	BANK0

	movlw	Endereco_EEPROM_leitura
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
	return

Gravar_EEPROM
	movwf	Valor
	btfsc	I2C_Started
	goto	Sem_Start
	bsf		I2C_Started
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0


	movlw	Endereco_EEPROM_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_H,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco_L,0
	movwf	SSPBUF

	call	Espera_I2C
Sem_Start:

	movf	Valor,0
	movwf	SSPBUF

	call	Espera_I2C

	btfss	Stop_I2C
	goto	Fim_Gravar_EEPROM
	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	bcf		I2C_Started
Fim_Gravar_EEPROM:
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


Converter_Bin_Dec_8bit
	movwf	VAR
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movf	VAR, F
	btfsc	STATUS, Z
	goto	Ajuste_ASCII
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
Ajuste_ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	return
Delay_5ms
			;13818 cycles
	movlw	0xCB
	movwf	delay1
	movlw	0x0B
	movwf	delay2
Delay_5ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_5ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bootloader

org 0x1F38
Bootloader:
bcf		INTCON, GIE
movlw	0x01
call	Enviar_byte_rs232_BootL

Loop_Gravar_Programa:

BANK2
clrf	EEADRH
clrf	EEADR

BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	NumeroDeBytes
bcf		STATUS, C
rrf		NumeroDeBytes, 1


BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEADR


BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEADRH

GravarDataBytes:
BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEDATA

BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEDATH

call	Gravar_Instrucao

incfsz	EEADR, F
goto	$+2
incf	EEADRH, F

decfsz	NumeroDeBytes, F
goto	GravarDataBytes


movlw	0x17
call	Enviar_byte_rs232_BootL
goto	Loop_Gravar_Programa

sleep

Gravar_Instrucao:
	BANK3
	bsf		EECON1,EEPGD
	bsf		EECON1,WREN
	movlw   0x55
	movwf   EECON2
	movlw   0xAA
	movwf   EECON2	
	bsf     EECON1 , 1
	nop    
	nop   
	btfsc   EECON1 , 1
	goto    $-1
	bcf     EECON1 , 2
	BANK2
	return

Enviar_byte_rs232_BootL
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return


END