;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;												;;
;;												;;
;;Data: 06/04/2010								;;
;;												;;
;;PIC 16F877									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF

cblock	0x20
Cont1							;Define as constantes de endereço
Status_SPI
byte
nibble
DSP1
DSP2
DSP3
DSP4
DSP5
VAR_L
VAR_H
delay1
delay2
delay3
Temp_L
Temp_H

endc

;Definição de constantes

#Define CS PORTE,2

#define	Porta_LCD	PORTB
#define	E			Porta_LCD,2
#define	RS			Porta_LCD,3

E_1	macro
bsf	E
Endm

E_0	macro
bcf	E
Endm

RS_1 macro
bsf	RS
Endm

RS_0 macro
bcf	RS
Endm


;Definições de comandos para a memória


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
BANK2 macro						;
bcf		STATUS,RP0				;
bsf		STATUS,RP1 			    ;Muda para o banco 2
Endm							;
								;
BANK1 macro						;
bsf		STATUS,RP0 			    ;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK0 macro						;
bcf		STATUS,RP0  			    ;Volta ao banco 0
bcf		STATUS,RP1				;
Endm							;
								;
								;
ORG  0X0000						;
Main							;Rotina principal=
	clrf	PORTB				;Limpa a porta B
	clrf	PORTC				;Limpa a porta C	
	clrf	PORTD				;Limpa a porta D
	clrf	PORTE				;Limpa a porta E	  
	BANK1						;Vai para o banco 1 da memória
	clrf	TRISB
	BANK0						;vai para o banco 0 da memória
	call	Delay_200ms
	call	Inicializar_SPI
	call	Lcd_Init


Teste_leitura

	call	Ler_Temperatura


	movf	Temp_H, W
	movwf	VAR_H

	movf	Temp_L, W
	movwf	VAR_L

	call	Converter_Bin_Dec_16bit

	movf	DSP4, W
	call	Enviar_char_lcd

	movf	DSP3, W
	call	Enviar_char_lcd

	movf	DSP2, W
	call	Enviar_char_lcd

	movf	DSP1, W
	call	Enviar_char_lcd

	call	Delay_200ms

	clrw
	call	Lcd_Posicao



goto	Teste_leitura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Inicializar_SPI
	BANK1
	movlw	b'11010111'
	movwf	TRISC
	movlw	b'10000000'
	movwf	SSPSTAT
	bcf		TRISE,2
	BANK0
	bsf		CS
	movlw	b'00110000'
	movwf	SSPCON
	clrw
	return

Ler_byte_SPI
	clrf	SSPBUF
	call	Aguardar_buffer_SPI
	movf	SSPBUF,W
	return

Aguardar_buffer_SPI
	BANKSEL SSPSTAT
	LOOP_
	btfss	SSPSTAT, BF
	goto	LOOP_
	BANK0
	return

Ler_Temperatura
	bcf		CS
	call	Ler_byte_SPI
	movwf	Temp_H

	call	Ler_byte_SPI
	movwf	Temp_L
	bsf		CS

	bcf		Temp_H, 7

	rrf		Temp_H, F
	rrf		Temp_L, F
	bcf		STATUS, C

	rrf		Temp_H, F
	rrf		Temp_L, F
	bcf		STATUS, C

	rrf		Temp_H, F
	rrf		Temp_L, F
	bcf		STATUS, C

	rrf		Temp_H, F
	rrf		Temp_L, F
	bcf		STATUS, C

	rrf		Temp_H, F
	rrf		Temp_L, F
	bcf		STATUS, C
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

Lcd_Init	
	clrf	Porta_LCD
	BANK1
	clrf	Porta_LCD
	BANK0
	movlw	B'00000011'
	call	Lcd_Enviar_Nibble
	call	Delay_5ms
	movlw	B'00000011'
	call	Lcd_Enviar_Nibble
	call	Delay_5ms
	movlw	B'00000011'
	call	Lcd_Enviar_Nibble
	call	Delay_5ms
	movlw	B'00000010'
	call	Lcd_Enviar_Nibble
	call	Delay_2ms
	movlw	0x28
	call	Lcd_Enviar_Byte
	call	Delay_40us
	movlw	0x0C
	call	Lcd_Enviar_Byte
	call	Delay_40us
	call	Lcd_Limpar
	movlw	0x06
	call	Lcd_Enviar_Byte
	call	Delay_40us
	return

Lcd_Limpar												;Limpa o display LCD 
	movlw	0x01
	call	Lcd_Enviar_Byte
	call	Delay_2ms
	return

Lcd_Posicao:
	iorlw	0x80
	call	Lcd_Enviar_Byte
	call	Delay_40us
	return


Lcd_Enviar_Nibble									;Envia um nibble para o display LCD
	movwf	nibble													;Cosidera apenas o nibble inferior do acumulador 
	E_0
	movlw	b'00001111'
	andwf	nibble, F
	swapf	nibble, F
	movlw	b'00001111'
	andwf	Porta_LCD, F
	movf	nibble, W
	iorwf	Porta_LCD
	E_1
	E_0
	return


Lcd_Enviar_Byte										;Envia um byte para o display LCD
	movwf	byte
	swapf	byte, W
	call	Lcd_Enviar_Nibble
	movf	byte, W
	call	Lcd_Enviar_Nibble
	return

Enviar_char_lcd										;Envia um caracter para o display LCD
	RS_1
	call	Lcd_Enviar_Byte
	RS_0
	call	Delay_40us
	return

								;
								;

Linha_1_LCD
	movlw	b'10000000'
	call	Lcd_Enviar_Byte		;Envia o comando
	call	Delay_40us			;
	return	

Linha_2_LCD
	movlw	b'11000000'
	call	Lcd_Enviar_Byte		;Envia o comando
	call	Delay_40us			;
	return

Delay_40us
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


Delay_2ms
			;1993 cycles
	movlw	0x8E
	movwf	delay1
	movlw	0x02
	movwf	delay2
Delay_2mS_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_2mS_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

Delay_5ms
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


								;
END								;Fim do programa
