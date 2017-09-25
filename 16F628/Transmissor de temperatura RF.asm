;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Template PIC16F628 TÍTULO AQUI!               ;;
;;Desenvolvido por Augusto Fraga Giachero       ;;
;;Tipo de oscilador                             ;;
;;                                              ;;
;;Comentários                                   ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;Data:   /  /                                  ;;
;;                                              ;;
;;PIC 16F628                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628
include <p16F628.inc>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Configuração dos fusíveis
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _HS_OSC & _BODEN_ON & _CPD_OFF & _MCLRE_ON

;_FOSC_LP:				LP oscillator: Low-power crystal on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_LP_OSC:				LP oscillator: Low-power crystal on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_XT:				XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_XT_OSC:				XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_HS:				HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_HS_OSC:				HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_ECIO:			EC: I/O function on RA6/OSC2/CLKOUT pin, CLKIN on RA7/OSC1/CLKIN
;_EXTCLK_OSC:			EC: I/O function on RA6/OSC2/CLKOUT pin, CLKIN on RA7/OSC1/CLKIN
;_FOSC_INTOSCIO:		INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTOSC_OSC_NOCLKOUT:	INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTRC_OSC_NOCLKOUT:	INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_FOSC_INTOSCCLK:		INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTOSC_OSC_CLKOUT:	INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTRC_OSC_CLKOUT:		INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_FOSC_EXTRCIO:			RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_RC_OSC_NOCLKOUT:		RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_ER_OSC_NOCLKOUT:		RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_FOSC_EXTRCCLK:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_RC_OSC_CLKOUT:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_ER_OSC_CLKOUT:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN

;_WDTE_OFF:				WDT disabled
;_WDT_OFF:				WDT disabled
;_WDTE_ON:				WDT enabled
;_WDT_ON:				WDT enabled

;_PWRTE_ON:				PWRT enabled
;_PWRTE_OFF:			PWRT disabled

;_MCLRE_OFF:			RA5/MCLR/VPP pin function is digital input, MCLR internally tied to VDD
;_MCLRE_ON:				RA5/MCLR/VPP pin function is MCLR

;_BOREN_OFF:			BOD disabled
;_BODEN_OFF:			BOD disabled
;_BOREN_ON:				BOD enabled
;_BODEN_ON:				BOD enabled

;_LVP_OFF:				RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming
;_LVP_ON:				RB4/PGM pin has PGM function, low-voltage programming enabled

;_CPD_ON:				Data memory code-protected
;DATA_CP_ON:			Data memory code-protected
;_CPD_OFF:				Data memory code protection off
;DATA_CP_OFF:			Data memory code protection off

;_CP_ON: 0000h to 07FFh code-protected
;_CP_OFF: Code protection off


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ERRORLEVEL 2

#define			CRISTAL_FREQ		16000000
#define			DS1820_PIN			PORTA,4
#define			TMR1_480us			.63616;(65536 - (480*CRISTAL_FREQ/4000000))
#define			TMR1_240us			.64576;(65536 - (240*CRISTAL_FREQ/4000000))
#define			TMR1_120us			.65056;(65536 - (120*CRISTAL_FREQ/4000000))
#define			TMR1_90us			.65176;(65536 - (90*CRISTAL_FREQ/4000000))
#define			TMR1_60us			.65296;(65536 - (60*CRISTAL_FREQ/4000000))
#define			Livre_1W			0x00
#define			Reset0_1W			0x01
#define			Reset1_1W			0x11
#define			Reset2_1W			0x21
#define			LerByte_1W			0x02
#define			EscreverByte_1W		0x03
#define			Bit_dip				VAR_BIT,0
#define			Bit_Buffer_1W		VAR_BIT,1
#define			Temp_DS18B20_L		ByteArray_1W
#define			Temp_DS18B20_H		ByteArray_1W+1

#define	LCD_RW	PORTB,5
#define	LCD_RS	PORTB,4
#define	LCD_E	PORTB,0

#define	LCD_D4	PORTA,0
#define	LCD_D5	PORTA,1
#define	LCD_D6	PORTA,2
#define	LCD_D7	PORTA,3

