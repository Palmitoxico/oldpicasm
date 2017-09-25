;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Controlador para fluxo de bomba               ;;
;;Versão do programa: 1.0                       ;;
;;Versão do hardware: 1.0                       ;;
;;Desenvolvido por Augusto Fraga Giachero       ;;
;;Cristal 4MHz                                  ;;
;;                                              ;;
;;                                              ;;
;;Data de início: 03/08/2012                    ;;
;;Data da última atualização: 03/08/2012        ;;
;;                                              ;;
;;                                              ;;
;;PIC 16F887                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
processor 16F887
include <p16f887.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF & _BOR_ON & _CP_OFF & _BOR21V

cblock 0x20
Dado
DSP1
DSP2
DSP3
DSP4
DSP5
VAR_L
VAR_H
Cont_AD
byte
delay1
delay2
delay3
Media_Fluxo_L
Media_Fluxo_H
Media_Fluxo_resultado
Media_Fluxo_resultado_L
Media_Fluxo_resultado_H
Fluxo_L
Fluxo_H
VAR_BIT
Nibble
Temp1
OffSet_Str_L
OffSet_Str_H
EnderecoStr_L
EnderecoStr_H
S_Char
Divisor_L
Divisor_H
Dividendo_L
Dividendo_H
Resultado_L
Resultado_H
Base_Index_L
Base_Index_H
Temp2
Multiplicador_L
Multiplicador_H
Multiplicando_L
Multiplicando_H
endc
w_temp		EQU	0x7D		; variable used for context saving
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving


#define Multiplicador_FLX	.50						;Define a fração para ajustar o fluxo
#define Divisor_FLX			.74						;
#define OffSet_AD_FLX		0xE4					;Valor do off set do AD para fluxo = -28
#define	Temperatura_atual	Media_Temp_resultado_H	;
#define	Atualizar_DSP		VAR_BIT, 0
#define BIP_PIN				PORTD, 1

#define	LCD_RW	PORTD,2
#define	LCD_RS	PORTD,1
#define	LCD_E	PORTD,3

#define	LCD_D4	PORTD,4
#define	LCD_D5	PORTD,5
#define	LCD_D6	PORTD,6
#define	LCD_D7	PORTD,7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
RES_ON macro					;
bsf		RES_Chave				;Liga o controle da resistência
Endm							;
								;
RES_OFF macro					;
bcf		RES_Chave 			    ;Desliga o controle da resistência
bcf		RES_PIN					;
Endm							;
								;
BANK0 macro						;
bcf		STATUS,RP0 			    ;Muda para o banco 0
bcf		STATUS,RP1				;
Endm							;
								;
BANK1 macro						;
bsf		STATUS,RP0  			;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK2 macro						;
bcf		STATUS,RP0  			;Muda para o banco 2
bsf		STATUS,RP1				;
Endm							;
								;
BANK3 macro						;
bsf		STATUS,RP0  			;Muda para o banco 3
bsf		STATUS,RP1				;
Endm							;
								;
								;
DESATIVAR_INT macro				;
bcf		INTCON,GIE				;
Endm							;
								;
ATIVAR_INT macro				;
bsf		INTCON,GIE				;
Endm							;
								;
ORG  0X0000						;Pular para a rotina principal
goto Main						;Deixar espaço para a interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0X0004						;Rotina da interrupção
movwf   w_temp          		; save off current W register contents
movf	STATUS,w        		; move status register into W register
movwf	status_temp       		; save off contents of STATUS register
movf	PCLATH,w		  		; move pclath register into w register
movwf	pclath_temp				; save off contents of PCLATH register



movf	pclath_temp,w			; retrieve copy of PCLATH register
movwf	PCLATH					; restore pre-isr PCLATH register contents
movf    status_temp,w			; retrieve copy of STATUS register
movwf	STATUS					; restore pre-isr STATUS register contents
swapf   w_temp,f
swapf   w_temp,w				; restore pre-isr W register contents

retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Constantes

Inicial_01:
DT "Fluxo:",0
Inicial_02:
DT "/LA0:     A1:/2A2:",0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal
Main
	clrf	PORTB				;Limpa a porta B
	clrf	PORTE				;Limpa a porta E

	movlw	.64					;Carrega
	movwf	Cont_AD				

	movlw	b'01000001'			;Liga o conversor AD, configura o clock de 2 microsegundos (8/4MHz), seleciona o canal AN0
	movwf	ADCON0


	BANK1						;Seleciona o banco 1 da RAM
	movlw	b'10000010'			;Configura a porta A como entrada analógica
	movwf	ADCON1				;O valor é justificado à direita, os 8 bits menos significativos ficam no registrador ADRESL
	clrf	TRISB				;Define a porta B como saida
	clrf	TRISE				;Defina a porta E como saida
;	clrf	TRISD				;Define a porta D como saida (controle do relé de estado sólido/BIP)	
	BANK0						;Seleciona o banco 0 da RAM
	bsf		BIP_PIN

	movlw	b'11000000'			;
	movwf	INTCON				;


	call	Delay_200ms			;Delay de 200 milisegundos para garantir que o display esteja energizado
	call	Init_LCD			;Chama a subrotina para inicialização do display no modo 8 bits
	bcf		BIP_PIN


	movlw	Low(Inicial_01)
	movwf	OffSet_Str_L
	movlw	High(Inicial_01)
	movwf	OffSet_Str_H
	call	Enviar_String




Loop_Principal:





	goto	Loop_Principal

sleep
									;Termina a rotina principal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
									;Começo das sub-rotinas

Converter							;Rotina para a conversão de binário de 8 bits para decimal
	movwf	Dado
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP1 , 1
	goto	$-4
	movlw	.100
	addwf	Dado , 1
	movlw	.10
	subwf	Dado , 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	Dado , 0
	movwf	DSP3

	movlw	0x30
	addwf	DSP1 , F	
	movlw	0x30
	addwf	DSP2 , F	
	movlw	0x30
	addwf	DSP3 , F	
	return							;Retorna da sub-rotina


Converter_Bin_Dec_16bit

	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	clrf	DSP4
	clrf	DSP5


	Ajuste_DSP5

	movlw	0x10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0x10
	addwf	VAR_L, F
	goto	FIM_DSP5


	movlw	0x27
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP5
	goto	Ajuste_DSP5

	movlw	0x10
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x27
	addwf	VAR_H, F


	FIM_DSP5




	Ajuste_DSP4

	movlw	0xE8
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0xE8
	addwf	VAR_L, F
	goto	FIM_DSP4


	movlw	0x03
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP4
	goto	Ajuste_DSP4

	movlw	0xE8
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x03
	addwf	VAR_H, F


	FIM_DSP4


	Ajuste_DSP3

	movlw	.100
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.100
	addwf	VAR_L, F
	goto	FIM_DSP3

	incf	DSP3, F
	goto	Ajuste_DSP3

	FIM_DSP3


	Ajuste_DSP2

	movlw	.10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.10
	addwf	VAR_L, F
	goto	FIM_DSP2

	incf	DSP2, F
	goto	Ajuste_DSP2

	FIM_DSP2


	Ajuste_DSP1

	movf	VAR_L, W
	movwf	DSP1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
	addwf	DSP4, F
	addwf	DSP5, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	return


Init_LCD
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK1
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK0
	bsf		LCD_E				;Coloca o pino enable em 1
	nop
	nop
	bcf		LCD_E				;Volta o pino enable em 0
	nop
	nop	
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x03
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x02
	call	Enviar_nibble_lcd
	call	Delay_5mS			;
	movlw	0x28
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	0x0c
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	b'00000001'
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	movlw	0x06
	call	Enviar_byte_lcd
	call	Delay_5mS			;
	return

