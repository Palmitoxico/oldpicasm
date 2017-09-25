;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Reator pós coluna 3.0                         ;;
;;Versão do programa: 3.0                       ;;
;;Versão do hardware: 3.0                       ;;
;;Desenvolvido por Augusto Fraga Giachero       ;;
;;Cristal 20MHz                                 ;;
;;                                              ;;
;;                                              ;;
;;Data de início: 28/09/2012                    ;;
;;Data da última atualização: 30/03/2013        ;;
;;                                              ;;
;;                                              ;;
;;PIC 16F887                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	list		p=16f887	; list directive to define processor
	#include	<p16f887.inc>	; processor specific variable definitions


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

	__CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _HS_OSC
	__CONFIG    _CONFIG2, _WRT_OFF & _BOR21V

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Macro comandos
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
								;
DESATIVAR_INT macro				;Desativa a chave geral de interrupções
bcf		INTCON,GIE				;
Endm							;
								;
ATIVAR_INT macro				;Ativa a chave geral de interrupções
bsf		INTCON,GIE				;
Endm							;
								;
Delay_5us macro					;
movlw	0x08					;
movwf	delay1					;
decfsz	delay1, f				;
goto	$-1						;
endm							;
								;
Escrever_LCD macro MSTR			;
movlw	Low(MSTR)				;
movwf	EnderecoStr_L			;
movlw	High(MSTR)				;
movwf	EnderecoStr_H			;
call	Enviar_String			;
endm 							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D		; variable used for context saving
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving

cblock	0x20
byte
Nibble
delay1
delay2
delay3
Temp1
EnderecoStr_L
EnderecoStr_H
S_Char
TMR1H_RE
TMR1L_RE
Motor_Turbo
Motor_cont
ADC_POINT
Temperatura
Dado
DSP1
DSP2
DSP3
Potencia_RES
Potencia_COUNTER
Temperatura_definida
Tempo_varredura
VAR_BIT
Divisor_L
Divisor_H
Dividendo_L
Dividendo_H
Resultado_L
Resultado_H
Base_Index_L
Base_Index_H
Temp_ROT_L
Temp_ROT_H
Count_Temp_ROT_L
Count_Temp_ROT_H
Fluxo
Count_AT
endc

#define	LCD_RS				PORTB,1
#define	LCD_RW				PORTB,2
#define	LCD_E				PORTB,3

#define	LCD_D4				PORTB,4
#define	LCD_D5				PORTB,5
#define	LCD_D6				PORTB,6
#define	LCD_D7				PORTB,7

#define B_Select			PORTD,4
#define B_Incrementar		PORTD,6
#define B_Decrementar		PORTD,7

#define RES_PIN				PORTE,0
#define	TMR0_TEMPO_BASE		(.256 - .125)

#define PWM_PIN	PORTC,2


#define	Botao_press			VAR_BIT,0
#define Calc_FLX			VAR_BIT,1
#define RES_Chave			VAR_BIT,3
#define Atualizar_Temp		VAR_BIT,4

;**********************************************************************
	ORG     0x000				;Vetor de reset
	nopdd
  	goto    Main				;Vai para rotina principal


	ORG     0x004				;Vetor de interrupção

	movwf   w_temp				;Salva W
	movf	STATUS,w			;Salva o STATUS
	movwf	status_temp			;
	movf	PCLATH,w			;Salva o PCLATH
	movwf	pclath_temp			;
	BANK0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Testa qual interrupção aconteceu
	btfsc	INTCON,INTF			;
	goto	RB0_INT				;
FIM_RB0_INT:					;
								;
	btfsc	PIR1,TMR2IF			;
	goto	TMR2_INT			;
FIM_TMR2_INT:					;
								;
	btfsc	PIR1,TMR1IF			;
	goto	TMR1_INT			;
FIM_TMR1_INT:					;
								;
	btfsc	PIR1,ADIF			;
	goto	ADC_INT				;
FIM_ADC_INT:					;
								;
	btfsc	INTCON,T0IF			;
	goto	TMR0_INT			;
