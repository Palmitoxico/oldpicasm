;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Reator pós coluna                             ;;
;;Versão do programa: 1.32                      ;;
;;Versão do hardware: 1.0                       ;;
;;Desenvolvido por Augusto Fraga Giachero       ;;
;;Cristal 4MHz                                  ;;
;;                                              ;;
;;                                              ;;
;;Data de início: 05/12/2010                    ;;
;;Data da última atualização: 13/12/2011        ;;
;;                                              ;;
;;                                              ;;
;;PIC 16F877 ou 16f877A                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF


cblock 0x20
Dado
DSP1
DSP2
DSP3
DSP4
DSP5
VAR_L
VAR_H
Resultado
Cont_AD
byte
delay1
delay2
delay3
Media_Temp_L
Media_Temp_H
Media_Temp_resultado_L
Media_Temp_resultado_H
Media_Pressao_L
Media_Pressao_H
Pressao_L
Pressao_H
Valor_H
Valor_L
Media_Pressao_resultado_L
Media_Pressao_resultado_H
Media_Fluxo_L
Media_Fluxo_H
Media_Fluxo_resultado_L
Media_Fluxo_resultado_H
Fluxo_L
Fluxo_H
W_2
STATUS_2
Temp_Cont
Pontencia_RES
VAR_BIT
Temperatura_definida
Tempo_varredura
Ajuste_media_L
Ajuste_media_H
Mult_count
Mult_Valor
Temp1
Nibble
endc

#define	Temperatura_atual	Media_Temp_resultado_H
#define	Atualizar_DSP		VAR_BIT, 0
#define	Botao_press			VAR_BIT, 1
#define	RES_Chave			VAR_BIT, 2
#define	Modo_VAD			VAR_BIT, 3
#define B_Select			PORTC, 6
#define B_Incrementar		PORTC, 5
#define B_Decrementar		PORTC, 4
#define RES_PIN				PORTD, 2

#define	LCD_RW	PORTE,1
#define	LCD_RS	PORTE,0
#define	LCD_E	PORTE,2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
RES_ON macro					;
bsf		RES_Chave				;Liga o controle da resistência
Endm							;
								;
RES_OFF macro					;
bcf		RES_Chave 			    ;Desliga o controle da resistência
bcf		RES_PIN					;
Endm							;
								;
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
;movlw	b'100'					;
;iorwf	PORTE					;
bsf		PORTE,2
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
;movlw	b'011'					;
;andwf	PORTE					;
bcf		PORTE,2
Endm							;
								;
RS_1 macro						;Coloca o pino RS em 1
;movlw	b'001'					;
;iorwf	PORTE					;
bsf		PORTE,0
Endm							;
								;
RS_0 macro						;Coloca o pino RS em 0
;movlw	b'110'					;
;andwf	PORTE					;
bcf		PORTE,0
Endm							;
								;
RW_1 macro						;Coloca o pino RW em 1
;movlw	b'010'					;
;iorwf	PORTE					;
bsf		PORTE,1
Endm							;
								;
RW_0 macro						;Coloca o pino RW em 0
;movlw	b'101'					;
;andwf	PORTE					;
bcf		PORTE,1
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
DESATIVAR_INT macro				;Desativa temporariamente todas as interrupções
bcf		INTCON,GIE				;
Endm							;
								;
ATIVAR_INT macro				;Ativa todas as interrupções
bsf		INTCON,GIE				;
Endm							;
								;
ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0X0004						;Rotina da interrupção
movwf	W_2
movf	STATUS, W
movwf	STATUS_2
BANK0

;clrwdt

btfsc	Modo_VAD
goto	Modo_VAD_Controle

btfss	RES_Chave
goto	Fim_Temp_Controle

incf	Temp_Cont, F
movf	Temp_Cont, W
subwf	Pontencia_RES, W
btfsc	STATUS, C
goto	$+3
bcf		RES_PIN
goto	$+2
bsf		RES_PIN

Fim_Temp_Controle

Modo_VAD_Controle

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop


movlw	b'01000001'				;Media da temperatura
movwf	ADCON0

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop


bsf		ADCON0,2

