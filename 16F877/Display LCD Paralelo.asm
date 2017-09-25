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


Cont1  EQU 0x20					;Define as constantes de endereço 
Cont2  EQU 0x21
byte   EQU 0x22
Letra  EQU 0x23
DSP1   EQU 0x24
DSP2   EQU 0x25
DSP3   EQU 0x26
DSP4   EQU 0x27
DSP5   EQU 0x28
RPML   EQU 0x29
RPMH   EQU 0x2A
Multp. EQU 0x2B
delay1 EQU 0x2C
delay2 EQU 0x2D	
delay3 EQU 0x2E	
p_lcd  EQU 0x2F
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
								;
ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0X0004						;Rotina da interrupção
decfsz	Cont2 , 1				;A interrupção acontece a cada 100 milisegundos
goto	INT_FIM					;Contador para ajustar o tempo de 100 milisegundos para 1 segundo
movlw	.5						;
movwf	Cont2					;
;call	Converter				;
incf	p_lcd,1

movlw	0X01
call	enviar_byte_lcd			;Envia o comando
;call	ler_BF					;Aguarda o busy flag ir para 0
movlw	0x20					;Da um delay de aproximadamente 100ms antes de começar a escrever no display
movwf	delay1					;
movlw	0xA1					;
movwf	delay2					;
decfsz	delay1 ,1				;
goto	$-1						;
decfsz	delay2 ,1				;
goto	$-3						;
movf	p_lcd,0
sublw	0x14
btfss	STATUS,Z
goto	$+3
movlw	0x40
movwf	p_lcd
movf	p_lcd,0
sublw	0x54
btfss	STATUS,Z
goto	$+2

clrf	p_lcd

movf	p_lcd,0
iorlw	b'10000000'
call	enviar_byte_lcd			;Envia o comando
call	ler_BF					;Aguarda o busy flag ir para 0

	movlw 	'T'					;Escreve "Teste de LCD"
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	's'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	't'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	' '					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'd'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	' '					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'L'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'C'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'D'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
								;
								;
INT_FIM							;
movlw	0x3C					;Recarrega o byte mais significativo do contador do timer 1
movwf	TMR1H					;
								;
movlw	0xB0					;Recarrega o byte menos significativo do contador do timer 1
movwf	TMR1L					;
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main							;Rotina principal
	movlw	.5					;
	movwf	Cont2				;
	clrf	RPML				;Limpa a variável RPML
	clrf	RPMH				;Limpa a variável RPMH
	clrf	PORTB				;Limpa a porta B	
	clrf	PORTD				;Limpa a porta D
	clrf	PORTE				;Limpa a porta E		  
	clrf	p_lcd
	BANK1						;Vai para o banco 1 da memória
	bcf		OPTION_REG , 7	 	;
	clrf	TRISB				;Toda a porta B como saída
	clrf	TRISD				;Toda a porta D como saída
	clrf	TRISE				;Toda a porta E como saída
	BANK0						;vai para o banco 0 da memória
	E_1
								;
	movlw	b'11000000'			;
	movwf	INTCON				;
								;
	movlw	b'00010001'			;
	movwf	T1CON				;
	movlw	0x3C				;
	movwf	TMR1H				;Carrega o byte mais significativo do contador do timer 1
								;
	movlw	0xB0				;Carrega o byte menos significativo do contador do timer 1
	movwf	TMR1L				;
								;
	movlw	0x30				;Define os valores iniciais dos dígito
	movwf	DSP1				;
								;
	movlw	0x30				;
	movwf	DSP2				;
								;
	movlw	0x30				;
	movwf	DSP3				;
								;
	movlw	0x30				;
	movwf	DSP4				;
								;
	movlw	0x30				;
	movwf	DSP5				;
								;
	movlw	0x38				;Inicialização do display lcd
	call	enviar_byte_lcd		;Configuraçao: 2 linhas, 8 bits
	call	ler_BF				;
	movlw	0x0C				;
	call	enviar_byte_lcd		;
	call	ler_BF				;
	movlw	0x01				;Limpa o display
	call	enviar_byte_lcd		;
	call	ler_BF				;
	movlw	0x20				;Da um delay de aproximadamente 100ms antes de começar a escrever no display
	movwf	delay1				;
	movlw	0xA1				;
	movwf	delay2				;
	decfsz	delay1 ,1			;
	goto	$-1					;
	decfsz	delay2 ,1			;
	goto	$-3					;
								;
	BANK1						;
	bsf		PIE1 , 0			;Inicia a contagem do timer 1
	BANK0						;
								;
	movlw 	'T'					;Escreve "Teste de LCD"
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	's'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	't'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	' '					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'd'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'e'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	' '					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'L'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'C'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
	movlw	'D'					;
	call	enviar_char_lcd		;
	call	ler_BF				;
								;
	leitura_de_freq.			;Entra na rotina para leitura da frequência de entrada em Hz
