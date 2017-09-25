processor 16F676
include <p16f676.inc>
__config _WDT_OFF & _HS_OSC 


org 0x0000
Dado		EQU 0x20
Cont1		EQU 0x21
W2			EQU 0x22
STATUS2		EQU 0x23





;org 0x0000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG 0X0004
movwf	W2
movf	STATUS,0
movwf	STATUS2

decfsz	Cont1 , 1				;A interrupção acontece a cada 100 milisegundos
goto	INT_FIM					;Contador para ajustar o tempo de 100 milisegundos para 1 segundo
movlw	.50						;
movwf	Cont1					;




INT_FIM							;
movlw	0xC3					;
movwf	TMR1H					;Carrega o byte mais significativo do contador do timer 1
								;
movlw	0x50					;Carrega o byte menos significativo do contador do timer 1
movwf	TMR1L					;
movf	STATUS2,0
movwf	STATUS
movf	W2,0
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main							;Rotina principal
	movlw	.50					;
	movwf	Cont1				;
	clrf	Dado
	clrf	PORTC
	movlw   b'111'
	movwf   CMCON
	BANK1						;Vai para o banco 1 da memória
	movlw	0xFF 
	movwf	TRISA 
	clrf	ANSEL
	bcf		OPTION_REG , 7	 	;
	clrf	TRISC				;Toda a porta C como saída
	BANK0						;vai para o banco 0 da memória
								;
	movlw	b'11000000'			;
	movwf	INTCON				;
								;
	movlw	b'00010001'			;
	movwf	T1CON				;
	movlw	0xC3				;
	movwf	TMR1H				;Carrega o byte mais significativo do contador do timer 1
								;
	movlw	0x50				;Carrega o byte menos significativo do contador do timer 1
	movwf	TMR1L				;
								;

								;
;	BANK1						;
;	bsf		PIE1 , 0			;Inicia a contagem do timer 1
;	BANK0						;



Inicio
	

	btfsc	PORTA,2
	goto	$+3
	bsf		PORTC,3
	goto	$+2
	bcf		PORTC,3

	btfsc	PORTA,1
	goto	$+3
	bsf		PORTC,2
	goto	$+2
	bcf		PORTC,2

	
	btfsc	PORTA,0
	goto	$+3
	bsf		PORTC,1
	goto	$+2
	bcf		PORTC,1


	goto	Inicio
	

	nop
	goto	$-1
END