btfsc	ADCON0,2
goto	$-1

BANK1
movf	ADRESL, W
BANK0
addwf	Media_Temp_L, F
btfsc	STATUS, C
incf	Media_Temp_H, F

movf	ADRESH, W
addwf	Media_Temp_H

movlw	b'01001001'				;Media da pressão
movwf	ADCON0


nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop



bsf		ADCON0,2

btfsc	ADCON0,2
goto	$-1

BANK1
movf	ADRESL, W
BANK0
addwf	Media_Pressao_L, F
btfsc	STATUS, C
incf	Media_Pressao_H, F

movf	ADRESH, W
addwf	Media_Pressao_H

movlw	b'01010001'				;Media do fluxo
movwf	ADCON0

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop


bsf		ADCON0,2

btfsc	ADCON0,2
goto	$-1

BANK1
movf	ADRESL, W
BANK0
addwf	Media_Fluxo_L, F
btfsc	STATUS, C
incf	Media_Fluxo_H, F

movf	ADRESH, W
addwf	Media_Fluxo_H


decfsz	Cont_AD, F
goto	Fim_Media
movlw	.64
movwf	Cont_AD


movf	Media_Temp_H, W
movwf	Media_Temp_resultado_H

movf	Media_Temp_L, W
movwf	Media_Temp_resultado_L

movf	Media_Fluxo_H, W
movwf	Media_Fluxo_resultado_H

movf	Media_Fluxo_L, W
movwf	Media_Fluxo_resultado_L

movf	Media_Pressao_H, W
movwf	Media_Pressao_resultado_H

movf	Media_Pressao_L, W
movwf	Media_Pressao_resultado_L


movf	Media_Pressao_resultado_H, W
movwf	Ajuste_media_L

rlf		Media_Pressao_resultado_L, F
rlf		Ajuste_media_L, F
rlf		Ajuste_media_H, F

rlf		Media_Pressao_resultado_L, F
rlf		Ajuste_media_L, F
rlf		Ajuste_media_H, F

movf	Ajuste_media_L, W
movwf	Media_Pressao_resultado_L

movf	Ajuste_media_H, W
movwf	Media_Pressao_resultado_H

clrf	Ajuste_media_L
clrf	Ajuste_media_H


movf	Media_Fluxo_resultado_H, W
movwf	Ajuste_media_L

rlf		Media_Fluxo_resultado_L
rlf		Ajuste_media_L, F
rlf		Ajuste_media_H, F

rlf		Media_Fluxo_resultado_L
rlf		Ajuste_media_L, F
rlf		Ajuste_media_H, F

movf	Ajuste_media_L, W
movwf	Media_Fluxo_resultado_L

movf	Ajuste_media_H, W
movwf	Media_Fluxo_resultado_H


clrf	Ajuste_media_L
clrf	Ajuste_media_H


bsf		Atualizar_DSP


clrf	Media_Temp_L
clrf	Media_Temp_H
clrf	Media_Fluxo_L
clrf	Media_Fluxo_H
clrf	Media_Pressao_L
clrf	Media_Pressao_H


Fim_Media


btfsc	Modo_VAD
goto	Modo_VAD_varredura

decfsz	Tempo_varredura, F
goto	Fim_varredura

bcf		Botao_press

btfsc	B_Select
goto	Fim_varredura

btfsc	B_Incrementar
goto	Fim_inc_P

movlw	.130
subwf	Temperatura_definida, W
btfsc	STATUS, Z
goto	Fim_inc_P
incf	Temperatura_definida, F
bsf		Atualizar_DSP
bsf		Botao_press


Fim_inc_P

btfsc	B_Decrementar
goto	Fim_dec_P

movlw	.39
subwf	Temperatura_definida, W
btfsc	STATUS, Z
goto	Fim_dec_P

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
bcf		RES_PIN
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


movlw	.39
subwf	Temperatura_definida, W
btfsc	STATUS, Z
goto	Fim_controle_ON_OFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina de controle da temperatura
movlw	.255					;Define a potência inicial de 100%(255) , caso as seguintes condições não se apliquem
movwf	Pontencia_RES

