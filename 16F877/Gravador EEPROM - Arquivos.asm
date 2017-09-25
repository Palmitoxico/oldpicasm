processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF

Cont1		EQU 0x20			;Define as constantes de endereço 
Cont2		EQU 0x21
byte		EQU 0x22
Letra		EQU 0x23
delay1		EQU 0x24
delay2		EQU 0x25	
delay3		EQU 0x26	
p_lcd		EQU 0x27
Endereco1	EQU 0x28
Endereco2	EQU 0x29
End_Cont	EQU 0x2A
Valor		EQU 0x2B
bit_config	EQU	0x2C
DSP1		EQU	0x2D
DSP2		EQU	0x2E
DSP3		EQU	0x2F
DSP4		EQU	0x30
DSP5		EQU	0x31
mem_H		EQU	0x32
mem_L		EQU	0x33

#Define  Endereco_RTC_escrita b'10100000'
#Define  Endereco_RTC_leitura b'10100001'







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
E_1 macro						;Coloca o pino enable em 1
bsf		PORTE ,2				;
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
bcf		PORTE ,2				;
Endm							;
								;
RS_1 macro						;Coloca o pino RS em 1
movlw	0x05					;
movwf	PORTE					;
Endm							;
								;
RS_0 macro						;Coloca o pino RS em 0
movlw	0x04					;
movwf	PORTE					;
Endm							;
								;
RW_1 macro						;Coloca o pino RW em 1
bsf  PORTE , 1					;
Endm							;
								;
RW_0 macro						;Coloca o pino RW em 0
bcf  PORTE , 1					;
Endm							;
								;
BF_E macro						;Configura como entrada a porta B
BANK1							;
movlw	0xFF					;
movwf	TRISB					;
BANK0							;
Endm							;
								;
BF_S macro						;Configura como saida o nibble alto da porta B
BANK1							;
clrf  TRISB						;
BANK0							;
Endm							;


Main
	movlw	b'00101000'
	movwf	SSPCON
	clrf	Endereco1
	clrf	Endereco2
	BANK1
	movlw	B'00100100'
	movwf	TXSTA			; CONFIGURA USART
							; HABILITA TX
							; MODO ASSINCRONO
							; TRANSMISSÃO DE 8 BITS
							; LOW SPEED BAUD RATE
	movlw	.12
	movwf	SPBRG			; ACERTA BAUD RATE -> 19200bps
	bcf		SSPSTAT,CKE
	movlw	0x02
	movwf	SSPADD
	BANK0
	movlw	B'10010000'
	movwf	RCSTA			; CONFIGURA USART
							; HABILITA RX
							; RECEPÇÃO DE 8 BITS
							; RECEPÇÃO CONTÍNUA
							; DESABILITA ADDRESS DETECT
	bcf		SSPSTAT,2		



	


Boot_fim
	call	Limpar_LCD
	movlw	'I'
	call	enviar_char_lcd
	movlw	'n'
	call	enviar_char_lcd
	movlw	'i'
	call	enviar_char_lcd
	movlw	'c'
	call	enviar_char_lcd
	movlw	'i'
	call	enviar_char_lcd
	movlw	'a'
	call	enviar_char_lcd
	movlw	'n'
	call	enviar_char_lcd
	movlw	'd'
	call	enviar_char_lcd
	movlw	'o'
	call	enviar_char_lcd
	movlw	' '
	call	enviar_char_lcd
	movlw	's'
	call	enviar_char_lcd
	movlw	'i'
	call	enviar_char_lcd
	movlw	's'
	call	enviar_char_lcd
	movlw	't'
	call	enviar_char_lcd
	movlw	'e'
	call	enviar_char_lcd
	movlw	'm'
	call	enviar_char_lcd
	movlw	'a'
	call	enviar_char_lcd
	movlw	'.'
	call	enviar_char_lcd
	movlw	'.'
	call	enviar_char_lcd
	movlw	'.'
	call	enviar_char_lcd
	call	Delay_1S
	movlw	'I'
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'c'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232
	movlw	'd'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'f'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'c'
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

	movlw	'.'
	call	enviar_byte_rs232
	movlw	'.'
	call	enviar_byte_rs232
	movlw	'.'
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232
	call	Delay_1S

	call	Detectar_disp
	btfsc	bit_config,6
	goto	ERRO_memoria

	clrf	Endereco1
	call	Ler_EEPROM
	sublw	'S'
	btfss	STATUS,Z
	goto	FIM_test_format
	movlw	0x01
	movwf	Endereco1
	call	Ler_EEPROM
	sublw	'F'
	btfss	STATUS,Z
	goto	FIM_test_format
	movlw	0x02
	movwf	Endereco1
	call	Ler_EEPROM
	sublw	'T'
	btfss	STATUS,Z
	goto	FIM_test_format
	goto	Fim_memoria
