processor 16F84
include <p16f84.inc>
__config _WDT_OFF & _PWRTE_ON


cont_d		EQU 0x20
Endereco0	EQU 0x21
Endereco1	EQU 0x22
Endereco2	EQU 0x23
Disp		EQU 0x24
Dado		EQU 0x25
byte		EQU 0x26
cont2		EQU 0x27




org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm

SCK_1 macro
bsf   PORTA,0   			   ;Pino SCK em 1
Endm

SCK_0 macro
bcf   PORTA,0      			   ;Pino SCK em 0
Endm


SDA_1 macro
bsf   PORTA,1   			   ;Pino SDA em 1
Endm

SDA_0 macro
bcf   PORTA,1      			   ;Pino SDA em 0
Endm

SDA_S macro
BANK1
bcf   TRISA,1				   ;Define SDA como saida
BANK0
Endm

SDA_E macro
BANK1
bsf   TRISA,1				   ;Define SDA como entrada
BANK0
Endm


Main
	clrf   PORTB			   ;Limpa a porta b		
	movlw  0xFC	  		       ;Move a constante 0xFC para W
	BANK1  	 	  		       ;Vai para o banco de memória 1
	movwf  TRISA			   ;Pinos b0 e b1 como saída
	clrf   TRISB
	BANK0					   ;Volta para o banco de memória 0

	clrf	Disp
	clrf	Endereco0
	clrf	Endereco1
	clrf	Endereco2
	movlw	0x01
	movwf	Endereco0
	call	ler_eeprom		   ;Chama a sub-rotina para ler a eeprom
	movf	Dado , W		   ;Move o valor da variável Dado para W
	movwf	PORTB			   ;Move o valor de W para a Porta B
	inicio
	movlw	0x01
	addwf	Endereco0 , 1
	btfsc	STATUS , 0
	addwf	Endereco1 , 1	
	call	ler_eeprom		   ;Chama a sub-rotina para ler a eeprom
	movf	Dado , W		   ;Move o valor da variável Dado para W
	movwf	PORTB			   ;Move o valor de W para a Porta B
	goto    inicio			   ;Loop infinito
	sleep

	DELAY1 	  				   ;Delay de 10 us
	movlw  0x00	  		       ;
	movwf  cont_d	  		   ;
	comeco1	  		           ;
	decfsz cont_d , 1	  	   ;
	goto   comeco1	  		   ;
	return	  		           ;Retorna da sub-rotina

	comecar_i2c				   ;Sub-rotina para iniciar a comunicação I2C
	SCK_0		  		       ;
	SDA_1		  		       ;
	SCK_1		  		       ;
	SDA_0		  		       ;
	SCK_0		  		       ;
	return		  		       ;Retorna da sub-rotina


	parar_i2c				   ;Sub-rotina para finalizar a comunicação I2C
	SCK_0		  		       ;
	SDA_0		  		       ;
	SCK_1		  		       ;
	SDA_1		  		       ;
	return		  		       ;Retorna da sub-rotina

	ler_byte_i2c			   ;Sub-rotina para ler um byte
	SCK_1
	SDA_E
	movlw  0x09		  		   ;
	movwf  cont2		  	   ;
	comeco3		  		       ;
	decfsz cont2 , 1		   ;
	goto   cond3		  	   ;
	goto   fim3		  		   ;
	cond3		  		       ;
	SCK_1		  		       ;
	call   DELAY1		  	   ;
	btfsc  PORTA, 1		  	   ;
	bsf	   byte , 0		       ;
	btfss  PORTA, 1		  	   ;
	bcf	   byte , 0		       ;
	rlf    byte , 1		  	   ;
	SCK_0		  		       ;
	call   DELAY1		  	   ;
	goto   comeco3		  	   ;
	fim3		  		       ;
	SCK_0			  		   ;
	SDA_S
	SDA_0		  		       ;
	rrf    byte , 1		  	   ;
	return			  		   ;Retorna da sub-rotina

	enviar_byte_i2c			   ;Sub-rotina para enviar um byte 
	movwf  byte		  		   ;
	movlw  0x09		  		   ;
	movwf  cont2		  	   ;
	comeco2		  		       ;
	decfsz cont2 , 1		   ;
	goto   cond2		  	   ;
	goto   fim2		  		   ;
	cond2		  		       ;
	SCK_0		  		       ;
	call   DELAY1		  	   ;
	btfsc  byte, 7		  	   ;
	SDA_1		  		       ;
	btfss  byte, 7		  	   ;
	SDA_0		  		       ;
	rlf    byte, 1		  	   ;
	SCK_1		  		       ;
	call   DELAY1		  	   ;
	goto   comeco2		  	   ;
	fim2		  		       ;
	SCK_0			  		   ;
	SDA_0		  		       ;
	return			  		   ;Retorna da sub-rotina

	ack_i2c		  		       ;Sub-rotina para sinal de reconhecimento (ack)
	SDA_0		  		       ;Coloca o pino SDA em 0
	SCK_1		  		       ;Coloca o pino SCK em 1
	SCK_0		  		       ;Coloca o pino SCK em 0
	SDA_1		  		       ;Coloca o pino SDA em 1
	return					   ;Retorna da sub-rotina
	
	nack_i2c		  		   ;Sub-rotina para sinal de não reconhecimento (nack)
	SDA_E					   ;
	SCK_1		  		       ;
	call  DELAY1		  	   ;
	SCK_0					   ;
	SDA_S
	return		  		       ;Retorna da sub-rotina
	
	gravar_eeprom		       ;Sub-rotina para escrever na memória eeprom
	call   comecar_i2c		   ;
	rlf	   Disp , 0		  	   ;
	iorlw  0xA0 		  	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c		  	   ;
	movf   Endereco1 , W	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c		  	   ;
	movf   Endereco2 , W	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c	   		   ;
	movf   Dado , W	           ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c	   		   ;
	call   parar_i2c	   	   ;
	return					   ;Retorna da sub-rotina
	
	ler_eeprom		      	   ;Sub-rotina para ler a memória eeprom
	call   comecar_i2c		   ;
	rlf	   Disp , 0		  	   ;
	iorlw  0xA0 		  	   ;
	andlw  0xAE				   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c		  	   ;
	movf   Endereco1 , W	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c		  	   ;
	movf   Endereco0 , W	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c	   		   ;
	call   comecar_i2c		   ;
	rlf	   Disp , 0		  	   ;
	iorlw  0xA1 		  	   ;
	call   enviar_byte_i2c	   ;
	call   ack_i2c		  	   ;
	call   ler_byte_i2c	       ;
	movf   byte , W	           ;
	movwf  Dado		           ;
	call   nack_i2c	   		   ;
	call   parar_i2c	   	   ;
	return					   ;Retorna da sub-rotina


END