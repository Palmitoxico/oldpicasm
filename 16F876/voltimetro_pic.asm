;**********************************************************************
;* Projeto - Voltímetro PIC - 0-25VDC
;* Desenvolvido por Márcio José Soares
;* 
;* Lê entrada AD em RA0 e converte valor
;* Apresenta em display LCD 16x2
;* 
;* PIC utilizado : PIC16F876-20/P
;* Compilador    : MPLAB 6.60
;*
;* Utiliza recursos da biblioteca matemática Microchip
;* Nota de aplicações - AN544
;**********************************************************************

;**********************************************************************
;Definicoes gerais
	processor 16F876
	radix	dec
	include <P16F876.INC>

;**********************************************************************
;* Configura bits do PIC

__CONFIG _CP_OFF & _BODEN_OFF & _WRT_ENABLE_ON & _LVP_OFF & _PWRTE_OFF &  _WDT_OFF & _XT_OSC  ;configura bits

;**********************************************************************
; Definições do usuário
#DEFINE bank1  	bsf STATUS,RP0	;define comando para mudar para banco 1
#DEFINE bank0   bcf STATUS,RP0  ;define comando para mudar para banco 0

PICRES	equ	0x00		;vetor de reset
PICINT	equ	0x04		;vector de interrupção

PICRES	equ	0x00		;vetor de reset
PICINT	equ	0x04		;vector de interrupção
PICRAM	equ	0x20		;vector de ram

PORTA 	EQU	0x05		;porta A
PORTB 	EQU	0x06		;porta B
PORTC	EQU	0x07		;porta C

LED		EQU	0x02		;pino do LED
LED_C	EQU	PORTA		;porta do LED

LCD_CNTL	equ	PORTA	;port de controle para display
LCD_DATA	equ	PORTB	;port de dados para o display
E			equ	0x05	;Enable do display
RS			equ	0x01	;RS do display
RW			equ	0x03	;RW do display

w		equ	0x00		;referencia ao acumulador
W		equ	0x00		;maisculo ou minusculo

;**********************************************************************
; variáveis do usuário
	org	0x20
T1	 	res 1			;variaveis para temporizaçao
T2	 	res	1			;
T3	 	res	1			;

CHAR 	res	1			;variável auxiliar p/ escrever no LCD

ACCaHI	res 1			;acumulador "a" de 16 bits usado
ACCaLO	res 1			;na rotina de divisão
ACCbHI	res 1			;acumulador "b" de 16 bits usado
ACCbLO	res 1			;na rotina de divisão
ACCcHI	res 1			;acumulador "c" de 16 bits usado
ACCcLO	res 1			;na rotina de divisão
ACCdHI	res 1			;acumulador "d" de 16 bits usado
ACCdLO	res 1			;na rotina de divisão
temp	res 1			;contador temporário usado
						;na rotina de divisão
H_byte	res 1			;acumulador de 16 bits usado
L_byte	res 1			;para retornar o valor da rotina
						;de multiplicação
mulplr	res 1			;operador p/ rotina de multiplicação
mulcnd	res 1			;operador p/ rotina de multiplicação
AUX		res 1			;registrador de uso geral
UNIDADE	res 1			;armazena valor na unidade da tensão
DEZENA1	res 1			;armazena valor na dezena1 da tensão
DEZENA2	res 1			;armazena valor na dezena2 da tensão

;**********************************************************************
; setup para reset e interrupções

	ORG  0X0238			;inicio do programa na ROM
;	nop					;não operando
;	goto	inicio		;desvia para inicio do programa
	
;	ORG  0X0004			;endereço para interrupçoes
;	retfie				;retorna da interrução

;**********************************************************************
; setup dos pinos e periféricos do PIC

inicio:
 	movlw   0x00            ;ajuste para os bits INTCON
    movwf   INTCON			;desabilita todas as INT

	clrf	PORTA			;limpa os ports
	clrf	PORTB
	clrf	PORTC
	
	bank1					;muda para banco 1

	movlw	b'00001110'		;faz porta A digtal, exceto RA0 (AN0)
	movwf 	ADCON1			;valor justificado a esquerda

    movlw   0x01            ;ajusta os bits em A como saida
    movwf   TRISA			;exceto RA0 (AN0 - entrada analógica)

;    movlw   0x00           ;ajusta os bits em C como saida
;    movwf   TRISC

	clrf	TRISB			;ajusta os bits em B como saida

	bank0
	movlw	b'01000001'		;liga AD canal 0
	movwf	ADCON0			;fosc/8

	bcf	LCD_CNTL,E			;limpa bits de controle do LCD
	bcf	LCD_CNTL,RW
	bcf	LCD_CNTL,RS
	