movf	Temperatura_atual, W
addlw	.11						;Caso a temperatura esteja 10ºC do set point, define a potência como 50%(128)
subwf	Temperatura_definida, W
btfsc	STATUS, C
goto	$+3
movlw	.128
movwf	Pontencia_RES

movf	Temperatura_atual, W
addlw	.5						;Caso a temperatura esteja 5ºC do set point, define a potência como 35%(90)
subwf	Temperatura_definida, W
btfsc	STATUS, C
goto	$+3
movlw	.90
movwf	Pontencia_RES

movf	Temperatura_atual, W
addlw	.3						;Caso a temperatura esteja 2ºC do set point, define a potência como 29%(75)
subwf	Temperatura_definida, W
btfsc	STATUS, C
goto	$+3
movlw	.75
movwf	Pontencia_RES

movf	Temperatura_atual, W	;Caso a temperatura esteja igual ao set point, define a potência como 19%(50)
subwf	Temperatura_definida, W
btfss	STATUS, Z
goto	$+3
movlw	.50
movwf	Pontencia_RES

movf	Temperatura_definida, W	;Caso a temperatura esteja maior ao set point, desliga a resistência
subwf	Temperatura_atual, W
btfss	STATUS, Z
goto	$+3
RES_ON
goto	Fim_controle_ON_OFF
btfss	STATUS, C
goto	$+4
RES_OFF
goto	$+2
RES_ON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Fim_controle_ON_OFF

Modo_VAD_varredura

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
	bcf		Modo_VAD

	movlw	.64
	movwf	Cont_AD

	RES_OFF						

	movlw	b'01000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
	movwf	ADCON0


	movlw	.40
	movwf	Temperatura_definida


	BANK1						;Seleciona o banco 1 da RAM
;	bcf		OPTION_REG , 7
	movlw	b'10000010'			;Configura a porta A como entrada analógica
	movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
	clrf	TRISB				;Define a porta B como saida
	clrf	TRISE				;Defina a porta E como saida
	clrf	TRISD				;Define a porta D como saida (controle do relé de estado sólido/BIP)	
	BANK0						;Seleciona o banco 0 da RAM
	bcf		RES_PIN

	movlw	b'11000000'			;
	movwf	INTCON				;

	movlw	b'00000001'			;
	movwf	T1CON				;
								;Seleção do modo de programa, caso os botões incrementar e decrementar estejam precionados durante a inicialização,
	btfsc	B_Incrementar		;o microcontrolador mostrará apenas os valores das portas do conversor AD
	goto	Modo_normal
	btfsc	B_Decrementar
	goto	Modo_normal
	bsf		Modo_VAD
Modo_normal

	movlw	.1
	movwf	Tempo_varredura

	movlw	0xF0
	movwf	TMR1L
	movlw	0xD8
	movwf	TMR1H

	call	Delay_200ms			;Delay de 200 milisegundos para garantir que o display esteja energizado
	call	Init_LCD			;Chama a subrotina para inicialização do display no modo 8 bits
	btfsc	Modo_VAD
	goto	Modo_VAD_DSP
	movlw	'T'					;Coloca a mensagem "T:000ºC SP:000°C" no display LCD
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	0xDF
	call	Enviar_char_lcd

	movlw	'C'
	call	Enviar_char_lcd

	movlw	' '
	call	Enviar_char_lcd

	movlw	'S'
	call	Enviar_char_lcd

	movlw	'P'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	0xDF
	call	Enviar_char_lcd

	movlw	'C'
	call	Enviar_char_lcd


	call	Linha_2_LCD			;Vai para a segunda linha do display

	movlw	'F'					;Coloca a mensagem "F:0.00 P:000" no display LCD
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd		;0x41 -> 0x42

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'.'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	' '
	call	Enviar_char_lcd

	movlw	' '
	call	Enviar_char_lcd

;	movlw	'P'
;	call	Enviar_char_lcd
;
;	movlw	':'
;	call	Enviar_char_lcd
;
;	movlw	'0'
;	call	Enviar_char_lcd
;
;	movlw	'0'
;	call	Enviar_char_lcd
;
;	movlw	'0'
;	call	Enviar_char_lcd




	goto	Modo_normal_DSP
