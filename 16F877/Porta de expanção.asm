processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF



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
ORG  0X0000

clrf	PORTB
clrf	PORTC

BANK1
clrf	TRISB
movlw	0xC0
movwf	TRISC
BANK0

END								;Fim do programa