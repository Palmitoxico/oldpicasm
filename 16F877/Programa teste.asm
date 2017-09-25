processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


cblock 0x20						;Definições de variáveis
Multiplicador_L
Multiplicador_H
Multiplicando_L
Multiplicando_H
Resultado_L
Resultado_H
byte
Nibble
delay1
delay2
delay3
VAR_L
VAR_H
DSP1
DSP2
DSP3
DSP4
DSP5
Contador_L
Contador_H
Base_Index_L
Base_Index_H
Temp1
endc

#define		Divisor_L	Multiplicador_L
#define		Divisor_H	Multiplicador_H
#define		Dividendo_L	Multiplicando_L
#define		Dividendo_H	Multiplicando_H

#define	LCD_RS	PORTB,2
#define	LCD_RW	PORTB,1
#define	LCD_E	PORTB,3



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

Main
	clrf   PORTB			   ;Limpa as portas B, C, D e E
	clrf   PORTC
	clrf   PORTD
	clrf   PORTE			  
	BANK1
	clrf   TRISB			   ;Toda a porta B como saída
	clrf   TRISC			   ;Toda a porta C como saída
	clrf   TRISD			   ;Toda a porta D como saída
	clrf   TRISE			   ;Toda a porta E como saída
	BANK0
	call	Delay_200ms
	call	Init_LCD

	movlw	low(.100)
	movwf	Dividendo_L

	movlw	high(.100)
	movwf	Dividendo_H

	movlw	low(.17)
	movwf	Divisor_L

	movlw	high(.17)
	movwf	Divisor_H

	call	MULV16 

	movf	Resultado_L,W
	movwf	VAR_L
	movf	Resultado_H,W
	movwf	VAR_H

	call	Converter_Bin_Dec_16bit

	movf	DSP5,W
	call	Enviar_char_lcd

	movf	DSP4,W
	call	Enviar_char_lcd

	movf	DSP3,W
	call	Enviar_char_lcd

	movf	DSP2,W
	call	Enviar_char_lcd

	movf	DSP1,W
	call	Enviar_char_lcd


	sleep

								;Começo das sub-rotinas:

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

DIVV16
	movf	Divisor_L,F
	btfss 	STATUS,Z
	goto	ZERO_TEST_SKIPPED
	movf	Divisor_H,F
	btfsc	STATUS,Z
return

ZERO_TEST_SKIPPED
	movlw   1
	movwf   Base_Index_L
	clrf    Base_Index_H
	clrf    Resultado_L
	clrf    Resultado_H

SHIFT_IT16
	btfsc   Divisor_H,7
	goto 	DIVU16LOOP
	bcf     STATUS,C
  	rlf     Base_Index_L,F
  	rlf     Base_Index_H,F
  	bcf     STATUS,C
  	rlf     Divisor_L,F
  	rlf     Divisor_H,F
  	goto    SHIFT_IT16

DIVU16LOOP
	call    SUB16
	btfsc   STATUS,C
	goto    COUNTX
	call    ADD16BIS
	goto    FINALX
COUNTX
	movf    Base_Index_L,W
	addwf   Resultado_L
	btfsc   STATUS,C
	incf    Resultado_H,F
	movf    Base_Index_H,W
	addwf   Resultado_H
FINALX
	bcf     STATUS,C
	rrf     Divisor_H,F
	rrf     Divisor_L,F
	bcf     STATUS,C
	rrf     Base_Index_H,F
	rrf     Base_Index_L,F
	btfss   STATUS,C
	goto    DIVU16LOOP
return

SUB16
	movf    Divisor_H,W
	movwf   Temp1
	movf    Divisor_L,W
	subwf   Dividendo_L
	btfss   STATUS,C
	incf    Temp1,F
	movf    Temp1,W
	subwf   Dividendo_H
return

ADD16BIS
	movf    Divisor_L,W
	addwf   Dividendo_L
	btfsc   STATUS,C
	incf    Dividendo_H,F
	movf    Divisor_H,W
	addwf   Dividendo_H
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
	Limpar_LCD					;
	movlw	b'00000001'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_5mS			;	
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

END