;Comunicação serial (escravo)

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON


cont_d		EQU 0x20
Dado		EQU 0x21
byte		EQU 0x22
cont2		EQU 0x23




org 0x0000
BANK1 macro
bsf   STATUS,RP0 			  	;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			  	;Volta ao banco 0
Endm

SCK_1 macro
bsf   PORTB,0   			  	;Pino SCK em 1
Endm

SCK_0 macro
bcf   PORTB,0      			  	;Pino SCK em 0
Endm


SDA_1 macro
bsf   PORTB,1   			  	;Pino SDA em 1
Endm

SDA_0 macro
bcf   PORTB,1      			  	;Pino SDA em 0
Endm




Main
	clrf   PORTB			  	;Limpa a porta b	
	clrf   PORTD			  	;Limpa a porta d	
	movlw  0x0D	  		      	;Move a constante 0xFC para W
	BANK1  	 	  		      	;Vai para o banco de memória 1
	movwf	TRISE			  	;Pino b1 como saída
	clrf	TRISD				;Toda a porta d como saída
	movlw	b'11000010'
	movwf	ADCON1
	BANK0						;Volta para o banco de memória 0
;	movlw	b'01010101'
	inicio
	btfss	PORTE,2
	goto	$-1
	bsf		PORTE,1
	btfsc	PORTE,2
	goto	$-1
	bcf		PORTE,1
	call	ler_byte
	movf	Dado,0
	movwf	PORTD
	movf	PORTC,0
	call	enviar_byte
	goto	inicio
	sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Sub-rotinas
	ler_byte
	movlw	0x08
	movwf	cont_d
	clrf	Dado
	init_1
	rrf		Dado,1
	btfss	PORTE,0
	goto	$-1
	btfss	PORTE,2
	goto	$+3
	bsf		Dado,7
	goto	$+2
	bcf		Dado,7
	btfsc	PORTE,0
	goto	$-1	
	decfsz	cont_d,1
	goto	init_1
	return

	enviar_byte
	movwf	Dado
	movlw	0x08
	movwf	cont_d
	init_2
	btfss	PORTE,0
	goto	$-1
	btfss	Dado,0
	goto	$+3
	bsf		PORTE,1
	goto	$+2
	bcf		PORTE,1
	rrf		Dado,1
	btfsc	PORTE,0
	goto	$-1	
	decfsz	cont_d,1
	goto	init_2
	return
	

END