;Endereços DS18B20:
;
;28 15 60 97 03 00 00 3C
;28 6E 80 97 03 00 00 86


variable TEST1=TMR1_480us

messg "olá"


cblock 0x20
W_2			;Byte para o armazenamento temporário de W
STATUS_2	;Byte para o armazenamento temporário do STATUS
Estado_1W
delay1
delay2
delay3
delay1_Temp
delay2_Temp
delay3_Temp
VAR_BIT
Buffer_1W
Count_1W
EnderecoROM_L
EnderecoROM_H
Convert_hex_L
Convert_hex_H
Hex_byte
BytesParaLer_1W
Index_ByteArray
Temp_convertida_L
Temp_convertida_H
VAR_L	;Byte menos significativo do número a ser convertido
VAR_H	;Byte mais significativo do número a ser convertido
DSP1	;Dígito unidade
DSP2	;Dígito dezena
DSP3	;Dígito centena
DSP4	;Dígito unidade de milhar
DSP5	;Dígito dezena de milhar
byte
Nibble
Temp1
Cheksum_L
Cheksum_H
AuxiliarPacote
ByteArray_1W:9
Scratch_RAM_buffer:9
Pacote_Serial:8
endc



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
bcf		STATUS,RP0 			    ;Muda para o banco 2
bsf		STATUS,RP1				;
Endm							;
								;
BANK3 macro						;
bsf		STATUS,RP0  			;Muda para o banco 3
bsf		STATUS,RP1				;
Endm							;

Set_1W macro
BANK1
bsf		DS1820_PIN
BANK0
Endm

Clr_1W macro
BANK1
bcf		DS1820_PIN
BANK0
bcf		DS1820_PIN
Endm

Habilitar_contagem_TMR1 macro
bsf	T1CON,TMR1ON
Endm

Desabilitar_contagem_TMR1 macro
bcf	T1CON,TMR1ON
Endm

Ler_ROM macro Endereco_ROM
movlw	low(Endereco_ROM)
movwf	EnderecoROM_L
movlw	high(Endereco_ROM)
movwf	EnderecoROM_H
call	Ler_ROM_SBR
Endm



org 0x0000							;Vetor de RESET
	clrf	PCLATH					;Limpa o PCLATH
	goto	Main					;Vai para a rotina principal

ORG  0X0004							;Rotina da interrupção
	movwf	W_2						;Guarda o registrador W 
	movf	delay1,W
	movwf	delay1_Temp
	movf	delay2,W
	movwf	delay2_Temp
	movf	delay3,W
	movwf	delay3_Temp
	movf	STATUS, W				;
	BANK0
	movwf	STATUS_2				;Guarda o registrador STATUS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Testa qual interrupção ocorreu e desvia para sua respectiva rotina
	BANK0						;;
;	btfsc	INTCON,T0IF			;;
;	goto	TMR0_INT			;;
								;;
;	btfsc	INTCON,INTF			;;
;	goto	RB0_INT				;;
								;;
;	btfsc	INTCON,RBIF			;;
;	goto	PORTB_INT			;;
								;;
;	btfsc	PIR1,EEIF			;;
;	goto	EEPROM_INT			;;
								;;
;	btfsc	PIR1,CMIF			;;
;	goto	COMPARATOR_INT		;;
								;;
;	btfsc	PIR1,RCIF			;;
;	goto	RX_USART_INT		;;
								;;
;	btfsc	PIR1,TXIF			;;
;	goto	TX_USART_INT		;;
								;;
;	btfsc	PIR1,CCP1IF			;;
;	goto	CCP1_INT			;;
								;;
;	btfsc	PIR1,TMR2IF			;;
;	goto	TMR2_INT			;;
								;;
	btfsc	PIR1,TMR1IF			;;
	goto	TMR1_INT			;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Fim_INT:
	BANK0
	movf	STATUS_2,W				;Recupera o registrador STATUS
	movwf	STATUS					;
	movf	delay1_Temp,W
	movwf	delay1
	movf	delay2_Temp,W
	movwf	delay2
	movf	delay3_Temp,W
	movwf	delay3
	movf	W_2,W					;Recupera o registrador W
	retfie							;Termina a rotina da interrupção

