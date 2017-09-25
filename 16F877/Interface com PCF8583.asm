;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Interface com PCF8583                			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;                               				;;
;;                        						;;
;;												;;
;;                    							;;
;;												;;
;;Data: 28/04/2011  							;;
;;												;;
;;PIC 16F877									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _XT_OSC


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
endc


#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

#Define Endereco_RTC_escrita b'10100000'
#Define Endereco_RTC_leitura b'10100001'

#Define Endereco_Segundos_RTC		0x02
#Define Endereco_Minutos_RTC		0x03
#Define Endereco_Horas_RTC			0x04


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
								;Definição de macro-comandos					;


Main
movlw	b'00101000'
movwf	SSPCON
clrf	PORTB				;Limpa a porta B	
clrf	PORTE				;Limpa a porta E

BANK1						;Vai para o banco 1 da memória
clrf	TRISB				;Toda a porta B como saída
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

call	Limpar_LCD


btfss	PORTD,2
goto	Loop

movlw	Endereco_Horas_RTC
movwf	Endereco_RTC
movlw	0x19
call	Gravar_RTC

movlw	Endereco_Minutos_RTC
movwf	Endereco_RTC
movlw	0x50
call	Gravar_RTC

movlw	Endereco_Segundos_RTC
movwf	Endereco_RTC
movlw	0x56
call	Gravar_RTC
Loop:	
	movlw	Endereco_Horas_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	call	Converter_BCD_CHAR
	movlw	':'
	call	Enviar_char_lcd
	movlw	Endereco_Minutos_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	call	Converter_BCD_CHAR
	movlw	':'
	call	Enviar_char_lcd
	movlw	Endereco_Segundos_RTC
	movwf	Endereco_RTC
	call	Ler_RTC
	call	Converter_BCD_CHAR
	clrw
	call	Endereco_LCD
	goto	Loop
	sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Começo das sub-rotinas:



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

Enviar_byte_lcd					;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd

	return						;Retorna da sub-rotina

Enviar_nibble_lcd
	movwf	Nibble
	movlw	b'00001111'
	andwf	PORTB
	andwf	Nibble
	swapf	Nibble,0
	iorwf	PORTB
	bcf		LCD_E				;Coloca o pino enable em 0
	nop
	nop
	bsf		LCD_E				;Volta o pino enable em 1	
	return

Enviar_char_lcd					;Sub-rotina para enviar um caracter para o display lcd
	bsf		LCD_RS
	call	Enviar_byte_lcd
	bcf		LCD_RS
	call	Delay_40uS			;
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
	movf	Valor,W
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



END