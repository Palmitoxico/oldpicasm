processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _HS_OSC 

Disp1 EQU 0x20
Disp2 EQU 0x21
Disp3 EQU 0x22
Disp4 EQU 0x23



org 0x0000
BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm


Main
	clrf   PORTA			   ;Limpa a porta a	 
	clrf   PORTD			   ;Limpa a porta d	 
	movlw  0x06                ;Configura a porta a para  digital 
	BANK1
	movwf  ADCON1  	 	  
	clrf   TRISA			   ;Toda a porta a como saída
	clrf   TRISD
	BANK0	
	Loop
	movlw  0x01
	movwf  PORTD
	bsf    PORTD , 4
	bsf    PORTD , 5
	bsf    PORTD , 6
	bsf    PORTD , 7
	goto   Loop
END