processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF


cblock 0x20
Dado
DSP1
DSP2
DSP3
Resultado
Cont_AD
byte
delay1
delay2
delay3
Media_ad_L
Media_ad_H
Media_ad_resultado_L
Media_ad_resultado_H
W_2
STATUS_2
Temp_Cont
Pontencia_RES
VAR_BIT
Temperatura_definida
Tempo_varredura
endc

#define	Temperatura_atual	Media_ad_resultado_H
#define	Atualizar_DSP		VAR_BIT, 0
#define	Botao_press			VAR_BIT, 1
#define	RES_Chave			VAR_BIT, 2
#define RES_ON				bsf	RES_Chave
#define RES_OFF				bcf	RES_Chave
#define Fluxo_Select		PORTC, 7
#define Temp_Select			PORTC, 6
#define B_Incrementar		PORTC, 5
#define B_Decrementar		PORTC, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
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
E_1 macro						;Coloca o pino enable em 1
movlw	b'100'					;
iorwf	PORTE					;
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
movlw	b'011'					;
andwf	PORTE					;
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
RB7_E macro						;Configura como entrada o pino RB7
BANK1							;
bsf		TRISB, 7				;
BANK0							;
Endm							;
								;
RB7_S macro						;Configura como saida o pino RB7
BANK1							;
bcf		TRISB, 7				;
BANK0							;
Endm							;
								;
ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0X0004						;Rotina da interrupção
movwf	W_2
movf	STATUS, W
movwf	STATUS_2

;clrwdt

btfss	RES_Chave
goto	Fim_Temp_Controle

incf	Temp_Cont, F
movf	Temp_Cont, W
subwf	Pontencia_RES, W
btfsc	STATUS, C
goto	$+3
bcf		PORTD, 2
goto	$+2
bsf		PORTD, 2

Fim_Temp_Controle

movlw	.5
call	Endereco_LCD

BANK1
movf	ADRESL, W
BANK0
addwf	Media_ad_L
btfsc	STATUS, C
incf	Media_ad_H, F

movf	ADRESH, W
addwf	Media_ad_H

decfsz	Cont_AD, F
goto	Fim_Media
movlw	.64
movwf	Cont_AD


movf	Media_ad_H, W
movwf	Media_ad_resultado_H

movf	Media_ad_L, W
movwf	Media_ad_resultado_L


movf	Media_ad_H, W
call	Converter
	
movf	DSP1, W	
call	Enviar_char_lcd

movf	DSP2, W	
call	Enviar_char_lcd

movf	DSP3, W	
call	Enviar_char_lcd

movlw	'.'
call	Enviar_char_lcd

btfss	Media_ad_resultado_L, 7
goto	$+4
movlw	'5'
call	Enviar_char_lcd
goto	$+3
movlw	'0'
call	Enviar_char_lcd


;movlw	.51
;subwf	Media_ad_H, W
;btfsc	STATUS, Z
;goto	$+3
;bcf		PORTD, 2
;goto	$+2
;bsf		PORTD, 2

;movlw	.51
;subwf	Media_ad_H, W
;btfss	STATUS, C
;goto	$+3
;bcf		PORTD, 2
;goto	$+2
;bsf		PORTD, 2

clrf	Media_ad_L
clrf	Media_ad_H


Fim_Media
bsf		ADCON0,2

decfsz	Tempo_varredura, F
goto	Fim_varredura

bcf		Botao_press


btfsc	B_Incrementar
goto	Fim_inc_P

movlw	.131
subwf	Temperatura_definida, W
btfss	STATUS, Z
goto	$+3
movlw	.39
movwf	Temperatura_definida


incf	Temperatura_definida, F
bsf		Atualizar_DSP
bsf		Botao_press

movlw	.131
subwf	Temperatura_definida, W
btfss	STATUS, Z
goto	$+3
RES_OFF
goto	Fim_inc_P

RES_ON

Fim_inc_P

btfsc	B_Decrementar
goto	Fim_dec_P

movlw	.39
subwf	Temperatura_definida, W
btfss	STATUS, Z
goto	$+3
movlw	.131
movwf	Temperatura_definida