Modo_VAD_DSP

	movlw	'A'
	call	Enviar_char_lcd

	movlw	'0'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd		;0x02 -> 0x03

	movlw	.8
	call	Endereco_LCD

	movlw	'A'
	call	Enviar_char_lcd

	movlw	'1'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd		;0x0A -> 0x0B

	call	Linha_2_LCD

	movlw	'A'
	call	Enviar_char_lcd

	movlw	'2'
	call	Enviar_char_lcd

	movlw	':'
	call	Enviar_char_lcd		;0x42 -> 0x43

Modo_normal_DSP



	RES_ON

	movlw	.255				;Potência máxima como padrão durante a inicialização do programa
	movwf	Pontencia_RES

	Inicio_AD

	bsf		ADCON0,2

	clrf	Media_Temp_L
	clrf	Media_Temp_H
	clrf	Media_Fluxo_L
	clrf	Media_Fluxo_H
	clrf	Media_Pressao_L
	clrf	Media_Pressao_H

	BANK1
	bsf		PIE1 , 0
	BANK0


Loop_Principal


;Atualizar_DSP
	btfss	Atualizar_DSP
	goto	Fim_Atualizar_DSP
	bcf		Atualizar_DSP

	btfsc	Modo_VAD
	goto	Modo_VAD_Atualizar

	movlw	.2
	call	Endereco_LCD

	movf	Temperatura_atual, W
	call	Converter
	
	movf	DSP1, W	
	call	Enviar_char_lcd

	movf	DSP2, W	
	call	Enviar_char_lcd

	movf	DSP3, W	
	call	Enviar_char_lcd

	movlw	0x0B
	call	Endereco_LCD
	

	movlw	.39
	subwf	Temperatura_definida, W
	btfsc	STATUS, Z
	goto	Fim_atualizar_temp

	movf	Temperatura_definida, W
	call	Converter

	movf	DSP1, W	
	call	Enviar_char_lcd

	movf	DSP2, W	
	call	Enviar_char_lcd

	movf	DSP3, W	
	call	Enviar_char_lcd


Fim_atualizar_temp

Res_Desligado
	movlw	.39
	subwf	Temperatura_definida, W
	btfss	STATUS, Z
	goto	Fim_Res_Desligado

	movlw	'O'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

Fim_Res_Desligado

Calculo_Pressao
	movf	Media_Pressao_resultado_L, W
	movwf	Valor_L
	movf	Media_Pressao_resultado_H, W
	movwf	Valor_H

	movlw	.170
	subwf	Valor_L, F
	btfss	STATUS, C
	decf	Valor_H, F


	rlf		Valor_L, F
	rlf		Valor_H, F

	clrf	Pressao_L
	clrf	Pressao_H

	goto	$+4
Divsao_por_3
	incfsz	Pressao_L, F
	goto	$+2
	incf	Pressao_H, F
	movlw	.3
	subwf	Valor_L, F
	btfsc	STATUS, C
	goto	Divsao_por_3
	movlw	.1
	subwf	Valor_H, F
	btfsc	STATUS, C	
	goto	Divsao_por_3

	movlw	0x4A
	call	Endereco_LCD

	movf	Pressao_L, W
	movwf	VAR_L

	movf	Pressao_H, W
	movwf	VAR_H

;	call	Converter_Bin_Dec_16bit

;	movf	DSP3, W	
;	call	Enviar_char_lcd
;
;	movf	DSP2, W	
;	call	Enviar_char_lcd
;
;	movf	DSP1, W	
;	call	Enviar_char_lcd

Calculo_Fluxo

	movf	Media_Fluxo_resultado_L, W
	movwf	Fluxo_L

	movf	Media_Fluxo_resultado_H, W
	movwf	Fluxo_H

	rrf		Fluxo_H, F
	rrf		Fluxo_L, F
	bcf		STATUS, C

	rrf		Fluxo_H, F
	rrf		Fluxo_L, F
	bcf		STATUS, C

	rrf		Fluxo_H, F
	rrf		Fluxo_L, F
	bcf		STATUS, C

	rrf		Fluxo_H, F
	rrf		Fluxo_L, F
	bcf		STATUS, C

	rrf		Fluxo_H, F
	rrf		Fluxo_L, F
	bcf		STATUS, C

	movlw	.4
	movwf	Mult_count
	
	movf	Fluxo_L, W
	movwf	Mult_Valor