FIM_TMR0_INT:					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FIM_INT:
	movf	pclath_temp,W		;Recupera o PCLATH
	movwf	PCLATH				;
	movf    status_temp,w		;Recupera o STATUS
	movwf	STATUS				;
	swapf   w_temp,f			;Recupera W
	swapf   w_temp,w			;
	retfie						;Retorna da interrupção


TMR2_INT:
	bcf		PIR1,TMR2IF			;Limpa a bandeira de interrupção

	incfsz	Count_Temp_ROT_L
	goto	$+2
	incf	Count_Temp_ROT_H

	btfss	Count_Temp_ROT_H, 1
	goto	Fim_Cont_512

	movf	Temp_ROT_H, W
	subwf	Count_Temp_ROT_H, W
	btfsc	STATUS, C
	goto	Force_up_FLX
	movf	Temp_ROT_L, W
	subwf	Count_Temp_ROT_L, W
	btfsc	STATUS, C
	goto	Fim_Cont_512
	movlw	.1
	subwf	Temp_ROT_H, W
	btfss	STATUS, C
	goto	Force_up_FLX
Fim_Cont_512:

	btfss	Count_Temp_ROT_H, 2
	goto	Fim_Cont_1024

	movf	Temp_ROT_H, W
	subwf	Count_Temp_ROT_H, W
	btfsc	STATUS, C
	goto	Force_up_FLX
	movf	Temp_ROT_L, W
	subwf	Count_Temp_ROT_L, W
	btfsc	STATUS, C
	goto	Fim_Cont_1024
	movlw	.1
	subwf	Temp_ROT_H, W
	btfss	STATUS, C
	goto	Force_up_FLX
Fim_Cont_1024:

	btfss	Count_Temp_ROT_H, 3
	goto	Fim_Cont_2048
	movlw	0xFF
	movwf	Count_Temp_ROT_H
	movwf	Count_Temp_ROT_L
	bcf		T2CON, TMR2ON
	clrf	Fluxo
	goto	N_calc
Fim_Cont_2048:



	goto	N_calc
Force_up_FLX:
	movf	Count_Temp_ROT_H,W
	movwf	Temp_ROT_H
	movf	Count_Temp_ROT_L,W
	movwf	Temp_ROT_L

	bsf		Calc_FLX


N_calc:


	movlw	(.256-.250)
	addwf	TMR2	
	goto	FIM_TMR2_INT


TMR1_INT:
	bcf		PIR1,TMR1IF			;Limpa a bandeira de interrupção

	movf	Motor_cont, W
	btfss	STATUS, Z
	goto	$+3
	movlw	b'0001010'
	movwf	PORTD
	
	movf	Motor_cont, W
	sublw	.1
	btfss	STATUS, Z
	goto	$+3
	movlw	b'0000110'
	movwf	PORTD
	
	movf	Motor_cont, W
	sublw	.2
	btfss	STATUS, Z
	goto	$+3
	movlw	b'0000101'
	movwf	PORTD
	
	movf	Motor_cont, W
	sublw	.3
	btfss	STATUS, Z
	goto	$+3
	movlw	b'0001001'
	movwf	PORTD

	incf	Motor_cont,F		;Incrementa o apontador de passo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Caso a contagem do motor chegue a 4
	movf	Motor_cont, W		;zera a variável de contagem.
	sublw	.4					;
	btfss	STATUS, Z			;
	goto	$+2					;
	clrf	Motor_cont			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Re-carrega a contagem do timer
	movf	TMR1H_RE, W			;Soma com a contagem durante a interrupção
	addwf	TMR1H, F			;para obter um tempo preciso
	movf	TMR1L_RE, W			;
	addwf	TMR1L, F			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	goto	FIM_TMR1_INT		;Vai para o fim da rotina de interrupção

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Interrupção externa
RB0_INT:
	bcf		INTCON,INTF

	movf	Count_Temp_ROT_H,W
	movwf	Temp_ROT_H
	movf	Count_Temp_ROT_L,W
	movwf	Temp_ROT_L

	clrf	Count_Temp_ROT_H
	clrf	Count_Temp_ROT_L

	bsf		Calc_FLX

	bsf		T2CON, TMR2ON

	goto	FIM_RB0_INT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Interrupção do conversor AD