decf	Temperatura_definida, F
bsf		Atualizar_DSP
bsf		Botao_press

movlw	.39
subwf	Temperatura_definida, W
btfss	STATUS, Z
goto	$+3
RES_OFF
goto	Fim_dec_P

RES_ON

Fim_dec_P

btfsc	Botao_press
goto	$+4
movlw	.1
movwf	Tempo_varredura
goto	$+3
movlw	.30
movwf	Tempo_varredura

Fim_varredura

movlw	.140
subwf	Temperatura_atual, W
btfss	STATUS, C
goto	Fim_MSG_1
bcf		PORTD, 2
call	Limpar_LCD
movlw	'S'
call	Enviar_char_lcd
movlw	'u'
call	Enviar_char_lcd
movlw	'p'
call	Enviar_char_lcd
movlw	'e'
call	Enviar_char_lcd
movlw	'r'
call	Enviar_char_lcd
movlw	'a'
call	Enviar_char_lcd
movlw	'q'
call	Enviar_char_lcd
movlw	'u'
call	Enviar_char_lcd
movlw	'e'
call	Enviar_char_lcd
movlw	'c'
call	Enviar_char_lcd
movlw	'i'
call	Enviar_char_lcd
movlw	'm'
call	Enviar_char_lcd
movlw	'e'
call	Enviar_char_lcd
movlw	'n'
call	Enviar_char_lcd
movlw	't'
call	Enviar_char_lcd
movlw	'o'
call	Enviar_char_lcd
goto	$
Fim_MSG_1

								;
INT_FIM							;
movlw	0xF0
movwf	TMR1L
movlw	0xD8
movwf	TMR1H

movf	STATUS_2,W
movwf	STATUS
movf	W_2
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main

	clrf	PORTB				;Limpa a porta B
	clrf	PORTE				;Limpa a porta E
	clrf	Pontencia_RES
	clrf	Temperatura_atual

	movlw	.64
	movwf	Cont_AD

	RES_OFF						

	movlw	b'01000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
	movwf	ADCON0


	movlw	.40
	movwf	Temperatura_definida


	BANK1						;Seleciona o banco 1 da RAM
	bcf		OPTION_REG , 7
	movlw	b'10000010'			;Configura a porta A como entrada analógica
	movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
	clrf	TRISB				;Define a porta B como saida
	clrf	TRISE				;Defina a porta E como saida
	bcf		TRISD, 2			;Define o pino RD2 como saida (controle do relé de estado sólido)	
	BANK0						;Seleciona o banco 0 da RAM
	bcf		PORTD, 2

	movlw	b'11000000'			;
	movwf	INTCON				;

	movlw	b'00000001'			;
	movwf	T1CON				;

	movlw	.1
	movwf	Tempo_varredura

	movlw	0xF0
	movwf	TMR1L
	movlw	0xD8
	movwf	TMR1H

	call	Delay_200ms			;Delay de 200 milisegundos para garantir que o display esteja energizado
	call	Init_LCD			;Chama a subrotina para inicialização do display no modo 8 bits


	movlw	'T'					;Coloca a mensagem "Temp:000" no display LCD
	call	Enviar_char_lcd

	movlw	'e'
	call	Enviar_char_lcd

	movlw	'm'
	call	Enviar_char_lcd

	movlw	'p'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	call	Linha_2_LCD			;Vai para a segunda linha do display

	movlw	'S'					;Coloca a mensagem "Set:000" no display LCD
	call	Enviar_char_lcd

	movlw	'e'
	call	Enviar_char_lcd

	movlw	't'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd		;0x43 -> 0x44

	movlw	'O'
	call	Enviar_char_lcd

	movlw	'4'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd



	RES_ON

	movlw	.127
	movwf	Pontencia_RES

	Inicio_AD

	bsf		ADCON0,2

	clrf	Media_ad_L
	clrf	Media_ad_H
;	movlw	.10
;	movwf	Pontencia_RES

	BANK1
	bsf		PIE1 , 0
	BANK0

