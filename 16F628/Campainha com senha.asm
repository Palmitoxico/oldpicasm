;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Campainha com senha                  			;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;                               				;;
;;                        						;;
;;												;;
;;                    							;;
;;												;;
;;Data: 13/07/2011  							;;
;;												;;
;;PIC 16F628A   								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628A
include <p16F628A.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _INTRC_OSC_NOCLKOUT & _BODEN_ON


cblock 0x20
Temp1
delay1
delay2
delay3
W_2
STATUS_2
Count_Tecla
Count_L
Count_H
VAR_L
VAR_H
VAR
DSP1
DSP2
DSP3
DSP4
DSP5
VAR_TECLA_L
VAR_TECLA_H
STR_SENHA_Contador
STR_SENHA:4
Char_Temp
Contador_Tempo_Rele
endc

#define		Linha1			PORTA,0
#define		Linha2			PORTA,1
#define		Linha3			PORTA,2
#define		Linha4			PORTA,3
#define		Led_correto		PORTB,0
#define		Led_incorreto	PORTB,3
#define		Rele			PORTA,4

#define		TECLA_0		VAR_TECLA_L, 7
#define		TECLA_1		VAR_TECLA_L, 0
#define		TECLA_2		VAR_TECLA_L, 4
#define		TECLA_3		VAR_TECLA_H, 4
#define		TECLA_4		VAR_TECLA_L, 1
#define		TECLA_5		VAR_TECLA_L, 5
#define		TECLA_6		VAR_TECLA_H, 5
#define		TECLA_7		VAR_TECLA_L, 2
#define		TECLA_8		VAR_TECLA_L, 6
#define		TECLA_9		VAR_TECLA_H, 6
#define		TECLA_Ast	VAR_TECLA_L, 3
#define		TECLA_JV	VAR_TECLA_H, 7


								;Definição de macro-comandos	
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

DESATIVAR_INT macro
bcf		INTCON,GIE
Endm

ATIVAR_INT macro
bsf		INTCON,GIE
Endm

Ligar_Rele	macro
bcf		Rele
Endm

Desligar_Rele	macro
bsf		Rele
Endm

Desligar_Led_correto	macro
bcf		Led_correto
Endm

Ligar_Led_correto	macro
bsf		Led_correto
Endm

org 0x0000
movlw	.0
movwf	PCLATH
goto	Main

ORG  0X0004						;Rotina da interrupção
clrf	PCLATH
movwf	W_2
movf	STATUS, W
movwf	STATUS_2
BANK0
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1

bcf		Linha1
bcf		Linha2
bcf		Linha3

clrf	VAR_TECLA_L
clrf	VAR_TECLA_H

bsf		Linha1
movfw	PORTB
andlw	0xF0
iorwf	VAR_TECLA_L
bcf		Linha1

swapf	VAR_TECLA_L

bsf		Linha2
movfw	PORTB
andlw	0xF0
iorwf	VAR_TECLA_L
bcf		Linha2


bsf		Linha3
movfw	PORTB
andlw	0xF0
iorwf	VAR_TECLA_H
bcf		Linha3

movf	Contador_Tempo_Rele, F
btfsc	STATUS, Z
goto	Fim_Delay_Rele
decfsz	Contador_Tempo_Rele, F
goto	Fim_Delay_Rele
Desligar_Rele
Desligar_Led_correto
Fim_Delay_Rele


movf	Count_Tecla, F
btfsc	STATUS, Z
goto	Inicio_Ler_tecla

decfsz	Count_Tecla, F
goto	Fim_Ler_tecla

Inicio_Ler_tecla

btfss	TECLA_0
goto	$+3
movlw	'0'
movwf	Char_Temp

btfss	TECLA_1
goto	$+3
movlw	'1'
movwf	Char_Temp

btfss	TECLA_2
goto	$+3
movlw	'2'
movwf	Char_Temp

btfss	TECLA_3
goto	$+3
movlw	'3'
movwf	Char_Temp

btfss	TECLA_4
goto	$+3
movlw	'4'
movwf	Char_Temp

btfss	TECLA_5
goto	$+3
movlw	'5'
movwf	Char_Temp

btfss	TECLA_6
goto	$+3
movlw	'6'
movwf	Char_Temp

btfss	TECLA_7
goto	$+3
movlw	'7'
movwf	Char_Temp

btfss	TECLA_8
goto	$+3
movlw	'8'
movwf	Char_Temp

btfss	TECLA_9
goto	$+3
movlw	'9'
movwf	Char_Temp

btfss	TECLA_Ast
goto	$+3
movlw	'*'
movwf	Char_Temp

btfss	TECLA_JV
goto	$+3
movlw	'#'
movwf	Char_Temp

