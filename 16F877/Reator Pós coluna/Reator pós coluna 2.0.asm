;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Reator pós coluna                             ;;
;;Versão do programa: 2.31                      ;;
;;Versão do hardware: 1.3                       ;;
;;Desenvolvido por Augusto Fraga Giachero       ;;
;;Cristal 4MHz                                  ;;
;;                                              ;;
;;                                              ;;
;;Data de início: 13/12/2011                    ;;
;;Data da última atualização: 11/01/2012        ;;
;;                                              ;;
;;                                              ;;
;;PIC 16F877 ou 16f877A                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BODEN_OFF & _CP_All

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
delay1_int
delay2_int
delay3_int
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
Media_Fluxo_resultado
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
Nibble
Temp1
OffSet_Str_L
OffSet_Str_H
EnderecoStr_L
EnderecoStr_H
S_Char
Divisor_L
Divisor_H
Dividendo_L
Dividendo_H
Resultado_L
Resultado_H
Base_Index_L
Base_Index_H
Temp2
Multiplicador_L
Multiplicador_H
Multiplicando_L
Multiplicando_H
endc



#define Multiplicador_FLX	.50						;Define a fração para ajustar o fluxo
#define Divisor_FLX			.74					;
#define OffSet_AD_Temp		0xF140					;Valor do off set do AD para temperatura = -3776
#define OffSet_AD_FLX		0xE4					;Valor do off set do AD para fluxo = -28
#define	Temperatura_atual	Media_Temp_resultado_H	;
#define	Atualizar_DSP		VAR_BIT, 0
#define	Botao_press			VAR_BIT, 1
#define	RES_Chave			VAR_BIT, 2
#define	Modo_VAD			VAR_BIT, 3
#define B_Select			PORTC, 6
#define B_Incrementar		PORTC, 5
#define B_Decrementar		PORTC, 4
#define RES_PIN				PORTD, 2
#define BIP_PIN				PORTD, 1

;#define	LCD_RW	PORTE,1
;#define	LCD_RS	PORTE,0
;#define	LCD_E	PORTE,2

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3
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
								;
DESATIVAR_INT macro				;
bcf		INTCON,GIE				;
Endm							;
								;
ATIVAR_INT macro				;
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

movfw	delay1
movwf	delay1_int
movfw	delay2
movwf	delay2_int
movfw	delay3
movwf	delay3_int

BANK0
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
bcf		T1CON,0					;Para a contagem do timer 1

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

call	Delay_20us


movlw	b'01000001'				;Media da temperatura
movwf	ADCON0

call	Delay_20us


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


call	Delay_20us



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

call	Delay_20us

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
movlw	.64							;Após somar 64 medidas do conversor AD, divide por 64 para obter a média
movwf	Cont_AD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Coloca o off set da temperatura
movlw	LOW(OffSet_AD_Temp)			;Soma uma variável inteira de 16 bits (-32768 a +32767)
addwf	Media_Temp_L, F
btfsc	STATUS,C
incf	Media_Temp_H, F
movlw	HIGH(OffSet_AD_Temp)
addwf	Media_Temp_H, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Move o valor da soma para as variáveis finais (que serão divididas por 64)
movf	Media_Temp_H, W
movwf	Media_Temp_resultado_H

movf	Media_Temp_L, W
movwf	Media_Temp_resultado_L

movf	Media_Fluxo_H, W
movwf	Media_Fluxo_resultado

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Trecho das divisões sucessivas, não é necessário dividir a temperatura, já que o valor inteiro está no byte mais significativo
clrc								;Limpa o bit carry
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

clrc								;Limpa o bit carry
rlf		Media_Fluxo_resultado_L, F
rlf		Ajuste_media_L, F
rlf		Ajuste_media_H, F

rlf		Media_Fluxo_resultado_L, F
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Tratamento dos botões
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina de superaquecimento
movlw	.140					;Caso a temperatura seja maior que 140ºC, aciona o alarme e indica uma mensagem de superaquecimento
subwf	Temperatura_atual, W
btfss	STATUS, C
goto	Fim_MSG_1
bcf		RES_PIN

movlw	Low(Aviso_01)
movwf	OffSet_Str_L
movlw	High(Aviso_01)
movwf	OffSet_Str_H
call	Enviar_String
Alerta_01
bsf		BIP_PIN
call	Delay_500ms
bcf		BIP_PIN
call	Delay_500ms
goto	Alerta_01
Fim_MSG_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movlw	.39						;Caso o valor do set point esteja igual a 39, não controlar a temperatura (controle desligado)
subwf	Temperatura_definida, W	;
btfsc	STATUS, Z				;
goto	Fim_controle_ON_OFF		;
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

bsf		T1CON,0					;Continua a contagem do timer 1

movfw	STATUS_2
movwf	STATUS
movfw	W_2


movfw	delay1_int
movwf	delay1
movfw	delay2_int
movwf	delay2
movfw	delay3_int
movwf	delay3

retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Constantes
Aviso_01:
DT "/LSuperaquecimento",0
Inicial_01:
DT "/LT:000",0xDF,"C SP:OFF",0xDF,"C/2F:0.00 ml//min",0
Inicial_02:
DT "/LA0:     A1:/2A2:",0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal
Main
	clrf	PORTB				;Limpa a porta B
	clrf	PORTE				;Limpa a porta E
	clrf	Pontencia_RES		;Potência 0
	clrf	Temperatura_atual	;Limpa a variável de temperatura
	bcf		Modo_VAD			;Coloca o modo Valor AD desligado (default)

	movlw	.64					;Carrega
	movwf	Cont_AD

	RES_OFF						

	movlw	b'01000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
	movwf	ADCON0


	movlw	.39
	movwf	Temperatura_definida


	BANK1						;Seleciona o banco 1 da RAM
	movlw	b'10000010'			;Configura a porta A como entrada analógica
	movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
	clrf	TRISB				;Define a porta B como saida
	clrf	TRISE				;Defina a porta E como saida
	clrf	TRISD				;Define a porta D como saida (controle do relé de estado sólido/BIP)	
	BANK0						;Seleciona o banco 0 da RAM
	bcf		RES_PIN
	bsf		BIP_PIN

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
	bcf		BIP_PIN
	btfsc	Modo_VAD
	goto	Modo_VAD_DSP


	movlw	Low(Inicial_01)
	movwf	OffSet_Str_L
	movlw	High(Inicial_01)
	movwf	OffSet_Str_H
	call	Enviar_String







	goto	Modo_normal_DSP
Modo_VAD_DSP

	movlw	Low(Inicial_02)
	movwf	OffSet_Str_L
	movlw	High(Inicial_02)
	movwf	OffSet_Str_H
	call	Enviar_String


Modo_normal_DSP



	RES_OFF

	movlw	.0					;Potência máxima como padrão durante a inicialização do programa
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

	movlw	.39
	subwf	Temperatura_definida, W
	btfsc	STATUS, Z
	goto	Fim_atualizar_temp

	movlw	0x0B
	call	Endereco_LCD

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

	movlw	0x0B
	call	Endereco_LCD

	movlw	'O'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

	movlw	'F'
	call	Enviar_char_lcd

Fim_Res_Desligado

Calculo_Pressao
;	movf	Media_Pressao_resultado_L, W
;	movwf	Valor_L
;	movf	Media_Pressao_resultado_H, W
;	movwf	Valor_H
;
;	movlw	.170
;	subwf	Valor_L, F
;	btfss	STATUS, C
;	decf	Valor_H, F
;
;
;	rlf		Valor_L, F
;	rlf		Valor_H, F
;
;	clrf	Pressao_L
;	clrf	Pressao_H
;
;	goto	$+4
;Divsao_por_3
;	incfsz	Pressao_L, F
;	goto	$+2
;	incf	Pressao_H, F
;	movlw	.3
;	subwf	Valor_L, F
;	btfsc	STATUS, C
;	goto	Divsao_por_3
;	movlw	.1
;	subwf	Valor_H, F
;	btfsc	STATUS, C	
;	goto	Divsao_por_3
;
;	movlw	0x4A
;	call	Endereco_LCD
;
;	movf	Pressao_L, W
;	movwf	VAR_L
;
;	movf	Pressao_H, W
;	movwf	VAR_H
;
;	call	Converter_Bin_Dec_16bit

;	movf	DSP3, W	
;	call	Enviar_char_lcd
;
;	movf	DSP2, W	
;	call	Enviar_char_lcd
;
;	movf	DSP1, W	
;	call	Enviar_char_lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Cálculo do fluxo
Calculo_Fluxo

	movlw	OffSet_AD_FLX				;Carrega o offset do fluxo
	addwf	Media_Fluxo_resultado, W	;Soma o offset do fluxo com o valor do conversor AD
	btfss	STATUS,C					;Verifica se a soma deu negativa
	clrw								;Se sim, zera o valor do fluxo


	movwf	Multiplicando_L

	clrf	Multiplicando_H

	movlw	LOW(Multiplicador_FLX)
	movwf	Multiplicador_L
	movlw	HIGH(Multiplicador_FLX)
	movwf	Multiplicador_H

	call	MULV16

	movf	Resultado_L, W
	movwf	Dividendo_L

	movf	Resultado_H, W
	movwf	Dividendo_H

	movlw	LOW(Divisor_FLX)
	movwf	Divisor_L

	movlw	HIGH(Divisor_FLX)
	movwf	Divisor_H

	call	DIVV16					;Chama a sub-rotina para dividir o numero

	movf	Resultado_L, W
;	movwf	Fluxo_L

;	movf	Fluxo_L, W
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	

	


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
	movlw	b'00000001'
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
	movlw	0xF0
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
	movlw	0x01
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

DIVV16							;Sub-rotina para divisão em 16 bits
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
	movwf   Temp2
	movf    Divisor_L,W
	subwf   Dividendo_L
	btfss   STATUS,C
	incf    Temp2,F
	movf    Temp2,W
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

Delay_20us
			;16 cycles
	movlw	0x05
	movwf	delay1
Delay_20us_0
	decfsz	delay1, f
	goto	Delay_20us_0

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
	return							;Retorna da sub-rotina

Delay_500ms
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_500ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_500ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


									;Fim do programa
END