;	clrf	Media_ad_L
;	clrf	Media_ad_H
;	bsf		ADCON0,2
;	btfsc	ADCON0,2
;	goto	$-1


;	movlw	.12
;	call	Endereco_LCD


;	movf	ADRESL , 0
;	movwf	Dado
;	call	Converter
	
;	movf	DSP1 , W	
;	call	enviar_char_lcd

;	movf	DSP2 , W	
;	call	enviar_char_lcd

;	movf	DSP3 , W	
;	call	enviar_char_lcd

;	call	Delay_0S5

;	goto 	Inicio_AD

Loop_Principal


;Atualizar_DSP
	btfss	Atualizar_DSP
	goto	Fim_Atualizar_DSP

	movlw	0x44
	call	Endereco_LCD
	

	movlw	.39
	subwf	Temperatura_definida, W
	btfsc	STATUS, Z
	goto	Res_Desligado

	movlw	.131
	subwf	Temperatura_definida, W
	btfsc	STATUS, Z
	goto	Res_Desligado

	movf	Temperatura_definida, W
	call	Converter

	movf	DSP1, W	
	call	Enviar_char_lcd

	movf	DSP2, W	
	call	Enviar_char_lcd

	movf	DSP3, W	
	call	Enviar_char_lcd

	bcf		Atualizar_DSP

	goto	Fim_Atualizar_DSP

Res_Desligado

	movlw	'O'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

	bcf		Atualizar_DSP

Fim_Atualizar_DSP


Controle_de_temperatura

	movf	Temperatura_definida, W
	subwf	Temperatura_atual, W
	btfss	STATUS, C
	goto	$+4
	RES_OFF
	bcf		PORTD, 2
	goto	$+2
	RES_ON

	goto	Loop_Principal

sleep
									;Termina a rotina principal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;Começo das sub-rotinas

Converter							;Rotina para a conversão de binário de 8 bits para decimal
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

	Limpar_LCD						;
	movlw	b'00000001'
	call	Enviar_byte_lcd			;Envia o comando
	call	Delay_2mS				;	
	return

	Init_LCD
	E_0
	movlw	0x30					;Inicialização do display lcd
	call	Enviar_byte_lcd			;Configuraçao: 2 linhas, 8 bits
	call	Delay_2mS				;
	movlw	0x30					;
	call	Enviar_byte_lcd			;	
	call	Delay_2mS				;
	movlw	0x30					;	
	call	Enviar_byte_lcd			;	
	call	Delay_40uS				;
	movlw	0x38					;	
	call	Enviar_byte_lcd			;	
	call	Delay_40uS				;
	call	Limpar_LCD				;Limpa o display
	movlw	0x0C					;
	call	Enviar_byte_lcd			;
	call	Delay_40uS				;
	return

	Enviar_byte_lcd					;Sub-rotina para enviar um byte para o display lcd
	movwf	byte					;
	movf	byte,0
	movwf	PORTB					;Coloca o dado na porta B
	E_1								;Coloca o pino enable em 1
	E_0								;Volta o pino enable em 0
	return							;Retorna da sub-rotina

	Enviar_char_lcd					;Sub-rotina para enviar um caracter para o display lcd
	movwf	byte					;
	RS_1
	movf	byte , 0
	movwf	PORTB					;Coloca o dado na porta B
	E_1								;Coloca o pino enable em 1
	E_0								;Volta o pino enable em 0
	call	Delay_40uS				;
	RS_0
	return							;Retorna da sub-rotina
									;
									;
	Endereco_LCD
	iorlw	b'10000000'
	call	Enviar_byte_lcd			;Envia o comando
	call	Delay_40uS				;
	return

	Linha_1_LCD
	movlw	b'10000000'
	call	Enviar_byte_lcd			;Envia o comando
	call	Delay_40uS				;
	return	

	Linha_2_LCD
	movlw	b'11000000'
	call	Enviar_byte_lcd			;Envia o comando
	call	Delay_40uS				;
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
	return							;Retorna da sub-rotina


									;Fim do programa
END