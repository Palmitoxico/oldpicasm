;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Template PIC16F628 TÍTULO AQUI!               ;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Tipo de oscilador                             ;;
;;												;;
;;Comentários                    				;;
;;                        						;;
;;												;;
;;												;;
;;Data:   /  /      							;;
;;												;;
;;PIC 16F628    								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628
include <p16F628.inc>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Configuração dos fusíveis
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _INTRC_OSC_NOCLKOUT & _BODEN_ON & _CPD_OFF & _MCLRE_ON

;_FOSC_LP:				LP oscillator: Low-power crystal on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_LP_OSC:				LP oscillator: Low-power crystal on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_XT:				XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_XT_OSC:				XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_HS:				HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_HS_OSC:				HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN
;_FOSC_ECIO:			EC: I/O function on RA6/OSC2/CLKOUT pin, CLKIN on RA7/OSC1/CLKIN
;_EXTCLK_OSC:			EC: I/O function on RA6/OSC2/CLKOUT pin, CLKIN on RA7/OSC1/CLKIN
;_FOSC_INTOSCIO:		INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTOSC_OSC_NOCLKOUT:	INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTRC_OSC_NOCLKOUT:	INTOSC oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_FOSC_INTOSCCLK:		INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTOSC_OSC_CLKOUT:	INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_INTRC_OSC_CLKOUT:		INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN
;_FOSC_EXTRCIO:			RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_RC_OSC_NOCLKOUT:		RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_ER_OSC_NOCLKOUT:		RC oscillator: I/O function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_FOSC_EXTRCCLK:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_RC_OSC_CLKOUT:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN
;_ER_OSC_CLKOUT:		RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, Resistor and Capacitor on RA7/OSC1/CLKIN

;_WDTE_OFF:				WDT disabled
;_WDT_OFF:				WDT disabled
;_WDTE_ON:				WDT enabled
;_WDT_ON:				WDT enabled

;_PWRTE_ON:				PWRT enabled
;_PWRTE_OFF:			PWRT disabled

;_MCLRE_OFF:			RA5/MCLR/VPP pin function is digital input, MCLR internally tied to VDD
;_MCLRE_ON:				RA5/MCLR/VPP pin function is MCLR

;_BOREN_OFF:			BOD disabled
;_BODEN_OFF:			BOD disabled
;_BOREN_ON:				BOD enabled
;_BODEN_ON:				BOD enabled

;_LVP_OFF:				RB4/PGM pin has digital I/O function, HV on MCLR must be used for programming
;_LVP_ON:				RB4/PGM pin has PGM function, low-voltage programming enabled

;_CPD_ON:				Data memory code-protected
;DATA_CP_ON:			Data memory code-protected
;_CPD_OFF:				Data memory code protection off
;DATA_CP_OFF:			Data memory code protection off

;_CP_ON: 0000h to 07FFh code-protected
;_CP_OFF: Code protection off


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ERRORLEVEL 2


cblock 0x20
W_2			;Byte para o armazenamento temporário de W
STATUS_2	;Byte para o armazenamento temporário do STATUS
endc



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
								;
BANK2 macro						;
bcf		STATUS,RP0 			    ;Muda para o banco 2
bsf		STATUS,RP1				;
Endm							;
								;
BANK3 macro						;
bsf		STATUS,RP0  			;Muda para o banco 3
bsf		STATUS,RP1				;
Endm							;




org 0x0000							;Vetor de RESET
	clrf	PCLATH					;Limpa o PCLATH
	goto	Main					;Vai para a rotina principal

ORG  0X0004							;Rotina da interrupção
	movwf	W_2						;Guarda o registrador W 
	movf	STATUS, W				;
	movwf	STATUS_2				;Guarda o registrador STATUS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Testa qual interrupção ocorreu e desvia para sua respectiva rotina
	BANK0						;;
	btfsc	INTCON,T0IF			;;
	goto	TMR0_INT			;;
								;;
	btfsc	INTCON,INTF			;;
	goto	RB0_INT				;;
								;;
	btfsc	INTCON,RBIF			;;
	goto	PORTB_INT			;;
								;;
	btfsc	PIR1,EEIF			;;
	goto	EEPROM_INT			;;
								;;
	btfsc	PIR1,CMIF			;;
	goto	COMPARATOR_INT		;;
								;;
	btfsc	PIR1,RCIF			;;
	goto	RX_USART_INT		;;
								;;
	btfsc	PIR1,TXIF			;;
	goto	TX_USART_INT		;;
								;;
	btfsc	PIR1,CCP1IF			;;
	goto	CCP1_INT			;;
								;;
	btfsc	PIR1,TMR2IF			;;
	goto	TMR2_INT			;;
								;;
	btfsc	PIR1,TMR1IF			;;
	goto	TMR1_INT			;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Fim_INT:
	movf	STATUS_2,W				;Recupera o registrador STATUS
	movwf	STATUS					;
	movf	W_2						;Recupera o registrador W
	retfie							;Termina a rotina da interrupção

TMR0_INT:							;Interrupção do timer 0
	bcf		INTCON,T0IF

	goto	Fim_INT

RB0_INT:							;Interrupção externa RB0
	bcf		INTCON,INTF

	goto	Fim_INT

PORTB_INT:							;Interrupção externa por mudança dos pinos RB4 a RB7
	bcf		INTCON,RBIF

	goto	Fim_INT

EEPROM_INT:							;Interrupção da gravação do memória eeprom interna
	bcf		PIR1,EEIF

	goto	Fim_INT

COMPARATOR_INT:						;Interrupção do módulo comparador
	bcf		PIR1,CMIF

	goto	Fim_INT

RX_USART_INT:						;Interrupção da USART por recepção de dados
	bcf		PIR1,RCIF

	goto	Fim_INT

TX_USART_INT:						;Interrupção da USART por envio de dados
	bcf		PIR1,TXIF

	goto	Fim_INT

CCP1_INT:							;Interrupção CCP (Capture Compare)
	bcf		PIR1,CCP1IF

	goto	Fim_INT

TMR2_INT:							;Interrupção do timer 2
	bcf		PIR1,TMR2IF

	goto	Fim_INT

TMR1_INT:							;Interrupção do timer 1
	bcf		PIR1,TMR1IF

	goto	Fim_INT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Fim do tratamento das interrupções, começo da rotina princiapal.
Main
	BANK1							;Vai para o banco 1 de memória

	BANK0

	

Loop:

	goto	Loop


sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas



END