ADC_INT:
	bcf		PIR1,ADIF
	movf	ADRESH, W
	movwf	Temperatura

	movlw	.255					;Define a potência inicial de 100%(255) , caso as seguintes condições não se apliquem
	movwf	Potencia_RES
	
	movf	Temperatura, W
	addlw	.11						;Caso a temperatura esteja 10ºC do set point, define a potência como 50%(128)
	subwf	Temperatura_definida, W
	btfsc	STATUS, C
	goto	$+3
	movlw	.128
	movwf	Potencia_RES
	
	movf	Temperatura, W
	addlw	.5						;Caso a temperatura esteja 5ºC do set point, define a potência como 35%(90)
	subwf	Temperatura_definida, W
	btfsc	STATUS, C
	goto	$+3
	movlw	.90
	movwf	Potencia_RES
	
	movf	Temperatura, W
	addlw	.3						;Caso a temperatura esteja 2ºC do set point, define a potência como 29%(75)
	subwf	Temperatura_definida, W
	btfsc	STATUS, C
	goto	$+3
	movlw	.75
	movwf	Potencia_RES
	
	movf	Temperatura, W			;Caso a temperatura esteja igual ao set point, define a potência como 21%(55)
	subwf	Temperatura_definida, W
	btfss	STATUS, Z
	goto	$+3
	movlw	.55
	movwf	Potencia_RES
	
	movf	Temperatura_definida, W	;Caso a temperatura esteja maior ao set point, desliga a resistência
	subwf	Temperatura, W
	btfsc	STATUS, C
	clrf	Potencia_RES

	goto	FIM_ADC_INT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Interrupção do timer 0
TMR0_INT:
	bcf		INTCON,T0IF

	btfss	RES_Chave
	goto	Fim_Temp_Pot

	incf	Potencia_COUNTER, F
	movf	Potencia_COUNTER, W
	subwf	Potencia_RES, W
	btfsc	STATUS, C
	goto	$+3
	bcf		RES_PIN
	goto	$+2
	bsf		RES_PIN
Fim_Temp_Pot:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Varredura das teclas
	decfsz	Tempo_varredura, F
	goto	Fim_varredura
	
	bcf		Botao_press
	
	btfsc	B_Select
	goto	Fim_varredura
	
	btfsc	B_Incrementar
	goto	Fim_inc_P
	bsf		Botao_press
	movlw	.130
	subwf	Temperatura_definida, W
	btfsc	STATUS, Z
	goto	Fim_inc_P
	incf	Temperatura_definida, F
Fim_inc_P:
	
	btfsc	B_Decrementar
	goto	Fim_dec_P
	bsf		Botao_press

	movlw	.39
	subwf	Temperatura_definida, W
	btfsc	STATUS,Z
	goto	Fim_dec_P

	decf	Temperatura_definida, F
Fim_dec_P:
	
	movlw	.39
	subwf	Temperatura_definida, W
	btfss	STATUS, Z
	goto	$+4
	bcf		RES_Chave 			    ;Desliga o controle da resistência
	bcf		RES_PIN					;
	goto	Fim_OFF
	
	bsf		RES_Chave				;Liga o controle da resistência
	
Fim_OFF:
	
	btfsc	Botao_press
	goto	$+4
	movlw	.1
	movwf	Tempo_varredura
	goto	$+3
	movlw	.32
	movwf	Tempo_varredura

Fim_varredura:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	incfsz	Count_AT
	goto	N_atualizar
	movlw	(.256 - .40)
	movwf	Count_AT
	bsf		Atualizar_Temp
	movlw	TMR0_TEMPO_BASE
	movwf	TMR0
N_atualizar:

	goto	FIM_TMR0_INT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Constantes

Inicial_01:
DT "SP= 00  T= 00 ",0xDF,"C/2Flx= 0,00 ml//min",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal

Main:
	BANK0
	bcf		RES_Chave
	bcf		RES_PIN
	clrf	ADC_POINT
	clrf	Count_Temp_ROT_H
	clrf	Count_Temp_ROT_L
	movlw	0xFF
	movwf	Temp_ROT_H
	movwf	Temp_ROT_L
	clrf	Fluxo
	bcf		Calc_FLX
	movlw	.1
	movwf	Tempo_varredura
	BANK1
	bcf		PWM_PIN				;Define como saída o pino do PWM
	bcf		RES_PIN
	movlw	b'11110000'
	movwf	TRISD
	movlw	b'00000000'
	movwf	ADCON1
	movlw	b'10000111'			;Configura o prescaler do timer 0 para 1:256, clock interno (FOSC/4)
	movwf	OPTION_REG
	BANKSEL	ANSEL
	movlw	b'00000011'			;Define apenas os pinos RA0 e RA1 como entradas analógicas
	movwf	ANSEL
	BANKSEL ANSELH
	clrf	ANSELH
	BANK0
	call	Delay_200ms			;Delay de 200 milisegundos para garantir que o display esteja energizado
	call	Init_LCD			;Chama a subrotina para inicialização do display no modo 4 bits

	Escrever_LCD Inicial_01		;Escreve a string inicial no display

	movlw	(.256-.250)
	movwf	TMR2
	movlw	b'01001111'
	movwf	T2CON

	movlw	TMR0_TEMPO_BASE
	movwf	TMR0

	movlw	.39
	movwf	Temperatura_definida

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Controle de motor de passo desativado
;	movlw	high(.65536 -.5000)
;	movwf	TMR1H_RE

;	movlw	low(.65536 -.5000)	;12500 20MHz -> 50p/s
;	movwf	TMR1L_RE


;	movlw	b'00110001'			;Configura o timer 1
;	movwf	T1CON				;Fonte = Fosc/32 Ativar contagem
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	movlw	b'11110000'			;Ativa a chave geral de interrupções, a interrupção do timer 0
	movwf	INTCON				;e a interrupção externa

	movlw	b'10000011'
	movwf	ADCON0

	BANK1
	movlw	b'01000010'
	movwf	PIE1				;Ativa a interrupção do conversor AD e Timer2
	BANK0


Loop:
	bsf		ADCON0,1


	btfss	Atualizar_Temp
	goto	Fim_Atualizar_Temp
	movf	Temperatura, W
	call	Byte_To_Char

	movlw	0x0A
	call	Endereco_LCD

	movf	DSP1, W
	sublw	0x30
	btfsc	STATUS, Z
	movlw	0xEF	
	addlw	0x30

	call	Enviar_char_lcd
	movf	DSP2, W
	call	Enviar_char_lcd
	movf	DSP3, W
	call	Enviar_char_lcd

	movf	Fluxo, W
	call	Byte_To_Char

	movlw	0x45
	call	Endereco_LCD

	movf	DSP1, W
	call	Enviar_char_lcd
	movlw	','
	call	Enviar_char_lcd
	movf	DSP2, W
	call	Enviar_char_lcd
	movf	DSP3, W
	call	Enviar_char_lcd

	bcf		Atualizar_Temp
Fim_Atualizar_Temp:

	movf	Temperatura_definida, W
	call	Byte_To_Char

	movlw	0x03
	call	Endereco_LCD
	btfss	RES_Chave
	goto	RES_OFF
	movf	DSP1, W
	sublw	0x30
	btfsc	STATUS, Z
	movlw	0xEF	
	addlw	0x30

	call	Enviar_char_lcd
	movf	DSP2, W
	call	Enviar_char_lcd
	movf	DSP3, W
	call	Enviar_char_lcd
	goto	RES_ON
RES_OFF:
	movlw	'O'
	call	Enviar_char_lcd
	movlw	'F'
	call	Enviar_char_lcd
	movlw	'F'
	call	Enviar_char_lcd
