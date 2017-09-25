processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON







org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm



Main

	BANK1  	 	  		       
	clrf	TRISB			   
	clrf	TRISC
	BANK0					   


	inicio
	movlw	0x01
	addwf	PORTB , 1
	btfsc	STATUS , 0
	addwf	PORTC , 1	
	goto    inicio			   ;Loop infinito
	sleep




END