FIM_test_format
	call	ERRO_MEMORIA_FORMAT
Fim_memoria
	movlw	'M'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232

	movlw	'O'
	call	enviar_byte_rs232
	movlw	'K'
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232
	sleep


ERRO_memoria
	movlw	'R'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'-'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'c'
	call	enviar_byte_rs232

	movlw	'i'
	call	enviar_byte_rs232

	movlw	'a'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232

	movlw	'?'
	call	enviar_byte_rs232
	movlw	'('
	call	enviar_byte_rs232
	movlw	'S'
	call	enviar_byte_rs232
	movlw	'/'
	call	enviar_byte_rs232
	movlw	'N'
	call	enviar_byte_rs232

	movlw	')'
	call	enviar_byte_rs232

Cond_SN_init
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'>'
	call	enviar_byte_rs232
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG,0
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'S'
	subwf	RCREG , 0
	btfss	STATUS , Z
	goto	S_init_fim
	goto	Main

S_init_fim

	movlw	'N'
	subwf	RCREG , 0
	btfss	STATUS , Z
	goto	Cond_SN_init
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'F'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'l'
	call	enviar_byte_rs232
	movlw	'h'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232

	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232


	

sleep


Fim_P
	call	Limpar_LCD
	movlw	'M'
	call	enviar_char_lcd
	movlw	'e'
	call	enviar_char_lcd
	movlw	'm'
	call	enviar_char_lcd
	movlw	'o'
	call	enviar_char_lcd
	movlw	'r'
	call	enviar_char_lcd
	movlw	'i'
	call	enviar_char_lcd
	movlw	'a'
	call	enviar_char_lcd
	movlw	' '
	call	enviar_char_lcd
	movlw	'O'
	call	enviar_char_lcd
	movlw	'K'
	call	enviar_char_lcd
	call	Delay_1S
	goto	Boot_fim
	

	sleep

Gravar_EEPROM
	movwf	Valor
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco2,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco1,0
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




Ler_EEPROM
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco2,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco1,0
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
	
Formatar
	clrf	Endereco1
	clrf	Endereco2



Format_Init

	clrf	End_Cont

	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco2,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco1,0
	movwf	SSPBUF
	call	Espera_I2C

Format_Init1
	incfsz	Endereco1,1
	goto	$+4
	incfsz	Endereco2,1
	goto	$+2
	goto	Fim_Formatar

	movlw	0xFF
	movwf	SSPBUF

	call	Espera_I2C

	incf	End_Cont,1
	movf	End_Cont,0
	sublw	.128
	btfss	STATUS,Z
	goto	Format_Init1
	
	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0

	call	Delay_5ms
	goto	Format_Init

Fim_Formatar
	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	call	Delay_5ms
	movlw	0xFF
	movwf	Endereco1
	movwf	Endereco2
	call	Gravar_EEPROM

	clrf	Endereco1
	clrf	Endereco2
	call	Delay_5ms
	movlw	'S'
	call	Gravar_EEPROM
	call	Delay_5ms
	movlw	'S'
	call	Gravar_EEPROM
	movlw	0x01
	movwf	Endereco1
	call	Delay_5ms
	movlw	'F'
	call	Gravar_EEPROM

	movlw	0x02
	movwf	Endereco1
	call	Delay_5ms
	movlw	'T'
	call	Gravar_EEPROM

	movlw	0x03
	movwf	Endereco1
	call	Delay_5ms
	movlw	0xFF
	call	Gravar_EEPROM

	movlw	0x04
	movwf	Endereco1
	call	Delay_5ms
	movlw	0xFF
	call	Gravar_EEPROM

	movlw	0x05
	movwf	Endereco1
	call	Delay_5ms
	movlw	0x00
	call	Gravar_EEPROM

	movlw	0x06
	movwf	Endereco1
	call	Delay_5ms
	movlw	0x07
	call	Gravar_EEPROM
	
	return

Delay_5ms
	movlw	0x13
	movwf	delay1
	movlw	0x88
	movwf	delay2

	decfsz	delay2,1
	goto	$-1
	decfsz	delay1,1
	goto	$-3

	return


Detectar_disp

	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF
	call	Espera_I2C

	movlw	0x00
	movwf	SSPBUF


	call	Espera_I2C
	BANK1
	movf	SSPCON2,0
	BANK0
	movwf	bit_config

	movlw	0x00
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
	btfss	bit_config,6
	goto	Teste_da_memoria
	movlw	'S'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'!'
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232
	return