movf	VAR_TECLA_L, F
btfss	STATUS, Z
goto	Init_Delay
movf	VAR_TECLA_H, F
btfss	STATUS, Z
goto	Init_Delay

goto	Fim_Ler_tecla

Init_Delay

movlw	.15
movwf	Count_Tecla

movfw	Char_Temp
xorlw	'#'
btfss	STATUS,Z
goto	Incrementar_str

clrf	STR_SENHA_Contador

goto	FIM_LER_GRAVAR_STR

Incrementar_str:


movlw	STR_SENHA
addwf	STR_SENHA_Contador, W
movwf	FSR

incf	STR_SENHA_Contador, F

movfw	Char_Temp
call	Enviar_byte_rs232
movfw	Char_Temp
movwf	INDF


movfw	STR_SENHA_Contador
xorlw	.4
btfss	STATUS,Z
goto	FIM_LER_GRAVAR_STR

clrf	STR_SENHA_Contador

movfw	STR_SENHA
xorlw	'1'
btfss	STATUS,Z
goto	Senha_errada

movfw	STR_SENHA+1
xorlw	'2'
btfss	STATUS,Z
goto	Senha_errada

movfw	STR_SENHA+2
xorlw	'3'
btfss	STATUS,Z
goto	Senha_errada

movfw	STR_SENHA+3
xorlw	'4'
btfss	STATUS,Z
goto	Senha_errada
movlw	.13
call	Enviar_byte_rs232
movlw	.10
call	Enviar_byte_rs232

movlw	'O'
call	Enviar_byte_rs232

movlw	'K'
call	Enviar_byte_rs232

movlw	.13
call	Enviar_byte_rs232
movlw	.10
call	Enviar_byte_rs232


Ligar_Rele
Ligar_Led_correto
movlw	.100
movwf	Contador_Tempo_Rele

goto	FIM_LER_GRAVAR_STR

Senha_errada

movlw	.13
call	Enviar_byte_rs232
movlw	.10
call	Enviar_byte_rs232

movlw	'S'
call	Enviar_byte_rs232

movlw	'e'
call	Enviar_byte_rs232

movlw	'n'
call	Enviar_byte_rs232

movlw	'h'
call	Enviar_byte_rs232

movlw	'a'
call	Enviar_byte_rs232

movlw	' '
call	Enviar_byte_rs232

movlw	'e'
call	Enviar_byte_rs232

movlw	'r'
call	Enviar_byte_rs232

movlw	'r'
call	Enviar_byte_rs232

movlw	'a'
call	Enviar_byte_rs232

movlw	'd'
call	Enviar_byte_rs232

movlw	'a'
call	Enviar_byte_rs232

movlw	.13
call	Enviar_byte_rs232
movlw	.10
call	Enviar_byte_rs232


FIM_LER_GRAVAR_STR
Fim_Ler_tecla
								;
INT_FIM							;
movlw	low(.63036)
movwf	TMR1L
movlw	high(.63036)
movwf	TMR1H


movf	STATUS_2,W
movwf	STATUS
movf	W_2
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Fim do tratamento das interrupções, começo da rotina princiapal.
Main
BANK0
clrf	STR_SENHA_Contador
clrf	PORTA
clrf	PORTB
clrf	Count_L
clrf	Count_H

movlw	.15
movwf	Count_Tecla

BANKSEL	CMCON

movlw	0x07
movwf	CMCON

BANKSEL TRISA

clrf	TRISA
movlw	b'11110010'
movwf	TRISB

movlw	B'00100100'
movwf	TXSTA				;Configura USART
							;Habilita TX
							;Modo assíncrono
							;Transmissão de 8 bits
							;High speed Baud Rate
movlw	.12
movwf	SPBRG				;Acerta Baud Rate -> 19200bps, Real: 19230,769230bps

BANK0
movlw	B'10010000'
movwf	RCSTA				;Habilita RX

Desligar_Rele
Desligar_Led_correto


movlw	low(.63036)
movwf	TMR1L
movlw	high(.63036)
movwf	TMR1H



call	Delay_200ms




movlw	'C'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'm'
call	Enviar_byte_rs232
movlw	'p'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'i'
call	Enviar_byte_rs232
movlw	'n'
call	Enviar_byte_rs232
movlw	'h'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	'c'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	'm'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	's'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	'n'
call	Enviar_byte_rs232
movlw	'h'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	.13
call	Enviar_byte_rs232
movlw	.10
call	Enviar_byte_rs232

call	Delay_200ms



movlw	b'11000000'			;
movwf	INTCON				;

movlw	b'00110001'			;
movwf	T1CON				;

BANK1
bsf		PIE1 , TMR1IE
BANK0

loop:




goto	loop


sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas

	Enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
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
	return


sleep
nop


org 0x2100
de 0x00,0x01,0x02,0x03 


END