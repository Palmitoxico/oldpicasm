processor 16F73
include <p16f73.inc>
__config _WDT_OFF & _PWRTE_ON


Cont1		EQU 0x20			;Define as constantes de endereço 
Cont2		EQU 0x21
byte		EQU 0x22
Letra		EQU 0x23
delay1		EQU 0x2A
delay2		EQU 0x2B	
delay3		EQU 0x2C
Endereco	EQU 0x2E
Endereco2	EQU 0x2F
Valor		EQU 0x30
Segundos	EQU 0x31
Minutos		EQU 0x32
Horas		EQU 0x33

#Define  Endereco_EEPROM_escrita b'10100000'
#Define  Endereco_EEPROM_leitura b'10100001'



org 0x0000
								;Definição de macro-comandos
BANK1 macro						;
bsf    STATUS,RP0 			    ;Muda para o banco 1
Endm							;
								;
BANK0 macro						;
bcf   STATUS,RP0  			    ;Volta ao banco 0
Endm							;
								;
E_1 macro						;Coloca o pino enable em 1
bsf		PORTE ,2				;
Endm							;
								;
E_0 macro						;Coloca o pino enable em 0
bcf		PORTE ,2				;
Endm							;
								;
RS_1 macro						;Coloca o pino RS em 1
movlw	0x05					;
movwf	PORTE					;
Endm							;
								;
RS_0 macro						;Coloca o pino RS em 0
movlw	0x04					;
movwf	PORTE					;
Endm							;
								;
RW_1 macro						;Coloca o pino RW em 1
bsf  PORTE , 1					;
Endm							;
								;
RW_0 macro						;Coloca o pino RW em 0
bcf  PORTE , 1					;
Endm							;
								;
BF_E macro						;Configura como entrada a porta B
BANK1							;
movlw	0xFF					;
movwf	TRISB					;
BANK0							;
Endm							;
								;
BF_S macro						;Configura como saida o nibble alto da porta B
BANK1							;
clrf  TRISB						;
BANK0							;
Endm							;


Main
movlw	b'00101000'
movwf	SSPCON
clrf	PORTB				;Limpa a porta

BANK1						;Vai para o banco 1 da memória
clrf	TRISB				;Toda a porta B como saída
bcf		SSPSTAT,CKE
movlw	0x02
movwf	SSPADD
BANK0
bcf		SSPSTAT,2
clrf	Endereco
;clrf	Endereco2

	movlw	0x30
	call	Gravar_RTC

	sleep



	Gravar_RTC
	movwf	Valor
	BANK1
	bsf		SSPSTAT,S
	btfsc	SSPSTAT,S
	goto	$-1
	BANK0

	movlw	Endereco_EEPROM_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Valor,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPSTAT,P
	btfsc	SSPSTAT,P
	goto	$-1
	BANK0
	return




	Ler_RTC
	BANK1
	bsf		SSPSTAT,S
	btfsc	SSPSTAT,S
	goto	$-1
	BANK0

	movlw	Endereco_EEPROM_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
;	bsf		SSPCON2,RSEN
;	btfsc	SSPCON2,RSEN
	goto	$-1
	BANK0

	movlw	Endereco_EEPROM_leitura
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
;	bsf		SSPCON2,RCEN
	BANK0


	call	Espera_I2C
	movf	SSPBUF,0
	movwf	Valor
	call	Enviar_NACK
	call	Espera_I2C
	BANK1
	bsf		SSPSTAT,P
	btfsc	SSPSTAT,P
	goto	$-1
	BANK0
	movf	Valor,0
	return

	Espera_I2C
	BANK1
	btfsc	SSPSTAT,R_W
	goto	$-1
;	movf	SSPCON2,0
;	andlw	B'00011111'
;	btfss	STATUS,Z
;	goto	$-3
	BANK0
	return

	Enviar_NACK
	BANK1
;	bsf		SSPCON2,ACKDT
;	bsf		SSPCON2,ACKEN
	BANK0
	return

END