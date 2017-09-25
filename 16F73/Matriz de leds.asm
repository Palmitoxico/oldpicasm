processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON


cont1 	EQU  0x20
cont2 	EQU  0x21
byte1 	EQU  0x22
byte2 	EQU  0x23
byte3 	EQU  0x24
byte4 	EQU  0x25
byte5 	EQU  0x26
byte6 	EQU  0x27
byte7 	EQU  0x28
byte8 	EQU  0x29
posicao EQU  0x2A
desloc  EQU  0x2B





org 0x0000
BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm


Main
	clrf	PORTB				;Limpa as portas b e c
	clrf	PORTC			  
	movlw	0x06				;Configura a porta a para  digital 
	BANK1
	movwf	ADCON1  	 	  
	clrf	TRISB				;Toda a porta b como saída
	clrf	TRISC				;Toda a porta c como saída
	BANK0
;	movlw	B'00000000'			;Carrega a imagem:
;	movwf	byte1				;
;	movlw	B'11111000'			;00000000	        
;	movwf	byte2				;00010000	     1    
;	movlw	B'00010100'			;00101000	  1     1   
;	movwf	byte3				;01000100	 1       1  
;	movlw	B'00010010'			;01111100	 1 1 1 1 1  
;	movwf	byte4				;01000100	 1       1  
;	movlw	B'00010100'			;01000100	 1       1  
;	movwf	byte5				;01000100	 1       1  
;	movlw	B'11111000'			;(Letra A)
;	movwf	byte6				;
;	movlw	B'00000000'			;
;	movwf	byte7				;
;	movlw	B'00000000'			;
;	movwf	byte8

	bsf		PORTC , 0
	bsf		byte1 , 0
	Loop
	btfss	PORTA , 2
	goto	fim1 

;	movf	byte1 , 0
;	clrf	byte1
;	movwf	byte8 	

	movf	byte2 , 0
	clrf	byte2
	movwf	byte1 	

	movf	byte3 , 0
	clrf	byte3
	movwf	byte2 	

	movf	byte4 , 0
	clrf	byte4
	movwf	byte3 	

	movf	byte5 , 0
	clrf	byte5
	movwf	byte4

	movf	byte6 , 0
	clrf	byte6
	movwf	byte5 	

	movf	byte7 , 0
	clrf	byte7
	movwf	byte6 	

	movf	byte8 , 0
	clrf	byte8
	movwf	byte7 	

	fim1

	btfsc	PORTA , 2
	goto	fim1



	btfss	PORTA , 5
	goto	fim2 

	movf	byte7 , 0
	clrf	byte7
	movwf	byte8  

	movf	byte6 , 0
	clrf	byte6
	movwf	byte7 

	movf	byte5 , 0
	clrf	byte5
	movwf	byte6 

	movf	byte4 , 0
	clrf	byte4
	movwf	byte5 

	movf	byte3 , 0
	clrf	byte3
	movwf	byte4 

	movf	byte2 , 0
	clrf	byte2
	movwf	byte3 

	movf	byte1 , 0
	clrf	byte1
	movwf	byte2 


	fim2

	btfsc	PORTA , 5
	goto	fim2

	btfss	PORTA , 3
	goto	fim3 
	rrf		byte1,1
	rrf		byte2,1
	rrf		byte3,1
	rrf		byte4,1
	rrf		byte5,1
	rrf		byte6,1
	rrf		byte7,1
	rrf		byte8,1	
	fim3

	btfsc	PORTA , 3
	goto	fim3

	btfss	PORTA , 4
	goto	fim4
	rlf		byte1,1
	rlf		byte2,1
	rlf		byte3,1
	rlf		byte4,1
	rlf		byte5,1
	rlf		byte6,1
	rlf		byte7,1
	rlf		byte8,1	
	fim4

	btfsc	PORTA , 4
	goto	fim4


	movf	byte1 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1    
	movf	byte2 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte3 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte4 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte5 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte6 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte7 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	movf	byte8 , 0
	movwf	PORTB				;Move W para a porta b
	nop
	clrf	PORTB
	rlf		PORTC , 1
	rlf		PORTC , 1



