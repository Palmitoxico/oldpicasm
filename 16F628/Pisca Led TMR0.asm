;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Pisca led TRM0                                ;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Oscilador interno de 4MHZ                     ;;
;;												;;
;;                               				;;
;;                        						;;
;;												;;
;;												;;
;;Data: 17/04/2012  							;;
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
TRM0_CONT	;Byte para contar o número de interrupções do timer 0
endc

#define		LED1			PORTB,0		;Pino do led1



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

decfsz	TRM0_CONT				;Decrementa a variável TRM0_CONT para obter uma frequência de 2Hz
goto	Recarregar_TRM0			;Caso a variável não fique em zero após o decremento, vai para o fim da rotina do timer 0
movlw	.62						;Recarrega o contador de interrupções
movwf	TRM0_CONT				;

btfss	LED1					;Testa se o led está ligado
goto	$+3						;
bcf		LED1					;Se sim, desliga o led
goto	$+2						;
bsf		LED1					;Se não, liga o led



Recarregar_TRM0:
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


	bcf		LED1				;Configura o pino do LED1 como saída
	BANK0

	movlw	.131				;Configura o timer 0 para gerar 125 interrupções por segundo (125Hz)
	movwf	TMR0				;((OSC/4)/PRESCALER)/(256-TMR0) -> (4MHz/4)/64)/(256-131) = 125Hz

	movlw	b'10100000'			;Ativa a interrupção do timer 0
	movwf	INTCON				;
	
	movlw	.62					;Carrega o contador de interrupções do timer0
	movwf	TRM0_CONT			;TMR0 -->125HZ 125/62 =~ 2Hz
	

Loop:

	goto	Loop


sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas



END