Teste_da_memoria
	movlw	0x03
	movwf	Endereco1
	call	Ler_EEPROM
	movwf	mem_H
	movlw	0x04
	movwf	Endereco1
	call	Ler_EEPROM
	movwf	mem_L
	call	Converter

	movlw	'M'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'l'
	call	enviar_byte_rs232
	movlw	':'
	call	enviar_byte_rs232

	movf	DSP1,0
	call	enviar_byte_rs232
	movf	DSP2,0
	call	enviar_byte_rs232
	movf	DSP3,0
	call	enviar_byte_rs232
	movf	DSP4,0
	call	enviar_byte_rs232
	movf	DSP5,0
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232
	movlw	'b'
	call	enviar_byte_rs232
	movlw	'y'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	's'
	call	enviar_byte_rs232


	movlw	0x0D
	call	enviar_byte_rs232
	return


Delay_1S
			;999997 cycles
	movlw	0x08
	movwf	delay1
	movlw	0x2F
	movwf	delay2
	movlw	0x03
	movwf	delay3
Delay_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_0

			;3 cycles
	goto	$+1
	return

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return

	Converter					;Sub-rotina para a conversão de números para caracteres
								;
								;
	clrf	DSP1				;Limpa as variáveis para realizar a decomposição do número
	clrf	DSP2				;
	clrf	DSP3				;
	clrf	DSP4				;
	clrf	DSP5				;
								;
								;
	Inicio_dec					;
	movf	mem_L,W				;
	btfss	STATUS,Z			;
	goto	$+6					;
	decf	mem_L,F				;
	movf	mem_H,W				;
	btfss	STATUS,Z			;
	goto	$+4					;
	goto	fim_dec				;
	decf	mem_L,F				;
	goto	$+2					;
	decf	mem_H,F				;
								;
	incf	DSP5,F				;
	movf	DSP5,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP5				;
	incf	DSP4,F				;
	movf	DSP4,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP4				;
	incf	DSP3,F				;
	movf	DSP3,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP3				;
	incf	DSP2,F				;
	movf	DSP2,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP2				;
	incf	DSP1,F				;
	goto	Inicio_dec			;
	fim_dec						;Fim da decomposição do número	
								;
								;
								;
	incf	DSP5,1
								;
	movlw	0x30				;
	addwf	DSP1 , 1			;
								;
	movlw	0x30				;
	addwf	DSP2 , 1			;
								;
	movlw	0x30				;
	addwf	DSP3 , 1			;
								;
	movlw	0x30				;
	addwf	DSP4 , 1			;
								;
	movlw	0x30				;	
	addwf	DSP5 , 1			;
								;

	clrf	mem_L				;
	clrf	mem_H				;
	return						;Retorna da sub-rotina

ERRO_MEMORIA_FORMAT

	movlw	'M'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'n'
	call	enviar_byte_rs232

	movlw	'a'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'f'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232

	movlw	'd'
	call	enviar_byte_rs232

	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'u'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'c'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'p'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'd'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'!'
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'F'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232

	movlw	'r'
	call	enviar_byte_rs232

	movlw	'?'
	call	enviar_byte_rs232

	movlw	'('
	call	enviar_byte_rs232
	movlw	'S'
	call	enviar_byte_rs232
	movlw	'/'
	call	enviar_byte_rs232
	movlw	'N'
	call	enviar_byte_rs232

	movlw	')'
	call	enviar_byte_rs232






Cond_SN_format
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'>'
	call	enviar_byte_rs232
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG,0
	call	enviar_byte_rs232
	movlw	'S'
	subwf	RCREG , 0
	btfss	STATUS , Z
	goto	S_format_fim
	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'F'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232

	movlw	'n'
	call	enviar_byte_rs232

	movlw	'd'
	call	enviar_byte_rs232

	movlw	'o'
	call	enviar_byte_rs232
	movlw	'.'
	call	enviar_byte_rs232
	movlw	'.'
	call	enviar_byte_rs232
	movlw	'.'
	call	enviar_byte_rs232
	
	call	Formatar

	movlw	0x0D
	call	enviar_byte_rs232
	movlw	'M'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'i'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232

	movlw	' '
	call	enviar_byte_rs232

	movlw	'f'
	call	enviar_byte_rs232

	movlw	'o'
	call	enviar_byte_rs232
	movlw	'r'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	't'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	'd'
	call	enviar_byte_rs232
	movlw	'a'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	'c'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'm'
	call	enviar_byte_rs232
	movlw	' '
	call	enviar_byte_rs232
	movlw	's'
	call	enviar_byte_rs232
	movlw	'u'
	call	enviar_byte_rs232
	movlw	'c'
	call	enviar_byte_rs232
	movlw	'e'
	call	enviar_byte_rs232
	movlw	's'
	call	enviar_byte_rs232
	movlw	's'
	call	enviar_byte_rs232
	movlw	'o'
	call	enviar_byte_rs232
	movlw	'!'
	call	enviar_byte_rs232
	movlw	0x0D
	call	enviar_byte_rs232

	return
S_format_fim

	movlw	'N'
	subwf	RCREG , 0
	btfss	STATUS , Z
	goto	Cond_SN_format
	

	return



END