TMR0_INT:							;Interrupção do timer 0
	bcf		INTCON,T0IF

	goto	Fim_INT

RB0_INT:							;Interrupção externa RB0
	bcf		INTCON,INTF

	goto	Fim_INT

PORTB_INT:							;Interrupção externa por mudança dos pinos RB4 a RB7
	bcf		INTCON,RBIF

	goto	Fim_INT

EEPROM_INT:							;Interrupção da gravação do memória eeprom interna
	bcf		PIR1,EEIF

	goto	Fim_INT

COMPARATOR_INT:						;Interrupção do módulo comparador
	bcf		PIR1,CMIF

	goto	Fim_INT

RX_USART_INT:						;Interrupção da USART por recepção de dados
	movf	RCREG,W

	goto	Fim_INT

TX_USART_INT:						;Interrupção da USART por envio de dados
	bcf		PIR1,TXIF

	goto	Fim_INT

CCP1_INT:							;Interrupção CCP (Capture Compare)
	bcf		PIR1,CCP1IF

	goto	Fim_INT

TMR2_INT:							;Interrupção do timer 2
	bcf		PIR1,TMR2IF

	goto	Fim_INT

TMR1_INT:							;Interrupção do timer 1
	bcf		PIR1,TMR1IF
	Desabilitar_contagem_TMR1
	movf	Estado_1W,W

	sublw	Reset0_1W
	btfss	STATUS,Z
	goto	FIM_Reset0_1W
	
	Set_1W
	movlw	low(TMR1_60us)
	movwf	TMR1L
	movlw	high(TMR1_60us)
	movwf	TMR1H
	movlw	Reset1_1W
	movwf	Estado_1W
	Habilitar_contagem_TMR1

	goto	Fim_INT
FIM_Reset0_1W:

	movf	Estado_1W,W
	sublw	Reset1_1W
	btfss	STATUS,Z
	goto	FIM_Reset1_1W

	bcf		Bit_dip
	btfss	DS1820_PIN
	bsf		Bit_dip

	movlw	low(TMR1_240us)
	movwf	TMR1L
	movlw	high(TMR1_240us)
	movwf	TMR1H
	movlw	Reset2_1W
	movwf	Estado_1W
	Habilitar_contagem_TMR1

	goto	Fim_INT
FIM_Reset1_1W:

	movf	Estado_1W,W
	sublw	Reset2_1W
	btfss	STATUS,Z
	goto	FIM_Reset2_1W

	movlw	Livre_1W
	movwf	Estado_1W
	goto	Fim_INT