;	btfss	PORTA , 4			;
;	goto	$-1					;
;	incf	RPML				;
;	btfsc	PORTA , 4			;
;	goto	$-1					;
	goto	leitura_de_freq.	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Começo das sub-rotinas:
								;
	enviar_byte_lcd				;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	movf	byte,0
	movwf	PORTB				;Coloca o dado na porta B
	call	delay_us			;
	E_0							;Coloca o pino enable em 0
	call	delay_us			;
	E_1							;Volta o pino enable em 1
	return						;Retorna da sub-rotina

	enviar_char_lcd				;Sub-rotina para enviar um caracter para o display lcd
	movwf	byte				;
	movlw	0x05				;
	movwf	PORTE				;
	movf	byte , 0
	movwf	PORTB				;Coloca o dado na porta B
	call	delay_us			;
	movlw	0x01				;Coloca o pino enable em 0
	movwf	PORTE
	call	delay_us			;
	movlw	0x04				;Volta o pino enable em 1
	movwf	PORTE
	return						;Retorna da sub-rotina
								;
								;
	ler_BF						;Sub-rotina para aguardar o busy flag ir para 0
	call	delay_us			;Gera um delay de 255 microsegundos
	return						;Retorna da sub-rotina
								;
	delay_us					;Sub-rotina para gerar um delay de 1 milisegundo

	movlw	0xFF
	movwf	delay1

	decfsz	delay1 , 1			;
	goto	$-1					;

	return						;Retorna da sub-rotina
								;
	Converter					;Sub-rotina para a conversão de números para caracteres
								;
	movlw	.60					;Rotina de multiplicão por 60 (Converte o valor de Hz para RPM)
	movwf	Multp.				;
	movf	RPML , 0			;
	decfsz	Multp. , 1			;
	goto	$+2					;
	goto	Fim_m				;
	addwf	RPML , 1			;
	btfss	STATUS , 0			;
	goto	$-5					;
	incf	RPMH				;
	goto	$-7					;
	Fim_m						;Fim da multiplicação
								;
	clrf	DSP1				;Limpa as variáveis para realizar a decomposição do número de RPM
	clrf	DSP2				;
	clrf	DSP3				;
	clrf	DSP4				;
	clrf	DSP5				;
								;
								;
	Inicio_dec					;Começo da decomposição do número de RPM, O número é de 16 bits (RPML e RPMH)
	movf	RPML,W				;
	btfss	STATUS,Z			;
	goto	$+6					;
	decf	RPML,F				;
	movf	RPMH,W				;
	btfss	STATUS,Z			;
	goto	$+4					;
	goto	fim_dec				;
	decf	RPML,F				;
	goto	$+2					;
	decf	RPMH,F				;
								;
	incf	DSP5,F				;
	movf	DSP5,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP5				;
	incf	DSP4,F				;
	movf	DSP4,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP4				;
	incf	DSP3,F				;
	movf	DSP3,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP3				;
	incf	DSP2,F				;
	movf	DSP2,W				;
	xorlw	0X0A				;
	btfss	STATUS,Z			;
	goto	Inicio_dec			;
								;
	clrf	DSP2				;
	incf	DSP1,F				;
	goto	Inicio_dec			;
	fim_dec						;Fim da decomposição do número	
								;
								;
	btfss	DSP1 , 0			;Caso o RPM esteja igual ou acima de 6000 coloca o pino D0 no estado lógico 1
	goto	$+2					;
	goto	$+5					;
	movlw	0x06				;
	subwf	DSP2 , W			;
	btfss	STATUS, C			;
	goto	$+3					;
	bsf		PORTD, 0			;
	goto	$+2					;
	bcf		PORTD, 0			;Caso não coloca o pino D0 no estado lógico 0
								;
								;
	movlw	0x30				;
	addwf	DSP1 , 1			;
								;
	movlw	0x30				;
	addwf	DSP2 , 1			;
								;
	movlw	0x30				;
	addwf	DSP3 , 1			;
								;
	movlw	0x30				;
	addwf	DSP4 , 1			;
								;
	movlw	0x30				;	
	addwf	DSP5 , 1			;
								;
	clrf	RPML				;
	clrf	RPMH				;
	return						;Retorna da sub-rotina
								;
								;
END								;Fim do programa