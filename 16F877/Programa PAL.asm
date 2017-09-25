processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON


cont1 EQU 0x20




org 0x0000
BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm


Main
	clrf   PORTE			   ;Limpa a porta E	  
	BANK1
	bcf    TRISE , 0		   ;Pino 0 da porta E como saída
	BANK0
	Loop
	bsf	   PORTE , 0
	call   DELAY_4
	bcf	   PORTE , 0
	call   DELAY_24
	bsf	   PORTE , 0
	call   DELAY_4
	bcf	   PORTE , 0
	call   DELAY_24
	bcf	   PORTE , 0
	call   DELAY_4
	bsf	   PORTE , 0
	goto   Loop				   ;Entra num loop infinito
	
	DELAY_24				   ;Delay de 24 us
	movlw  0x7F
	movwf  cont1
	DELAY_24_3
	decfsz cont1 , 1
	goto   DELAY_24_3
	movlw  0x7F
	movwf  cont1
	DELAY_24_2
	decfsz cont1
	goto   DELAY_24_2
	return
	
	DELAY_4					   ;Delay de 4 us
	movlw  0x14
	movwf  cont1
	DELAY_4_1
	decfsz cont1 , 1
	goto   DELAY_4_1
	return

END