;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;												;;
;;												;;
;;Data: 06/04/2010								;;
;;												;;
;;PIC 16F877									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


Cont1		EQU 0x20					;Define as constantes de endereço
Endereco_H	EQU 0x21
Endereco_L	EQU 0x22
Dado_EEPROM EQU	0x23
Status_SPI	EQU	0x24

;Definição de constantes

#Define CS PORTE,2

;Definições de comandos para a memória

#Define SPI_ler_memoria				0x03
#Define SPI_escrever_memoria		0x02
#Define SPI_ler_status				0x05
#Define SPI_escrever_status			0x01
#Define SPI_habilitar_escrita		0x06
#Define SPI_desabilitar_escrita		0x04
#Define SPI_apagar_memoria			0xC7


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
BANK2 macro						;
bcf		STATUS,RP0				;
bsf		STATUS,RP1 			    ;Muda para o banco 2
Endm							;
								;
BANK1 macro						;
bsf		STATUS,RP0 			    ;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK0 macro						;
bcf		STATUS,RP0  			    ;Volta ao banco 0
bcf		STATUS,RP1				;
Endm							;
								;
								;
ORG  0X0000						;
Main							;Rotina principal=
	clrf	PORTB				;Limpa a porta B
	clrf	PORTC				;Limpa a porta C	
	clrf	PORTD				;Limpa a porta D
	clrf	PORTE				;Limpa a porta E	  
	BANK1						;Vai para o banco 1 da memória
	clrf	TRISB
	BANK0						;vai para o banco 0 da memória
	call	Inicializar_SPI

	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x00
	movwf	Endereco_L
	movlw	0x14
	call	Gravar_eeprom_SPI
	call	Aguardar_escrita_EEPROM_SPI
	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x00
	movwf	Endereco_L
	movlw	'F'
	call	Gravar_eeprom_SPI

	call	Aguardar_escrita_EEPROM_SPI
	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x01
	movwf	Endereco_L
	movlw	'A'
	call	Gravar_eeprom_SPI

	call	Aguardar_escrita_EEPROM_SPI
	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x02
	movwf	Endereco_L
	movlw	'T'
	call	Gravar_eeprom_SPI

	call	Aguardar_escrita_EEPROM_SPI
	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x03
	movwf	Endereco_L
	movlw	'1'
	call	Gravar_eeprom_SPI

	call	Aguardar_escrita_EEPROM_SPI
	call	Habilitar_escrita_SPI_eeprom
	movlw	0x00
	movwf	Endereco_H
	movlw	0x04
	movwf	Endereco_L
	movlw	'2'
	call	Gravar_eeprom_SPI



	call	Aguardar_escrita_EEPROM_SPI
	movlw	0x00
	movwf	Endereco_H
	movlw	0x00
	movwf	Endereco_L
	call	Ler_eeprom_SPI
	movwf	PORTB
;	call	Habilitar_escrita_SPI_eeprom
;	call	Gravar_eeprom_SPI
	call	Apagar_eeprom_SPI




goto	$+0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Começo das sub-rotinas

;Sintaxe dos comandos:
;SPI_ler_memoria
;SPI_escrever_memoria
;SPI_ler_status
;SPI_escrever_status
;SPI_habilitar_escrita
;SPI_desabilitar_escrita

Inicializar_SPI
	BANK1
	movlw	b'11010111'
	movwf	TRISC
	movlw	b'10000000'
	movwf	SSPSTAT
	bcf		TRISE,2
	BANK0
	bsf		CS
	movlw	b'00110000'
	movwf	SSPCON
	call	Enviar_byte_SPI
	return

Enviar_byte_SPI
	movwf	SSPBUF
	call	Aguardar_buffer_SPI
	return

Ler_byte_SPI
	call	Aguardar_buffer_SPI
	clrf	SSPBUF
	call	Aguardar_buffer_SPI
	movf	SSPBUF,W
	return

Aguardar_buffer_SPI
	BANK1
	LOOP_
	btfss	SSPSTAT, BF
	goto	LOOP_
	BANK0
	return

Gravar_eeprom_SPI
	movwf	Dado_EEPROM
	bcf		CS
	movlw	SPI_escrever_memoria
	call	Enviar_byte_SPI
	movf	Endereco_H,W
	call	Enviar_byte_SPI
	movf	Endereco_L,W
	call	Enviar_byte_SPI
	movf	Dado_EEPROM,W
	call	Enviar_byte_SPI
	bsf		CS
	return

Ler_eeprom_SPI
	bcf		CS
	movlw	SPI_ler_memoria
	call	Enviar_byte_SPI
	movf	Endereco_H,W
	call	Enviar_byte_SPI
	movf	Endereco_L,W
	call	Enviar_byte_SPI
	call	Ler_byte_SPI
	bsf		CS
	return

Habilitar_escrita_SPI_eeprom
	bcf		CS
	movlw	SPI_habilitar_escrita
	call	Enviar_byte_SPI
	bsf		CS
	return

Desabilita_escrita_SPI_eeprom
	bcf		CS
	movlw	SPI_desabilitar_escrita
	call	Enviar_byte_SPI
	bsf		CS
	return

Ler_status_SPI_eeprom
	bcf		CS
	movlw	SPI_ler_status
	call	Enviar_byte_SPI
	call	Ler_byte_SPI
	bsf		CS
	movwf	Status_SPI
	return

Gravar_status_SPI_eeprom
	movlw	Dado_EEPROM
	bcf		CS
	movlw	SPI_escrever_status
	call	Enviar_byte_SPI
	movf	Dado_EEPROM,w
	call	Enviar_byte_SPI
	bsf		CS
	return

Aguardar_escrita_EEPROM_SPI
	call	Ler_status_SPI_eeprom
	btfsc	Status_SPI,0
	goto	$-2
	return

Apagar_eeprom_SPI
	bcf		CS
	movlw	SPI_apagar_memoria
	call	Enviar_byte_SPI
	bsf		CS
	return
								;
END								;Fim do programa