;	clrf   byte1
;	clrf   byte2
;	clrf   byte3
;	clrf   byte4
;	clrf   byte5
;	clrf   byte6
;	clrf   byte7
;	clrf   byte8

;	movf   posicao , 0
;	sublw  0x08
;	btfss  STATUS , 0
;	goto   fim6
;	bsf    byte1 , 0
;	movf   posicao , 0
;	movwf  desloc
;	inicio1
;	decfsz desloc , 1
;	goto   bloco1
;	goto   fim_b
;	bloco1
;	rlf    byte1 , 1
;	goto   inicio1
;	fim6
;
;	movf   posicao , 0
;	sublw  0x10
;	btfss  STATUS , 0
;	goto   fim7
;	
;	bsf    byte2 , 0
;	movf   posicao , 0
;	sublw  0x08
;	movwf  desloc
;	inicio2
;	decfsz desloc , 1
;	goto   bloco2
;	goto   fim_b
;	bloco2
;	rlf    byte2 , 1
;	goto   inicio2
;	fim7
;
;	movf   posicao , 0
;	sublw  0x18
;	btfss  STATUS , 0
;	goto   fim8
;	bsf    byte3 , 0
;	movf   posicao , 0
;	sublw  0x10
;	movwf  desloc
;	inicio3
;	decfsz desloc , 1
;	goto   bloco3
;	goto   fim_b
;	bloco3
;	rlf    byte3 , 1
;	goto   inicio3
;	fim8
;
;	movf   posicao , 0
;	sublw  0x20
;	btfss  STATUS , 0
;	goto   fim9
;	bsf    byte4 , 0
;	movf   posicao , 0
;	sublw  0x18
;	movwf  desloc
;	inicio4
;	decfsz desloc , 1
;	goto   bloco4
;	goto   fim_b
;	bloco4
;	rlf    byte4 , 1
;	goto   inicio4
;	fim9
;
;	movf   posicao , 0
;	sublw  0x28
;	btfss  STATUS , 0
;	goto   fim10
;	bsf    byte5 , 0
;	movf   posicao , 0
;	sublw  0x20
;	movwf  desloc
;	inicio5
;	decfsz desloc , 1
;	goto   bloco5
;	goto   fim_b
;	bloco5
;	rlf    byte5 , 1
;	goto   inicio5
;	fim10
;
;	movf   posicao , 0
;	sublw  0x30
;	btfss  STATUS , 0
;	goto   fim11
;	bsf    byte6 , 0
;	movf   posicao , 0
;	sublw  0x28
;	movwf  desloc
;	inicio6
;	decfsz desloc , 1
;	goto   bloco6
;	goto   fim_b
;	bloco6
;	rlf    byte6 , 1
;	goto   inicio6
;	fim11
;
;	movf   posicao , 0
;	sublw  0x38
;	btfss  STATUS , 0
;	goto   fim12
;	bsf    byte7 , 0
;	movf   posicao , 0
;	sublw  0x30
;	movwf  desloc
;	inicio7
;	decfsz desloc , 1
;	goto   bloco7
;	goto   fim_b
;	bloco7
;	rlf    byte7 , 1
;	goto   inicio7
;	fim12
;
;
;	bsf    byte8 , 0
;	movf   posicao , 0
;	movwf  desloc
;	inicio8
;	decfsz desloc , 1
;	goto   fim_b
;	rlf    byte8 , 1
;	goto   inicio8

;
;	fim_b
;	btfsc  PORTA , 0
;	goto   Loop
;	clrf   byte1
;	clrf   byte2
;	clrf   byte3
;	clrf   byte4
;	clrf   byte5
;	clrf   byte6
;	clrf   byte7
;	clrf   byte8
;	clrf   posicao
	goto   Loop				   ;

END