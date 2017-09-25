;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Multiplexação com displays de 7-Seg  			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Oscilador interno de 4MHZ                     ;;
;;												;;
;;                               				;;
;;                        						;;
;;												;;
;;												;;
;;Data: 18/03/2012  							;;
;;												;;
;;PIC 16F628    								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628
include <p16F628.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _INTRC_OSC_NOCLKOUT & _BODEN_ON
ERRORLEVEL 2


cblock 0x20
W_2			;Byte para o armazenamento temporário de W
STATUS_2	;Byte para o armazenamento temporário do STATUS
DSP_dado	;Byte para o armazenamento do número a ser mostrado no display (em BCD)
endc

#define		DSP_D			PORTA,6		;Pino de seleção do display de dezena
#define		DSP_U			PORTA,7		;Pino de seleção do display de unidade
#define		DSP_P			PORTB		;Porta para os dígitos



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



org 0x0000						;Vetor de RESET
clrf	PCLATH					;Limpa o PCLATH
goto	Main					;Vai para a rotina principal

ORG  0X0004						;Rotina da interrupção
movwf	W_2						;Guarda o registrador W 
movf	STATUS, W				;
movwf	STATUS_2				;Guarda o registrador STATUS

btfss	INTCON,T0IF				;Testa se a interrupção é do timer 0
goto	FIM_TMR0				;Se não for, pula para o fim da rotina
bcf		INTCON,T0IF				;Se for, limpa o flag da interrupção

btfss	DSP_U					;Verifica qual display será ligado/desligado
goto	Display_Dezena			;Se for o display da Dezena, vai para a rotina da Dezena
bcf		DSP_U					;Desativa o display da Unidade
swapf	DSP_dado				;Inverte a dezena com a unidade (para poder converter o número das dezenas em 7 SEG)
movf	DSP_dado, W				;Carrega em W o valor do número 
andlw	0x0F					;Deixa apenas o LOW nibble para ser convertido para 7 SEG
call	Converter_7SEG			;Chama a sub-rotina de conversão para 7 SEG
movwf	DSP_P					;Carrega o valor convertido na porta do display
bsf		DSP_D					;Ativa o display da Dezena
swapf	DSP_dado				;Troca os dígitos (Dezena e Unidade) para a posição correta
goto	Fim_Display_Dezena		;Vai para o fim da rotina

Display_Dezena:
bcf		DSP_D					;Desativa o display da Dezena
movf	DSP_dado, W				;Carrega o número em BCD a ser mostrado no display
andlw	0x0F					;Deixa apenas o LOW nibble para ser convertido para 7 SEG
call	Converter_7SEG			;Chama a sub-rotina de conversão para 7 SEG
movwf	DSP_P					;Carrega o valor convertido na porta do display
bsf		DSP_U					;Ativa o display da Unidade
Fim_Display_Dezena:	



movlw	.131					;
movwf	TMR0					;Recarrega a contagem do timer 0
FIM_TMR0:



movf	STATUS_2,W				;Recupera o registrador STATUS
movwf	STATUS					;
movf	W_2						;Recupera o registrador W
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Fim do tratamento das interrupções, começo da rotina princiapal.
Main
	BANK1						;Vai para o banco 1 de memória
	movlw	b'11000101'			;Configura o timer 0 com um prescaler 1:64
	movwf	OPTION_REG			;

	bcf		DSP_D				;Configura como saída os pinos de controle do display
	bcf		DSP_U				;
	clrf	DSP_P				;
	clrf	TRISA
	BANK0

	clrf	PORTA				;Limpa a porta A
	clrf	PORTB				;Limpa a porta B

	movlw	.131				;Configura o timer 0 para gerar 125 interrupções por segundo (125Hz)
	movwf	TMR0				;((OSC/4)/PRESCALER)/(256-TMR0) -> (4MHz/4)/64)/(256-131) = 125Hz

	movlw	b'10100000'			;Ativa a interrupção do timer 0
	movwf	INTCON				;

	movlw	0x82				;Coloca o número "12" no display
	movwf	DSP_dado			;


Loop:

	goto	Loop


sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas

Converter_7SEG:
	addwf	PCL,F
	retlw	b'00111111'	;0
	retlw	b'00000110'	;1
	retlw	b'01011011'	;2
	retlw	b'01001111'	;3
	retlw	b'01100110'	;4
	retlw	b'01101101'	;5
	retlw	b'01111101'	;6
	retlw	b'00000111'	;7
	retlw	b'01111111'	;8
	retlw	b'01101111'	;9
	retlw	b'01110111'	;A
	retlw	b'01111100'	;B
	retlw	b'00111001'	;C
	retlw	b'01011110'	;D
	retlw	b'01111001'	;E
	retlw	b'01110001'	;F



END