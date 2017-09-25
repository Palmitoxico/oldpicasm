;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Sensor de temperatura via RS232		;;
;;											;;
;; Desenvolvido por Augusto Fraga Giachero  ;;
;;											;;
;;PIC: 16F877								;;
;;Cristal: 20MHz							;;
;;											;;
;;Sensor: LM35, conectado no pino RA0		;;
;;											;;
;;											;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC


dado EQU 0x20


Dado		EQU 0x20					;Define as constantes de endereço
DSP1		EQU 0x21
DSP2		EQU 0x22
DSP3		EQU 0x23
Resultado	EQU 0x24
Cont1		EQU 0x25
Cont2		EQU 0x26
Cont3		EQU 0x27

org 0x0000
BANK1 macro
bsf    STATUS,RP0						;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0						;Volta ao banco 0
Endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Main								;Inicio do programa
										;
	BANK1								;Vai para o banco 1 da RAM
										;
	movlw	B'00100100'					;
	movwf	TXSTA						;Configura a USART
										;Habilita o pino TX
										;Modo assíncrono
	movlw	.128						;
	movwf	SPBRG						;Configura o baud rate para 9600 bits por segundo
										;
	movlw	b'11001110'					;Configura o conversor A/D
	movwf	ADCON1						;
										;
	BANK0								;Volta para o banco 0 da RAM
										;
	movlw	B'10010000'					;
	movwf	RCSTA						;
										;Habilita o pino RX
										;Recepção de 8 bits
										;Fim das configurações
	inicio								;Inicio
										;
	btfss	PIR1 , RCIF					;Aguarda o recebimento de um caracter 
	goto	$-1							;
										;
	movf	RCREG , 0					;Se receber verifica se é igual a letra C
	sublw	'C'							;
	btfss	STATUS , C					;
	goto	$-5							;Se não for a letra C, volta a aguardar o recebimento de um novo caracter
										;Se sim inicia a rotina para enviar a temperatura via RS232
										;
	inicio2								;Inicio da rotina para enviar a temperatura via RS232
										;
	movlw	b'11000101'					;Inicia a conversão analógica digital
	movwf	ADCON0						;
										;
	movlw	0xA0						;Carrega as variáveis para a contagem
	movwf	Cont1						;
	movlw	0x25						;
	movwf	Cont2						;
	movlw	0x23						;
	movwf	Cont3						;
										;
	decfsz	Cont1 , 1					;Inicia a contagem, delay de aproximadamente 2 segundos
	goto	$-1							;
	decfsz	Cont2 , 1					;
	goto	$-3							;
	decfsz	Cont3 , 1					;
	goto	$-5							;
										;
	BANK1								;Vai para o banco 1 da RAM
	bcf		STATUS , C					;Limpa o carry 
	rrf		ADRESL , 1					;Divide o valor lido da conversão A/D por 2
	decf	ADRESL , 1					;Decrementa o valor
	movf	ADRESL , W					;Move o valor de temperatura para o registrador W
	BANK0								;Volta para o banco 0 da RAM
	movwf	Dado						;Move o valor de W para a variável Dado
										;
	call	Converter					;Converte a temperatura em outras 3 variáveis (centena, dezena e unidade)
										;
	movlw	0x30						;Transforma as variáveis de números para caracteres adicionando mais 30h
	addwf	DSP1 , 0					;
	call	enviar_byte_rs232			;Depois envia o valor pela porta serial
										;
	movlw	0x30						;
	addwf	DSP2 , 0					;
	call	enviar_byte_rs232			;
										;
	movlw	0x30						;
	addwf	DSP3 , 0					;
	call	enviar_byte_rs232			;
										;
	movlw	' '							;Envia o caracter "espaço"
	call	enviar_byte_rs232			;
										;
	movlw	0x0D						;Envia ENTER
	call	enviar_byte_rs232			;
										;
										;
	btfss	PIR1 , RCIF					;Verifica se tem algum novo caracter no buffer
	goto	inicio2						;Se não volta para continuar enviando o a temperatura
	movlw	'P'							;Se sim verifica se o caracter recebido foi "P"
	subwf	RCREG , 0					;
	btfss	STATUS , 2					;
	goto	inicio2						;Se o caracter recebido foi "P" volta a aguardar o recebimento do caracter "C" e para de enviar a temperatura
	goto	inicio						;Se o caracter recebido não foi "P" volta a enviar a temperatura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
										;
										;Fim da rotina principal
										;
										;Inicio das sub-rotinas
	enviar_byte_rs232					;Sub-rotina para aguardar o esvaziamento do buffer do TX
	BANK1								;Vai para o banco 1 da RAM
	btfss	TXSTA,TRMT					;Verifica se o buffer do TX está vazio
	goto	$-1							;Não - aguarda esvaziar
	BANK0								;Sim - Volta para o banco 0 da RAM
	movwf	TXREG						;Move o valor do registrador W para TXREG
	return								;Retorna da sub-rotina
										;
	Converter							;Sub-rotina para converter o valor em BCD
	clrf	DSP1						;Limpa as variáveis DSP1 , DSP2 e DSP3
	clrf	DSP2						;
	clrf	DSP3						;
	movlw	.100						;Conta quantas centenas a variável tem
	subwf	Dado , 1					;
	btfss	STATUS , 0					;
	goto	$+3							;
	incf	DSP1 , 1					;
	goto	$-4							;
	movlw	.100						;
	addwf	Dado , 1					;Conta quantas dezenas a variável tem
	movlw	.10							;
	subwf	Dado , 1					;
	btfss	STATUS , 0					;
	goto	$+3							;
	incf	DSP2 , 1					;
	goto	$-4							;
	movlw	.10							;
	addwf	Dado , 0					;Oque sobrou foram as unidades que vão para a variável DSP3
	movwf	DSP3						;
	return								;Retorna da sub-rotina
										;
END										;Fim do programa