Mult_por_5
	movf	Mult_Valor, W
	addwf	Fluxo_L, F

	decfsz	Mult_count,F
	goto	Mult_por_5

	movf	Fluxo_L, W
	call	Converter

	movlw	0x42
	call	Endereco_LCD

	movf	DSP1, W	
	call	Enviar_char_lcd

	movlw	'.'
	call	Enviar_char_lcd

	movf	DSP2, W	
	call	Enviar_char_lcd

	movf	DSP3, W	
	call	Enviar_char_lcd


	

	


Fim_Atualizar_DSP

	goto	Loop_Principal

Modo_VAD_Atualizar

	movf	Media_Temp_resultado_H, W
	movwf	VAR_L

	rlf		Media_Temp_resultado_L, F
	rlf		VAR_L, F
	rlf		VAR_H, F

	rlf		Media_Temp_resultado_L, F
	rlf		VAR_L, F
	rlf		VAR_H, F

	call	Converter_Bin_Dec_16bit

	movlw	.3
	call	Endereco_LCD

	movf	DSP4, W
	call	Enviar_char_lcd

	movf	DSP3, W
	call	Enviar_char_lcd

	movf	DSP2, W
	call	Enviar_char_lcd

	movf	DSP1, W
	call	Enviar_char_lcd

	movf	Media_Fluxo_resultado_L, W
	movwf	VAR_L

	movf	Media_Fluxo_resultado_H, W
	movwf	VAR_H

	call	Converter_Bin_Dec_16bit

	movlw	0x43
	call	Endereco_LCD

	movf	DSP4, W
	call	Enviar_char_lcd

	movf	DSP3, W
	call	Enviar_char_lcd

	movf	DSP2, W
	call	Enviar_char_lcd

	movf	DSP1, W
	call	Enviar_char_lcd

	movf	Media_Pressao_resultado_L, W
	movwf	VAR_L

	movf	Media_Pressao_resultado_H, W
	movwf	VAR_H

	call	Converter_Bin_Dec_16bit

	movlw	.11
	call	Endereco_LCD

	movf	DSP4, W
	call	Enviar_char_lcd

	movf	DSP3, W
	call	Enviar_char_lcd

	movf	DSP2, W
	call	Enviar_char_lcd

	movf	DSP1, W
	call	Enviar_char_lcd

	bcf		Atualizar_DSP


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


Init_LCD
	clrf	PORTB
	BANK1
	movlw	b'00001111'
	movwf	TRISB
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
	DESATIVAR_INT
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd
	ATIVAR_INT
	return						;Retorna da sub-rotina

Enviar_nibble_lcd
	movwf	Nibble
	movlw	b'00001111'
	andwf	PORTB
	andwf	Nibble
	swapf	Nibble,0
	iorwf	PORTB
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
	DESATIVAR_INT
	clrf	byte
	BANK1
	movlw	0xFF
	movwf	TRISB
	BANK0
	bsf		LCD_RW
	nop
	nop
	bsf		LCD_E
	nop
	nop
	movwf	0xF0
	andwf	PORTB, W	
	iorwf	byte, F
	bcf		LCD_E
	nop
	nop
	swapf	byte, F
	bsf		LCD_E
	nop
	nop
	movwf	0xF0
	andwf	PORTB, W	
	iorwf	byte, F
	bcf		LCD_E
	swapf	byte, F
	bcf		LCD_RW
	BANK1
	movlw	0x0F
	movwf	TRISB
	BANK0
	movfw	byte
	ATIVAR_INT
	return

Aguardar_BF_LCD					;Sub-rotina para esperar o display LCD ficar desocupado
	call	Ler_byte_LCD
	btfsc	byte, 7
	goto	Aguardar_BF_LCD
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
	return							;Retorna da sub-rotina



									;Fim do programa
END