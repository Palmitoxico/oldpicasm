;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Oscilador interno                             ;;
;;												;;
;;												;;
;;												;;
;;Data: 05/04/2012								;;
;;												;;
;;PIC 16F628									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628
include <p16f628.inc>
__CONFIG  _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _LVP_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT & _CP_OFF & DATA_CP_OFF;


CBLOCK 0X20	
  DELAY_0
  DELAY_1
  DELAY_2
 ENDC

#define LED1 PORTA,0						


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
								;
BANK1 macro						;
bsf		STATUS,RP0 			    ;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK0 macro						;
bcf		STATUS,RP0  			;Volta ao banco 0
bcf		STATUS,RP1				;
Endm							;
								;

								;
ORG  0X0000						;Pular para a rotina principal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main							;Rotina principal
	BANK1
	movlw	b'11111110'
	movwf	TRISA
	BANK0
Loop1:
	bsf		LED1
	call	Delay_500ms
	bcf		LED1
	call	Delay_500ms
	goto	Loop1

sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Começo das sub-rotinas
Delay_500ms
			;499994 cycles
	movlw	0x03
	movwf	DELAY_0
	movlw	0x18
	movwf	DELAY_1
	movlw	0x02
	movwf	DELAY_2
Delay_500ms_0
	decfsz	DELAY_0, f
	goto	$+2
	decfsz	DELAY_1, f
	goto	$+2
	decfsz	DELAY_2, f
	goto	Delay_500ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


END								;Fim do programa