;**********************************************************************
; setup para display e outros
setadisp:
	call	t250ms			;aguarda display inicializar
	call	t250ms			;0,5 segundos
	call	DISPLAY_INIT	;inicializa display
	call	DISPLAY_MSG		;envia mensagem

;**********************************************************************
; Loop principal
loop:
	bsf		ADCON0, GO_DONE	;colhe dado do canal analógico

espera_ad:
	btfsc	ADCON0, GO_DONE	;testa para ver se dado pronto
	goto	espera_ad		;dado ainda não pronto, continua teste

	movf	ADRESH,W		;carrega valor da conversão em "W"
	movwf	mulplr			;carrega mulplr com conteúdo de "W"

	movlw	.250			;carrega com 250 decimal mulcnd
	movwf	mulcnd			;para adaptar a leitura (fundo de escala 25V)

	call	mpy_F			;chama rotina de multiplicação

	movf	H_byte,W
	movwf	ACCbHI			;salva resutado da multiplicação
	movf	L_byte,W		;em ACCb para ser usado na
	movwf	ACCbLO			;rotina de divisão

	clrf	ACCaHI			;carrega ACCa com 255 decimal (fundo de
	movlw	.255			;escala do conversor A/D
	movwf	ACCaLO			;(Conversão em 8 bits)

	call	D_divF			;chama rotina de divisão

	movf    ACCbLO,W		;pega resultado da divisão
	call	AJUSTE_DECIMAL	;faz ajuste decimal


	movlw	0XC9			;comando para posicionar o cursor
	call	SEND_CMD		;na linha 2, coluna 9

	btfss	PORTC , 0
	goto	$+2
	goto	curto

	movf	DEZENA2,W
	addlw	0X30			;converte BCD da DEZENA2 em ASCII
	call	SEND_CHAR		;envia para LCD

	movf	DEZENA1,W
	addlw	0X30			;converte BCD da DEZENA1 em ASCII
	call	SEND_CHAR		;envia para LCD

	movlw	','				;escreve uma virgula no LCD
	call	SEND_CHAR		;envia para LCD

	movf	UNIDADE,W
	addlw	0X30			;converte BCD da INIDADE em ASCII
	call	SEND_CHAR		;envia para LCD

	movlw	'V'				;escreve "V" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	' '				;escreve " " no LCD
	CALL	SEND_CHAR		;envia para LCD
	
	goto	loop

	curto

	movlw	'C'				;escreve "C" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	'u'				;escreve "U" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	'r'				;escreve "V" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	't'				;escreve "V" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	'o'				;escreve "V" no LCD
	CALL	SEND_CHAR		;envia para LCD

	movlw	'!'				;escreve "V" no LCD
	CALL	SEND_CHAR		;envia para LCD

	goto	loop			;faz eternamente


;**********************************************************************
;* Ajuste decimal
;* W [HEX] =  dezena [DEC] ; unidade [DEC]
;* Conforme indicado no livro - "Conectando o PIC - Recursos avançados
;* Autores Nicolás César Lavinia e David José de Souza
;*
;* Alterada por Márcio José Soares para uso com números com duas dezenas e uma unidade
;*
;* Esta rotina recebe um argumento passado pelo acumulador "W" e retorna nas variáveis
;* DEZENA1, DEZENA2 e UNIDADE o número BCD correspondente ao parâmetro passado.

AJUSTE_DECIMAL:

	movwf	AUX			;salva valor a converter em AUX
	clrf	UNIDADE		;limpa unidade
	clrf	DEZENA1		;limpa dezena1
	clrf	DEZENA2		;limpa dezena2

	movf	AUX,F
	btfsc	STATUS,Z	;valor a converter = 0 ?
	return				;sim - retorna

ini_ajuste:						
	incf	UNIDADE,F	;Não - incrementa unidade

	movf	UNIDADE,W	;carrega W com valor em unidade
	xorlw	0X0A
	btfss	STATUS,Z	;unidade = 10 decimal ?
	goto	fim_ajuste	;não
						 
	clrf	UNIDADE		;sim, limpa unidade UNIDADE
	
	movf	DEZENA1,W	;carrega W com valor em dezena1
	xorlw	0x09		;compara com nove
	btfss	STATUS,Z	;
	goto	incDez1		;não, valor menor que 9. Incrementa dezena 1
	clrf	DEZENA1		;limpa dezena1
	incf	DEZENA2,F	;sim, incrementa dezena2	
	goto	fim_ajuste	;desvia
	
incDez1:
	incf	DEZENA1,F	;Incrementa dezena1
	
fim_ajuste:
	decfsz	AUX,F		;Fim da conversão ?
	goto	ini_ajuste	;Não - volta para continuar
	return				;sim, final da conversão

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    ROTINA DE DIVISÃO by Microchip - AN544               *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                       Double Precision Division
;****************************************************************************
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_divF
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;****************************************************************************

D_divF
	MOVLW	.16
	MOVWF	temp			;carrega contador para divisão

	MOVF	ACCbHI,W
	MOVWF	ACCdHI
	MOVF	ACCbLO,W
	MOVWF	ACCdLO			;salva ACCb em ACCd

	CLRF	ACCbHI
	CLRF	ACCbLO			;limpa ACCb

	CLRF	ACCcHI
	CLRF	ACCcLO			;limpa ACCc

DIV
	BCF		STATUS,C
	RLF		ACCdLO,F
	RLF		ACCdHI,F
	RLF		ACCcLO,F
	RLF		ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,W       	;verifica se a>c
	BTFSS	STATUS,Z
	GOTO	NOCHK
	MOVF	ACCaLO,W
	SUBWF	ACCcLO,W		;se bit msb igual, então verifica lsb
NOCHK
	BTFSS	STATUS,C		;carry setado se c>a
	GOTO	NOGO
	MOVF	ACCaLO,W		;c-a. Resposta em c
	SUBWF	ACCcLO,F
	BTFSS	STATUS,C
	DECF	ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,F
	BSF		STATUS,C			;shift de 1. Resultado em b
NOGO
	RLF		ACCbLO,F
	RLF		ACCbHI,F

	DECFSZ	temp,F			;fim da divisão ?
	GOTO	DIV				;não - volta para DIV
							
	RETURN					;sim, então retorna


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               ROTINA DE MULTIPLICAÇÃO by Microchip - AN544              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                   8x8 Software Multiplier
;               ( Fast Version : Straight Line Code )
;****************************************************************************
;
;   The 16 bit result is stored in 2 bytes
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;       Performance :
;                       Program Memory  :  37 locations
;                       # of cycles     :  38
;                       Scratch RAM     :   0 locations
;*******************************************************************

; ********************************************
;  Define a macro for adding & right shifting
; ********************************************

mult    MACRO   bit			;Inicio da macro mult

	BTFSC	mulplr,bit
	ADDWF	H_byte,F
	RRF		H_byte,F
	RRF		L_byte,F

	ENDM					;fim da macro

; *****************************
;   Begin Multiplier Routine
; *****************************

mpy_F
	CLRF	H_byte
	CLRF	L_byte
	MOVF	mulcnd,W		; move the multiplicand to W reg.
	BCF		STATUS,C		; Clear carry bit in the status Reg.

	mult    0
	mult    1
	mult    2
	mult    3
	mult    4
	mult    5
	mult    6
	mult    7

	RETURN				; RETORNA


;*******************************************************************
; Subrotina para piscar um led	(uso apenas para testes e outros)
; não utilizada neste programa, após conclusão do mesmo
;*******************************************************************
piscaled:	
	bsf		LED_C,LED		;acende o led
	call	t250ms			;aguarda 1 segundo
	bcf     LED_C,LED		;apada o led
	call	t250ms
	return					;faz infinitamente

;
;*******************************************************************
; Subrotinas do display
; Subrotinas utilizam busy check (pino RW em uso)
; Uso com display 16x2                                        
;*******************************************************************

;*******************************************************************
; Inicializa o display
; caracter 5x7, 2 linhas, cursor ligado, mensagem fixa
;*******************************************************************
;
DISPLAY_INIT:
	movlw   0x038           ; Comando para interface 8-bits
    call    SEND_CMD

    movlw   0x00E	    	; liga display
    call    SEND_CMD        ;

    movlw   0x006           ; incrementa display
    call    SEND_CMD        ;

    movlw   0x001           ; apaga display
    call    SEND_CMD        ;
    retlw   0x00	    	; volta

;
;***************************************************************
;envia mensagem para display
;***************************************************************
;
DISPLAY_MSG:
	movlw   ' '
    call    SEND_CHAR
	movlw   'V'
    call    SEND_CHAR
	movlw   'o'
    call    SEND_CHAR
    movlw   'l'
    call    SEND_CHAR
    movlw   't'
    call    SEND_CHAR
    movlw   'i'
    call    SEND_CHAR
    movlw   'm'
    call    SEND_CHAR
    movlw   'e'
    call    SEND_CHAR
    movlw   't'
    call    SEND_CHAR
    movlw   'r'
    call    SEND_CHAR
    movlw   'o'
    call    SEND_CHAR
    movlw   ' '
    call    SEND_CHAR
    movlw   'P'
    call    SEND_CHAR
	movlw   'I'
    call    SEND_CHAR
	movlw   'C'
    call    SEND_CHAR

	movlw   0xC0				;muda de linha
	call    SEND_CMD	        ;envia comando

	movlw   ' '
    call    SEND_CHAR
	movlw   'T'
    call    SEND_CHAR
	movlw   'e'
    call    SEND_CHAR
	movlw   'n'
    call    SEND_CHAR
	movlw   's'
    call    SEND_CHAR
	movlw   'a'
    call    SEND_CHAR
	movlw   'o'
    call    SEND_CHAR
	movlw   '='
    call	SEND_CHAR

    retlw   0x00
	      
;*****************************************************************
;* SEND_CHAR - envia caracter que esta no registro W para o LCD  *
;* Esta rotina envia todo caracter pelo port                     *
;* O dado eh trasmitido pelo PORTB<7:0> pins                     *
;*****************************************************************
;
SEND_CHAR:
	movwf   CHAR            ; caracter em W
    call    BUSY_CHECK      ; espere ate que o display esteje pronto
    bcf     LCD_CNTL, RW    ; seta o LCD em modelo leitura
    bsf     LCD_CNTL, RS    ; seta o LCD em modo dados
    bsf     LCD_CNTL, E     ; inverte E para o LCD
    movf    CHAR, w          
    movwf   LCD_DATA        ; envie o dado para o LCD
    bcf     LCD_CNTL, E
    retlw   0x00

;**************************************************************
;* SEND_CND - envia comando contido no registro W para LCD    *
;* esta rotina insere o dados completo no PORT                *
;* o dado eh transmitido pelo pinos do PORT<7:0>              *
;**************************************************************

SEND_CMD:
    movwf   CHAR            ; Comando a enviar em W
    call    BUSY_CHECK      ; aguarde ate que o display esteje pronto
  	bcf     LCD_CNTL, RW    ; seta o LCD em modo leitura
    bcf     LCD_CNTL, RS    ; seta o LCD em modo comando
	bsf     LCD_CNTL, E     ; inverte E para LCD
    movf    CHAR, w          
    movwf   LCD_DATA        ; envie o dado para o LCD
    bcf     LCD_CNTL, E
    retlw   0x00

;**************************************************************
;* Esta rotina checa o busy flag, retorna quando livre        *
;*  Afeta:                                                    *
;*      TEMP - retorna com endereco busy                      *
;**************************************************************
;
BUSY_CHECK:
	bank1				    ; Seleciona registro da pagina 1
    movlw   0xFF            ; Seta port B para entrada
    movwf   TRISB
    bank0				    ; Seleciona Registro da pagina 0
    bcf     LCD_CNTL, RS    ; Seta LCD para modo comando
    bsf     LCD_CNTL, RW    ; Setup para ler busy flag
    bsf     LCD_CNTL, E     ; Seta E high
    movf    LCD_DATA, w     ; le o busy flag, endereco DDram 
    bcf     LCD_CNTL, E     ; Seta E low
    andlw   0x80			; Limpa bits que não interessam
	btfss   STATUS, Z		; bit em zero ?
    goto    BUSY_CHECK		; não, então continua teste
lcdnobusy:
    bcf     LCD_CNTL, RW  	; Volta RW para escrever      
    bank1				    ; Seleciona registro pagina 1
    movlw   0x00			; seta novamente port B como saida
    movwf   TRISB			; Seta port B para saida
    bank0				    ; Seleciona registro pagina 0
    retlw   0x00

;**************************************************
;* Rotinas para temporização sem usar o TIMER
;* da PIC - espera ocupada
;**************************************************
;
;*******************************************************************
; Temporizador para 1s em 4MHZ
; Faz 4 vezes 250ms
;
t1000ms:
	movlw	0x04
	movwf	T3
t1000msa:
	call	t250ms
	decfsz	T3,1
	goto	t1000msa
	retlw	0x00

;
;*******************************************************************
; Temporizador para 250ms em 4MHZ
;
t250ms:
	movlw	0xFA		;250 decimal
	movwf	T1
t250msa:
	movlw	0xF8		;248 decimal
	movwf	T2
t250msb:
	nop
	decfsz	T2,1
	goto	t250msb
	decfsz	T1,1
	goto	t250msa
	retlw	0x00

;*******************************************************************
; Fim do programa
;
	end