RES_ON:


	btfss	Calc_FLX
	goto	Loop

	movlw	low(.24043)
	movwf	Dividendo_L
	movlw	high(.24043)
	movwf	Dividendo_H

	movf	Temp_ROT_H, W
	movwf	Divisor_H
	movf	Temp_ROT_L, W
	movwf	Divisor_L

	call	DIV16
	movf	Resultado_L, W
	movwf	Fluxo

	bcf		Calc_FLX

	goto	Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Init_LCD:
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
	bcf		LCD_RS
	bcf		LCD_RW
	bcf		LCD_E

	call	Delay_5mS

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
	Delay_5us
	bsf		LCD_E				;Coloca o pino enable em 1
	Delay_5us
	bcf		LCD_E				;Volta o pino enable em 0	
	return

Enviar_char_lcd					;Sub-rotina para enviar um caracter para o display lcd
	movwf	Temp1
	call	Aguardar_BF_LCD			;
	bsf		LCD_RS
	Delay_5us
	movfw	Temp1
	call	Enviar_byte_lcd
	Delay_5us
	bcf		LCD_RS
	return


Ler_Str_Tabela:
    movf	EnderecoStr_H,W
    movwf	PCLATH
    movf	EnderecoStr_L,W
    movwf   PCL
 

Enviar_String:
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
	Delay_5us
	bsf		LCD_E
	Delay_5us
	btfsc	LCD_D4
	bsf		byte,4
	btfsc	LCD_D5
	bsf		byte,5
	btfsc	LCD_D6
	bsf		byte,6
	btfsc	LCD_D7
	bsf		byte,7

	bcf		LCD_E
	Delay_5us
	bsf		LCD_E
	Delay_5us
	
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

Byte_To_Char:					;Rotina para a conversão de binário de 8 bits para decimal
	movwf	Dado
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

	movlw	0x30
	addwf	DSP1 , F	
	movlw	0x30
	addwf	DSP2 , F	
	movlw	0x30
	addwf	DSP3 , F	
	return							;Retorna da sub-rotina

DIV16:
	movf	Divisor_L,F
	btfss 	STATUS,Z
	goto	ZERO_TEST_SKIPPED
	movf	Divisor_H,F
	btfsc	STATUS,Z
return

ZERO_TEST_SKIPPED:
	movlw   1
	movwf   Base_Index_L
	clrf    Base_Index_H
	clrf    Resultado_L
	clrf    Resultado_H

SHIFT_IT16:
	btfsc   Divisor_H,7
	goto 	DIVU16LOOP
	bcf     STATUS,C
  	rlf     Base_Index_L,F
  	rlf     Base_Index_H,F
  	bcf     STATUS,C
  	rlf     Divisor_L,F
  	rlf     Divisor_H,F
  	goto    SHIFT_IT16

DIVU16LOOP:
	call    SUB16
	btfsc   STATUS,C
	goto    COUNTX
	call    ADD16BIS
	goto    FINALX
COUNTX:
	movf    Base_Index_L,W
	addwf   Resultado_L
	btfsc   STATUS,C
	incf    Resultado_H,F
	movf    Base_Index_H,W
	addwf   Resultado_H
FINALX:
	bcf     STATUS,C
	rrf     Divisor_H,F
	rrf     Divisor_L,F
	bcf     STATUS,C
	rrf     Base_Index_H,F
	rrf     Base_Index_L,F
	btfss   STATUS,C
	goto    DIVU16LOOP
return

SUB16:
	movf    Divisor_H,W
	movwf   Temp1
	movf    Divisor_L,W
	subwf   Dividendo_L
	btfss   STATUS,C
	incf    Temp1,F
	movf    Temp1,W
	subwf   Dividendo_H
return

ADD16BIS:
	movf    Divisor_L,W
	addwf   Dividendo_L
	btfsc   STATUS,C
	incf    Dividendo_H,F
	movf    Divisor_H,W
	addwf   Dividendo_H
return

Delay_5mS
			;24993 cycles
	movlw	0x86
	movwf	delay1
	movlw	0x14
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
			;999990 cycles
	movlw	0x07
	movwf	delay1
	movlw	0x2F
	movwf	delay2
	movlw	0x03
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return

	END

