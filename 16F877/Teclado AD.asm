processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


org 0x0000
Dado		EQU 0x20
DSP1		EQU 0x21
DSP2		EQU 0x22
DSP3		EQU 0x23
Resultado	EQU 0x24
Cont1		EQU 0x25
Cont2		EQU 0x26
Cont3		EQU 0x27
byte		EQU 0x28
delay1		EQU 0x29
delay2		EQU 0x2A
delay3		EQU 0x2B





org 0x0000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
BANK1 macro						;
bsf    STATUS,RP0 			    ;Muda para o banco 1
Endm							;
								;
BANK0 macro						;
bcf   STATUS,RP0  			    ;Volta ao banco 0
Endm							;
								;
E_1 macro						;Coloca o pino enable em 1
movlw	b'100'					;
iorwf	PORTE					;
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
movlw	b'011'					;
andwf	PORTE
Endm							;
								;
RS_1 macro						;Coloca o pino RS em 1
movlw	b'001'					;
iorwf	PORTE					;
Endm							;
								;
RS_0 macro						;Coloca o pino RS em 0
movlw	b'110'					;
andwf	PORTE					;
Endm							;
								;
RW_1 macro						;Coloca o pino RW em 1
movlw	b'010'					;
iorwf	PORTE					;
Endm							;
								;
RW_0 macro						;Coloca o pino RW em 0
movlw	b'101'					;
andwf	PORTE					;
Endm							;
								;
PORTB_E macro					;Configura como entrada a porta B
BANK1							;
movlw	0xFF					;
movwf	TRISB					;
BANK0							;
Endm							;
								;
PORTB_S macro					;Configura como saida o nibble alto da porta B
BANK1							;
clrf  TRISB						;
BANK0							;
Endm							;
								;



Main

	clrf	PORTB
	clrf	PORTE

	movlw	b'11000001'
	movwf	ADCON0

	BANK1
	movlw	b'01001110'
	movwf	ADCON1
	clrf	TRISB
	clrf	TRISE
	
	BANK0					; SELECIONA BANCO 0 DA RAM
	call	Delay_0S5
	call	Init_LCD


	movlw	'V'
	call	enviar_char_lcd


	movlw	'a'
	call	enviar_char_lcd

	movlw	'l'
	call	enviar_char_lcd

	movlw	'o'
	call	enviar_char_lcd

	movlw	'r'
	call	enviar_char_lcd

	movlw	' '
	call	enviar_char_lcd

	movlw	'd'
	call	enviar_char_lcd

	movlw	'a'
	call	enviar_char_lcd



	call	Linha_2_LCD


	movlw	't'
	call	enviar_char_lcd

	movlw	'e'
	call	enviar_char_lcd


	movlw	'c'
	call	enviar_char_lcd

	movlw	'l'
	call	enviar_char_lcd

	movlw	'a'
	call	enviar_char_lcd

	movlw	':'
	call	enviar_char_lcd


	Inicio_AD
	bsf		ADCON0,2
	btfsc	ADCON0,2
	goto	$-1

	movlw	.70
	call	Endereco_LCD


	movf	ADRESL , 0
	movwf	Dado
	call	Converter
	
	movlw	0x30
	addwf	DSP1 , 0	
	call	enviar_char_lcd

	movlw	0x30
	addwf	DSP2 , 0	
	call	enviar_char_lcd

	movlw	0x30
	addwf	DSP3 , 0	
	call	enviar_char_lcd

	goto 	Inicio_AD




	Converter
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP1 , 1
	goto	$-4
	movlw	.100
	addwf	Dado , 1
	movlw	.10
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	Dado , 0
	movwf	DSP3
	return

	Limpar_LCD					;
	call	Ler_BF
	movlw	b'00000001'
	call	enviar_byte_lcd		;Envia o comando	
	return

	Init_LCD
	E_0
	movlw	0x38				;Inicialização do display lcd
	call	enviar_byte_lcd		;Configuraçao: 2 linhas, 8 bits
	call	Delay_40uS			;
	movlw	0x0C				;
	call	enviar_byte_lcd		;
	call	Delay_40uS			;
	call	Limpar_LCD			;Limpa o display
	return

	enviar_byte_lcd				;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	movf	byte,0
	movwf	PORTB				;Coloca o dado na porta B
	E_1							;Coloca o pino enable em 0
	E_0							;Volta o pino enable em 1
	return						;Retorna da sub-rotina

	enviar_char_lcd				;Sub-rotina para enviar um caracter para o display lcd
	movwf	byte				;
	call	Ler_BF				;
	RS_1
	movf	byte , 0
	movwf	PORTB				;Coloca o dado na porta B
	E_1	
	E_0							;Coloca o pino enable em 0							;Volta o pino enable em 1
	RS_0
	return						;Retorna da sub-rotina
								;
								;
	Endereco_LCD
	iorlw	b'10000000'
	movwf	byte
	call	Ler_BF				;
	movf	byte,0
	call	enviar_byte_lcd		;Envia o comando

	return

	Linha_1_LCD
	call	Ler_BF				;
	movlw	b'10000000'
	call	enviar_byte_lcd		;Envia o comando
	return	

	Linha_2_LCD
	call	Ler_BF				;
	movlw	b'11000000'
	call	enviar_byte_lcd		;Envia o comando
	return

Ler_BF
	PORTB_E
	RW_1
	E_1

	btfss	PORTB,7
	goto	Fim_bf
	E_0

	goto	Ler_BF
Fim_bf
	RW_0
	PORTB_S
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


Delay_2mS
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

Delay_0S5
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_0S5_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_0S5_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return

								;


END