FIM_Reset2_1W:


	movf	Estado_1W,W
	sublw	LerByte_1W
	btfss	STATUS,Z
	goto	FIM_LerByte_1W
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina para ler bytes 1-Wire (bit a bit)
LerByte_1W_INT:
	decfsz	Count_1W,F					;Decrementa o contador de bits
	goto	$+2							;
	goto	Fim_carregar_buffer			;Caso chegue a zero (
	movlw	low(TMR1_90us)
	movwf	TMR1L
	movlw	high(TMR1_90us)
	movwf	TMR1H

	bcf		STATUS,C
	rrf		Buffer_1W,F
	call	Ler_bit_1W
	bcf		Buffer_1W,7
	btfsc	Bit_Buffer_1W
	bsf		Buffer_1W,7
	Habilitar_contagem_TMR1
	goto	Fim_INT

Fim_carregar_buffer:
	movlw	ByteArray_1W
	addwf	Index_ByteArray,W
	movwf	FSR
	movf	Buffer_1W,W
	movwf	INDF
	incf	Index_ByteArray,F
	decfsz	BytesParaLer_1W,F
	goto	$+2
	goto	Fim_ler_bytes
	movlw	.9
	movwf	Count_1W
	goto	LerByte_1W_INT
Fim_ler_bytes:
	movlw	Livre_1W
	movwf	Estado_1W
	goto	Fim_INT
FIM_LerByte_1W:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movf	Estado_1W,W
	sublw	EscreverByte_1W
	btfss	STATUS,Z
	goto	FIM_EscreverByte_1W


	decfsz	Count_1W,F
	goto	$+2
	goto	Fim_esvaziar_buffer

	Set_1W

	movlw	low(TMR1_120us)
	movwf	TMR1L
	movlw	high(TMR1_120us)
	movwf	TMR1H

	Clr_1W

	btfss	Buffer_1W,0
	goto	Aqui_1
	Set_1W
Aqui_1:
	bcf		STATUS,C
	rrf		Buffer_1W,F
	Habilitar_contagem_TMR1
	goto	Fim_INT

Fim_esvaziar_buffer:
	Set_1W
	movlw	Livre_1W
	movwf	Estado_1W
	goto	Fim_INT
FIM_EscreverByte_1W:


	goto	Fim_INT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Fim do tratamento das interrupções, começo das constamtes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo da rotina princiapal.
Main
	BANK1							;Vai para o banco 1 de memória
	movlw	B'00100000'
	movwf	TXSTA				;Configura USART
								;Habilita TX
								;Modo assíncrono
								;Transmissão de 8 bits
								;High speed Baud Rate
	movlw	.207
	movwf	SPBRG				;Acerta Baud Rate -> 1200bps, Real: 1202bps

	BANK0
	movlw	0x07
	movwf	CMCON

	movlw	B'10010000'
	movwf	RCSTA				;Habilita RX
	bcf		PORTB,7

	movlw	B'00001100'
	movwf	T1CON

	clrf	PIR1

	movlw	B'11000000'
	movwf	INTCON

	BANKSEL	PIE1
	movlw	B'00000001'
	movwf	PIE1
	BANK0

	call	Delay_200ms
	call	Init_LCD


	call	Reset_1W
	call	Aguardar_1W

	movlw	'T'
	call	Enviar_byte_rs232
	movlw	'e'
	call	Enviar_byte_rs232
	movlw	'm'
	call	Enviar_byte_rs232
	movlw	'p'
	call	Enviar_byte_rs232
	movlw	'e'
	call	Enviar_byte_rs232
	movlw	'r'
	call	Enviar_byte_rs232
	movlw	'a'
	call	Enviar_byte_rs232
	movlw	't'
	call	Enviar_byte_rs232
	movlw	'u'
	call	Enviar_byte_rs232
	movlw	'r'
	call	Enviar_byte_rs232
	movlw	'a'
	call	Enviar_byte_rs232
	movlw	0x0D
	call	Enviar_byte_rs232

Loop:
	call	Reset_1W
	call	Aguardar_1W

	movlw	0xCC
	call	Enviar_byte_1W
	call	Aguardar_1W

	movlw	0x44
	call	Enviar_byte_1W
	call	Aguardar_1W

	call	Linha_1_LCD

	call	Delay_1S

	call	Reset_1W
	call	Aguardar_1W

	movlw	0xCC
	call	Enviar_byte_1W
	call	Aguardar_1W

	movlw	0xBE
	call	Enviar_byte_1W
	call	Aguardar_1W

	movlw	.9
	movwf	BytesParaLer_1W
	call	Ler_bytes_1W
	call	Aguardar_1W
	
	movlw	' '
	movwf	Pacote_Serial

	btfss	Temp_DS18B20_H,7
	goto	TempPositiva
	comf	Temp_DS18B20_L,F
	comf	Temp_DS18B20_H,F
	movlw	.1
	addwf	Temp_DS18B20_L,F
	btfsc	STATUS,C
	incf	Temp_DS18B20_H,F
	movlw	'-'
	movwf	Pacote_Serial
	call	Enviar_char_lcd
TempPositiva:
	movf	Temp_DS18B20_L,W
	movwf	Temp_convertida_L
	movf	Temp_DS18B20_H,W
	movwf	Temp_convertida_H

	bcf		STATUS,C
	rlf		Temp_convertida_L,F
	rlf		Temp_convertida_H,F
	bcf		STATUS,C
	rlf		Temp_convertida_L,F
	rlf		Temp_convertida_H,F
	movf	Temp_DS18B20_L,W
	addwf	Temp_convertida_L,F
	btfsc	STATUS,C
	incf	Temp_convertida_H,F
	movf	Temp_DS18B20_H,W
	addwf	Temp_convertida_H,F
	bcf		STATUS,C
	rrf		Temp_convertida_H,F
	rrf		Temp_convertida_L,F
	bcf		STATUS,C
	rrf		Temp_convertida_H,F
	rrf		Temp_convertida_L,F
	bcf		STATUS,C
	rrf		Temp_convertida_H,F
	rrf		Temp_convertida_L,F
	movf	Temp_convertida_L,W
	movwf	VAR_L
	movf	Temp_convertida_H,W
	movwf	VAR_H
	call	Converter_Bin_Dec_16bit
	movf	DSP3,W
	movwf	Pacote_Serial+1
	call	Enviar_char_lcd
	movf	DSP2,W
	movwf	Pacote_Serial+2
	call	Enviar_char_lcd
	movlw	','
	movwf	Pacote_Serial+3
	call	Enviar_char_lcd
	movf	DSP1,W
	movwf	Pacote_Serial+4
	call	Enviar_char_lcd
	movlw	0xC2
	movwf	Pacote_Serial+5
	movlw	'º'
	movwf	Pacote_Serial+6
	movlw	0xDF
	call	Enviar_char_lcd
	movlw	'C'
	movwf	Pacote_Serial+7
	call	Enviar_char_lcd

	movlw	' '
	call	Enviar_char_lcd
	call	EnviarPacoteSerial
	call	EnviarPacoteSerial
	call	EnviarPacoteSerial
	call	EnviarPacoteSerial

;	btfss	PIR1 , RCIF					;Aguarda o recebimento de um caracter 
;	goto	$-1							;
;	movf	RCREG,W
;	sublw	'T'
;	btfss	STATUS,Z
	goto	Loop
;	goto	Init_Temp


sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas
EnviarPacoteSerial:
	movlw	0xAA
	call	Enviar_byte_rs232
	movlw	0xAA
	call	Enviar_byte_rs232
	movlw	0xAA
	call	Enviar_byte_rs232
	movlw	0xAA
	call	Enviar_byte_rs232
	movlw	0xAA
	call	Enviar_byte_rs232

	clrf	Cheksum_L
	clrf	Cheksum_H

	movlw	Pacote_Serial
	movwf	FSR

Codificar_Pacote:
	movlw	Pacote_Serial+8
	subwf	FSR,W
	btfsc	STATUS,C
	goto	Fim_Codificar_Pacote
	
	movf	INDF,W
	movwf	AuxiliarPacote
	addwf	Cheksum_L,F
	btfsc	STATUS,C
	incf	Cheksum_H,F

	swapf	AuxiliarPacote,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232

	movf	AuxiliarPacote,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232
	incf	FSR,F
	goto	Codificar_Pacote
Fim_Codificar_Pacote:

	swapf	Cheksum_H,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232

	movf	Cheksum_H,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232

	swapf	Cheksum_L,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232

	movf	Cheksum_L,W
	andlw	0x0F
	iorlw	0x50
	call	Enviar_byte_rs232
	
	return

Convert_nibble_hex:
	movlw	high(Convert_nibble_hex)
    movwf	PCLATH
	movf	Hex_byte,W
	andlw	0x0F
	addwf	PCL,F
	retlw	'0'
	retlw	'1'
	retlw	'2'
	retlw	'3'
	retlw	'4'
	retlw	'5'
	retlw	'6'
	retlw	'7'
	retlw	'8'
	retlw	'9'
	retlw	'A'
	retlw	'B'
	retlw	'C'
	retlw	'D'
	retlw	'E'
	retlw	'F'

Convert_byte_hex:
	movwf	Hex_byte
	call	Convert_nibble_hex
	movwf	Convert_hex_L
	swapf	Hex_byte,F
	call	Convert_nibble_hex
	movwf	Convert_hex_H
	return

Ler_ROM_SBR:
    movf	EnderecoROM_H,W
    movwf	PCLATH
    movf	EnderecoROM_L,W
    movwf   PCL

Enviar_byte_rs232:
	BANKSEL	TXSTA				; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return

Reset_1W:
	movlw	low(TMR1_480us)
	movwf	TMR1L
	movlw	high(TMR1_480us)
	movwf	TMR1H
	movlw	Reset0_1W
	movwf	Estado_1W
	Clr_1W
	Habilitar_contagem_TMR1
	return

Aguardar_1W:
	movf	Estado_1W,W
	sublw	Livre_1W
	btfss	STATUS,Z
	goto	$-3
	return

Ler_bit_1W:
	Clr_1W
	nop
	nop
	nop
	nop
	nop
	Set_1W
	call	Delay_15us
	bcf		Bit_Buffer_1W
	btfsc	DS1820_PIN
	bsf		Bit_Buffer_1W	
	return

Ler_bytes_1W:
	movlw	0xFA
	movwf	TMR1L
	movlw	0xFF
	movwf	TMR1H
	movlw	LerByte_1W
	movwf	Estado_1W
	movlw	.9
	movwf	Count_1W
	clrf	Index_ByteArray
	Habilitar_contagem_TMR1
	return

Enviar_byte_1W:
	movwf	Buffer_1W
	movlw	0xFA
	movwf	TMR1L
	movlw	0xFF
	movwf	TMR1H
	movlw	EscreverByte_1W
	movwf	Estado_1W
	movlw	.9
	movwf	Count_1W
	Habilitar_contagem_TMR1
	return


Enviar_byte_1W_teste:
	movwf	Buffer_1W
	movlw	.9
	movwf	Count_1W

Aqui_3:
	decfsz	Count_1W,F
	goto	$+2
	return

	Clr_1W
	nop
	nop
	nop
	nop
	nop
	btfss	Buffer_1W,0
	goto	Aqui_2
	Set_1W
Aqui_2:
	bcf		STATUS,C
	rrf		Buffer_1W,F
	call	Delay_120us
	Set_1W
	goto	Aqui_3

	return

Converter_Bin_Dec_16bit:
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
Init_LCD
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK1
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
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
;	DESATIVAR_INT
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd
;	ATIVAR_INT
	return						;Retorna da sub-rotina

Enviar_nibble_lcd
	movwf	Nibble
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	btfsc	Nibble,0
	bsf		LCD_D4
	btfsc	Nibble,1
	bsf		LCD_D5
	btfsc	Nibble,2
	bsf		LCD_D6
	btfsc	Nibble,3
	bsf		LCD_D7	
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
;	DESATIVAR_INT
	clrf	byte
	BANK1
	bsf		LCD_D4
	bsf		LCD_D5
	bsf		LCD_D6
	bsf		LCD_D7
	BANK0
	bsf		LCD_RW
	nop
	nop
	bsf		LCD_E
	nop
	nop	
	btfsc	LCD_D4
	bsf		byte,4
	btfsc	LCD_D5
	bsf		byte,5
	btfsc	LCD_D6
	bsf		byte,6
	btfsc	LCD_D7
	bsf		byte,7

	bcf		LCD_E
	nop
	nop
	swapf	byte, F
	bsf		LCD_E
	nop
	nop
	
	btfsc	LCD_D4
	bsf		byte,0
	btfsc	LCD_D5
	bsf		byte,1
	btfsc	LCD_D6
	bsf		byte,2
	btfsc	LCD_D7
	bsf		byte,3

	bcf		LCD_E
	bcf		LCD_RW
	BANK1
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK0
	movfw	byte
;	ATIVAR_INT
	return

Aguardar_BF_LCD					;Sub-rotina para esperar o display LCD ficar desocupado
	call	Ler_byte_LCD
	btfsc	byte, 7
	goto	Aguardar_BF_LCD
	return


Delay_15us:
			;55 cycles
	movlw	0x12
	movwf	delay1
Delay_15us_0
	decfsz	delay1, f
	goto	Delay_15us_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

Delay_120us:
			;475 cycles
	movlw	0x9E
	movwf	delay1
Delay_120us_0
	decfsz	delay1, f
	goto	Delay_120us_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

Delay_5mS:
			;19993 cycles
	movlw	0x9E
	movwf	delay1
	movlw	0x10
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



Delay_200ms:
			;799993 cycles
	movlw	0x6C
	movwf	delay1
	movlw	0xBF
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

Delay_1S:
			;3999994 cycles
	movlw	0x23
	movwf	delay1
	movlw	0xB9
	movwf	delay2
	movlw	0x09
	movwf	delay3
Delay_1S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_1S_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


END