Enviar_byte_lcd					;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	DESATIVAR_INT
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd
	ATIVAR_INT
	return						;Retorna da sub-rotina

Enviar_nibble_lcd
	movwf	Nibble
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	btfsc	Nibble,0
	bsf		LCD_D4
	btfsc	Nibble,1
	bsf		LCD_D5
	btfsc	Nibble,2
	bsf		LCD_D6
	btfsc	Nibble,3
	bsf		LCD_D7	
	nop
	nop
	bsf		LCD_E				;Coloca o pino enable em 1
	nop
	nop
	bcf		LCD_E				;Volta o pino enable em 0	
	return

Enviar_char_lcd					;Sub-rotina para enviar um caracter para o display lcd
	movwf	Temp1
	call	Aguardar_BF_LCD			;
	movfw	Temp1
	bsf		LCD_RS
	nop
	nop
	call	Enviar_byte_lcd
	nop
	nop
	bcf		LCD_RS
	nop
	nop
	return


Ler_Str_Tabela:
	movfw	OffSet_Str_H
    addwf	EnderecoStr_H,W
    movwf	PCLATH
	movfw	OffSet_Str_L
    addwf	EnderecoStr_L,W
    skpnc
    incf	PCLATH,F
    movwf   PCL
 

Enviar_String:
	clrf	EnderecoStr_H
	clrf	EnderecoStr_L
Ler_Str:
	call	Ler_Str_Tabela
	movwf	S_Char
	movf	S_Char,F
	btfsc	STATUS,Z
	goto	Fim_Enviar_String

	sublw	'/'
	btfss	STATUS,Z
	goto	EnviarChar1

	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F

	call	Ler_Str_Tabela
	PAGESEL	Enviar_String
	movwf	S_Char
	movf	S_Char,W
	btfsc	STATUS,Z
	goto	Fim_Enviar_String

	movf	S_Char,W
	sublw	'/'
	btfss	STATUS,Z
	goto	FimChar_barra
	movlw	'/'
	call	Enviar_char_lcd
FimChar_barra

	movf	S_Char,W
	sublw	'L'
	btfss	STATUS,Z
	goto	FimChar_limpar
	call	Limpar_LCD
FimChar_limpar

	movf	S_Char,W
	sublw	'1'
	btfss	STATUS,Z
	goto	FimChar_linha1
	call	Linha_1_LCD
FimChar_linha1

	movf	S_Char,W
	sublw	'2'
	btfss	STATUS,Z
	goto	FimChar_linha2
	call	Linha_2_LCD
FimChar_linha2


	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F

	goto	Ler_Str
EnviarChar1
	movf	S_Char,W
	call	Enviar_char_lcd
	incfsz	EnderecoStr_L,F
	goto	$+2
	incf	EnderecoStr_H,F
	goto	Ler_Str
Fim_Enviar_String
	return

								;
								;
Endereco_LCD
	movwf	Temp1
	call	Aguardar_BF_LCD
	movfw	Temp1
	iorlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	return

Linha_1_LCD
	call	Aguardar_BF_LCD
	movlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	return	

Linha_2_LCD
	call	Aguardar_BF_LCD
	movlw	b'11000000'
	call	Enviar_byte_lcd		;Envia o comando
	return

Limpar_LCD					;
	call	Aguardar_BF_LCD
	movlw	b'00000001'
	call	Enviar_byte_lcd		;Envia o comando
	return

Ler_byte_LCD					;Sub-rotina para ler uma byte do display LCD
	DESATIVAR_INT
	clrf	byte
	BANK1
	bsf		LCD_D4
	bsf		LCD_D5
	bsf		LCD_D6
	bsf		LCD_D7
	BANK0
	bsf		LCD_RW
	nop
	nop
	bsf		LCD_E
	nop
	nop	
	btfsc	LCD_D4
	bsf		byte,4
	btfsc	LCD_D5
	bsf		byte,5
	btfsc	LCD_D6
	bsf		byte,6
	btfsc	LCD_D7
	bsf		byte,7

	bcf		LCD_E
	nop
	nop
	bsf		LCD_E
	nop
	nop
	
	btfsc	LCD_D4
	bsf		byte,0
	btfsc	LCD_D5
	bsf		byte,1
	btfsc	LCD_D6
	bsf		byte,2
	btfsc	LCD_D7
	bsf		byte,3

	bcf		LCD_E
	bcf		LCD_RW
	BANK1
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK0
	movfw	byte
	ATIVAR_INT
	return

