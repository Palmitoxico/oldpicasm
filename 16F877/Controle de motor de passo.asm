processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF


org 0x0000
cblock 0x20
Dado
DSP1
DSP2
DSP3
Resultado
Cont1
Cont2
Cont3
byte
delay1
delay2
delay3
Cont_T
Motor_cont
W_2
STATUS_2
Div_L
Div_H
Resul_L
Resul_H
Timer_Extra_Byte
EnderecoStr_L
EnderecoStr_H
Nibble
Temp1
OffSet_Str_H
OffSet_Str_L
S_Char
endc

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

#define	LCD_D4	PORTB,4
#define	LCD_D5	PORTB,5
#define	LCD_D6	PORTB,6
#define	LCD_D7	PORTB,7

#define	TTIMER	.6000




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
								;

ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0X0004						;Rotina da interrupção
movlw	W_2
movf	STATUS,W
movwf	STATUS_2
;decfsz	Cont_T , F
;goto	INT_FIM
;movf	Timer_Extra_Byte,W
;movwf	Cont_T					;

incf	Motor_cont,F			;

movf	Motor_cont , W
sublw	.4
btfss	STATUS , Z
goto	$+2
clrf	Motor_cont

movf	Motor_cont , W
btfss	STATUS , Z
goto	$+3
movlw	b'1001'
movwf	PORTC

movf	Motor_cont , W
sublw	.1
btfss	STATUS , Z
goto	$+3
movlw	b'1100'
movwf	PORTC

movf	Motor_cont , W
sublw	.2
btfss	STATUS , Z
goto	$+3
movlw	b'0110'
movwf	PORTC

movf	Motor_cont , W
sublw	.3
btfss	STATUS , Z
goto	$+3
movlw	b'0011'
movwf	PORTC


								;
INT_FIM							;
movlw	high(.65536 - TTIMER)	;
movwf	TMR1H					;Carrega o byte mais significativo do contador do timer 1

movlw	low(.65536 - TTIMER)	;Carrega o byte menos significativo do contador do timer 1
movwf	TMR1L					;
movf	STATUS_2,W
movwf	STATUS
movf	W_2
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STR1:
DT "Motor de passo/2GOSTOSO",0

Main

;	movlw	.3					;
;	movwf	Cont_T				;
	clrf	Timer_Extra_Byte
	clrf	PORTB
	clrf	PORTE

	BANK1
	bcf		OPTION_REG , 7	 	;
	movlw	b'01001110'
	movwf	ADCON1
	clrf	TRISB
	clrf	TRISE
	movlw	b'11110000'
	movwf	TRISC
	BANK0						; SELECIONA BANCO 0 DA RAM
	movlw	b'11000000'			;
	movwf	INTCON				;
								;
	movlw	b'00000001'			;
	movwf	T1CON				;
	movlw	high(.65536 - TTIMER);
	movwf	TMR1H				;Carrega o byte mais significativo do contador do timer 1
								;
	movlw	low(.65536 - TTIMER)	;Carrega o byte menos significativo do contador do timer 1
	movwf	TMR1L				;
	call	Delay_200ms
	call	Init_LCD

	movlw	Low(STR1)
	movwf	OffSet_Str_L
	movlw	High(STR1)
	movwf	OffSet_Str_H
	call	Enviar_String

	BANK1
	bsf		PIE1 , 0
	BANK0
Rotina_Motor

	btfss	PORTC,7
	goto	Motor_desligado
	goto	Motor_ligado

Motor_desligado:
	bcf		T1CON,0
	movlw	b'1111'
	movwf	PORTC
	goto	Rotina_Motor
Motor_ligado:
	bsf		T1CON,0
	goto	Rotina_Motor

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
	call	Delay_5ms			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5ms			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5ms			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5ms			;
	movlw	0x02
	call	Enviar_nibble_lcd
	call	Delay_5ms			;
	movlw	0x28
	call	Enviar_byte_lcd
	call	Delay_5ms			;
	movlw	0x0c
	call	Enviar_byte_lcd
	call	Delay_5ms			;
	movlw	b'00000001'
	call	Enviar_byte_lcd
	call	Delay_5ms			;
	movlw	0x06
	call	Enviar_byte_lcd
	call	Delay_5ms		;
	return

Enviar_byte_lcd					;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd
	return						;Retorna da sub-rotina

Ler_Str_Tabela:
	movfw	OffSet_Str_H
    addwf	EnderecoStr_H,W
    movwf	PCLATH
	movfw	OffSet_Str_L
    addwf	EnderecoStr_L,W
    skpnc
    incf	PCLATH,F
    movwf   PCL

Enviar_String:
	clrf	EnderecoStr_H
	clrf	EnderecoStr_L
Ler_Str:
	call	Ler_Str_Tabela
	movwf	S_Char
	movf	S_Char,F
	btfsc	STATUS,Z
	goto	Fim_Enviar_String

	sublw	'/'
	btfss	STATUS,Z
	goto	EnviarChar1

	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F

	call	Ler_Str_Tabela
	PAGESEL	Enviar_String
	movwf	S_Char
	movf	S_Char,W
	btfsc	STATUS,Z
	goto	Fim_Enviar_String

	movf	S_Char,W
	sublw	'/'
	btfss	STATUS,Z
	goto	FimChar_barra
	movlw	'/'
	call	Enviar_char_lcd
FimChar_barra

	movf	S_Char,W
	sublw	'L'
	btfss	STATUS,Z
	goto	FimChar_limpar
	call	Limpar_LCD
FimChar_limpar

	movf	S_Char,W
	sublw	'1'
	btfss	STATUS,Z
	goto	FimChar_linha1
	call	Linha_1_LCD
FimChar_linha1

	movf	S_Char,W
	sublw	'2'
	btfss	STATUS,Z
	goto	FimChar_linha2
	call	Linha_2_LCD
FimChar_linha2


	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F

	goto	Ler_Str
EnviarChar1
	movf	S_Char,W
	call	Enviar_char_lcd
	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F
	goto	Ler_Str
Fim_Enviar_String
	return

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
	return

Aguardar_BF_LCD					;Sub-rotina para esperar o display LCD ficar desocupado
	call	Ler_byte_LCD
	btfsc	byte, 7
	goto	Aguardar_BF_LCD
	return


Delay_5ms
			;9993 cycles
	movlw	0xCE
	movwf	delay1
	movlw	0x08
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