Aguardar_BF_LCD					;Sub-rotina para esperar o display LCD ficar desocupado
	call	Ler_byte_LCD
	btfsc	byte, 7
	goto	Aguardar_BF_LCD
	return

DIVV16							;Sub-rotina para divisão em 16 bits
	movf	Divisor_L,F
	btfss 	STATUS,Z
	goto	ZERO_TEST_SKIPPED
	movf	Divisor_H,F
	btfsc	STATUS,Z
return

ZERO_TEST_SKIPPED
	movlw   1
	movwf   Base_Index_L
	clrf    Base_Index_H
	clrf    Resultado_L
	clrf    Resultado_H

SHIFT_IT16
	btfsc   Divisor_H,7
	goto 	DIVU16LOOP
	bcf     STATUS,C
  	rlf     Base_Index_L,F
  	rlf     Base_Index_H,F
  	bcf     STATUS,C
  	rlf     Divisor_L,F
  	rlf     Divisor_H,F
  	goto    SHIFT_IT16

DIVU16LOOP
	call    SUB16
	btfsc   STATUS,C
	goto    COUNTX
	call    ADD16BIS
	goto    FINALX
COUNTX
	movf    Base_Index_L,W
	addwf   Resultado_L
	btfsc   STATUS,C
	incf    Resultado_H,F
	movf    Base_Index_H,W
	addwf   Resultado_H
FINALX
	bcf     STATUS,C
	rrf     Divisor_H,F
	rrf     Divisor_L,F
	bcf     STATUS,C
	rrf     Base_Index_H,F
	rrf     Base_Index_L,F
	btfss   STATUS,C
	goto    DIVU16LOOP
return

SUB16
	movf    Divisor_H,W
	movwf   Temp2
	movf    Divisor_L,W
	subwf   Dividendo_L
	btfss   STATUS,C
	incf    Temp2,F
	movf    Temp2,W
	subwf   Dividendo_H
return

ADD16BIS
	movf    Divisor_L,W
	addwf   Dividendo_L
	btfsc   STATUS,C
	incf    Dividendo_H,F
	movf    Divisor_H,W
	addwf   Dividendo_H
return

MULV16 
	clrf    Resultado_L
	clrf    Resultado_H
MULU16LOOP
	btfsc	Multiplicando_L,0
	call	ADD16
	bcf		STATUS,C
	rrf 	Multiplicando_H,F
	rrf 	Multiplicando_L,F
	bcf 	STATUS,C
	rlf 	Multiplicador_L,F
	rlf 	Multiplicador_H,F
	movf	Multiplicando_L,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	movf	Multiplicando_H,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	return

ADD16
	movf	Multiplicador_L,W
	addwf	Resultado_L
	btfsc	STATUS,C
	incf	Resultado_H
	movf	Multiplicador_H,W
	addwf	Resultado_H
	return

Delay_20us
			;16 cycles
	movlw	0x05
	movwf	delay1
Delay_20us_0
	decfsz	delay1, f
	goto	Delay_20us_0

			;4 cycles (including call)
	return

Delay_5mS
			;4993 cycles
	movlw	0xE6
	movwf	delay1
	movlw	0x04
	movwf	delay2
Delay_5ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_5ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

Delay_200ms
			;199993 cycles
	movlw	0x3E
	movwf	delay1
	movlw	0x9D
	movwf	delay2
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_200ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return							;Retorna da sub-rotina

Delay_500ms
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_500ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_500ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


									;Fim do programa
END