;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Controlador de Teclado de Computador 		    ;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4.000MHz                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;                                              ;;
;;Versão: 1.0                                   ;;
;;Data de início: 17/06/2011                    ;;
;;Data de término:                              ;;
;;                                              ;;
;;PIC 16F628A                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628A
include <p16F628A.inc>
__config _WDT_OFF & _PWRTE_ON & _LVP_OFF & _XT_OSC


cblock 0x20
W_2
STATUS_2
W_3
STATUS_3
delay1
delay2
delay3
STR_ADRESS_L
STR_ADRESS_H
INDEX_STR
Byte_Teclado
KBDcnt
TEMP1
TEMP2
TEMP3
TEMP4
TEMP5
TEMP6
VAR_BIT
KBD
endc


#define		KBDclktris		PORTB, 0
#define		KBDdatatris		PORTA, 2
#define		KBDclkpin		TRISB, 0
#define		KBDdatapin		TRISA, 2
#define		PARITY			VAR_BIT, 0
#define		KBDtxf			VAR_BIT, 1
#define		Data_Bit		VAR_BIT, 2

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




CLK_OUTPUT	macro

BANK1
bcf		TRISB,0
BANK0

Endm

CLK_INPUT	macro

BANK1
bsf		TRISB,0
BANK0

Endm


DATA_OUTPUT	macro

BANK1
bcf		KBDdatapin
BANK0

Endm

DATA_INPUT	macro

BANK1
bsf		KBDdatapin
BANK0

Endm

ATIVAR_INTE macro
movwf	W_3
movf	STATUS, W
BANK0
movwf	STATUS_3
bsf		INTCON, INTE
movf	STATUS_3,W
movwf	STATUS
movf	W_3, W
Endm

DESATIVAR_INTE macro
movwf	W_3
movf	STATUS, W
BANK0
movwf	STATUS_3
bcf		INTCON, INTE
movf	STATUS_3,W
movwf	STATUS
movf	W_3, W
Endm

org 0x0000
goto	Main
nop
nop
nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina da interrupção
ORG  0X0004
movwf	W_2
movf	STATUS, W
BANK0
movwf	STATUS_2

BANKSEL	PIR1
btfsc	PIR1, RCIF
goto	Int_USART
BANK0
btfsc	INTCON, INTF
goto	Int_Externa
retfie


Int_Externa



btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

clrf	Byte_Teclado

btfsc	KBDdatapin
bsf		Byte_Teclado,0

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,1

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,2

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,3

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,4

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,5

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,6

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfsc	KBDdatapin
bsf		Byte_Teclado,7



btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfss	PORTB,0
goto	$-1

btfsc	PORTB,0
goto	$-1

btfss	PORTB,0
goto	$-1

bcf		INTCON, INTF

movf	Byte_Teclado, W
call	Enviar_byte_rs232
goto	Int_Fim

Int_USART
BANK0


movf	RCREG, W
;sublw	'P'
;btfss	STATUS,Z
;goto	Fim_GravarPrograma
call	_ISR_KBDxmit
;BANK1
;bcf		PIR1,RCIF
Int_Fim:
BANK0
movf	STATUS_2,W
movwf	STATUS
movf	W_2, W
retfie
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal:
Main




call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms
call	Delay_200ms



clrf	PORTB
BANK1
movlw	b'00000111'			;Vai para o banco 1 da memória
movwf	TRISB				;Toda a porta B como saída
movlw	B'00100100'
movwf	TXSTA				;Configura USART
							;Habilita TX
							;Modo assíncrono
							;Transmissão de 8 bits
							;High speed Baud Rate
movlw	.12
movwf	SPBRG				;Acerta Baud Rate -> 19200bps, Real: 19230,769230bps
bcf		OPTION_REG,INTEDG

BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0

movlw	b'00000111'
movwf	CMCON

movlw	b'11010000'			;
movwf	INTCON				;
movlw	B'10010000'
movwf	RCSTA				;Habilita RX

call	Delay_200ms

movlw	'C'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	'n'
call	Enviar_byte_rs232
movlw	't'
call	Enviar_byte_rs232
movlw	'r'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	'l'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'd'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232
movlw	'r'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	'd'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	' '
call	Enviar_byte_rs232
movlw	't'
call	Enviar_byte_rs232
movlw	'e'
call	Enviar_byte_rs232
movlw	'c'
call	Enviar_byte_rs232
movlw	'l'
call	Enviar_byte_rs232
movlw	'a'
call	Enviar_byte_rs232
movlw	'd'
call	Enviar_byte_rs232
movlw	'o'
call	Enviar_byte_rs232

movlw	0xED
call	Enviar_Byte_KB

;DESATIVAR_INTE
;
;bcf		PORTB, 0
;bcf		KBDdatapin
;CLK_OUTPUT
;call	Delay_64us
;DATA_OUTPUT
;call	Delay_64us
;CLK_INPUT
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 0
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 2
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 4
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 5
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 6
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 7
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 8
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;Paridade
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;DATA_INPUT
;
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;










;Ler acknowledge (FA)

;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;clrf	Byte_Teclado
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,0
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,1
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,2
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,3
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,4
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,5
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,6
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfsc	KBDdatapin
;bsf		Byte_Teclado,7
;
;
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;movf	Byte_Teclado, W
;call	Enviar_byte_rs232
;
;Ligar leds
ATIVAR_INTE
movf	Byte_Teclado, W
sublw	0xFA
btfss	STATUS, Z
goto	$-1



movlw	0x06
call	Enviar_Byte_KB


;DESATIVAR_INTE
;
;
;bcf		PORTB, 0
;bcf		KBDdatapin
;CLK_OUTPUT
;call	Delay_64us
;DATA_OUTPUT
;call	Delay_64us
;bcf		KBDdatapin
;CLK_INPUT
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 1
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 2
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;bit 3
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bcf		KBDdatapin				;bit 4
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bcf		KBDdatapin				;bit 5
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bcf		KBDdatapin				;bit 6
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bcf		KBDdatapin				;bit 7
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bcf		KBDdatapin				;bit 8
;
;btfsc	PORTB,0
;goto	$-1
;
;btfss	PORTB,0
;goto	$-1
;
;bsf		KBDdatapin				;Paridade
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;
;DATA_INPUT
;
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;
;btfsc	PORTB,0
;goto	$-1
;
;
;btfss	PORTB,0
;goto	$-1
;
;
;
;
;
;
;
;
;ATIVAR_INTE





goto	$+0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas:
	Enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return

;	Enviar_String_RS232
;	call	Enviar_byte_rs232

;	return


Enviar_Byte_KB
	movwf	KBD
DESATIVAR_INTE
	movlw	.8
	movwf	TEMP1
	bcf		PORTB,0
	bcf		KBDdatapin
BANK1
bcf		TRISB,0
BANK0
	call	Delay_64us
BANK1
bcf		KBDdatapin
BANK0

BANK1
bsf		TRISB,0
BANK0

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1
TxData

	rrf		KBD, F

	btfsc	STATUS, C
	bsf		KBDdatapin
	btfss	STATUS, C
	bcf		KBDdatapin

	btfsc	PORTB,0
	goto	$-1

	btfss	PORTB,0
	goto	$-1

	decfsz	TEMP1, F
	goto	TxData

	rrf		KBD, F

	bsf		KBDdatapin

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1

BANK1
bsf		KBDdatapin
BANK0

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1
ATIVAR_INTE
return


Enviar_Byte_KB_2
	movwf	KBD
DESATIVAR_INTE
	movlw	.8
	movwf	TEMP1
	bcf		PORTB,0
	bcf		KBDdatapin
BANK1
bcf		TRISB,0
BANK0
	call	Delay_64us
BANK1
bcf		KBDdatapin
BANK0

BANK1
bsf		TRISB,0
BANK0

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1
TxData_2

	rrf		KBD, F

	btfsc	STATUS, C
	bsf		KBDdatapin
	btfss	STATUS, C
	bcf		KBDdatapin

	btfsc	PORTB,0
	goto	$-1

	btfss	PORTB,0
	goto	$-1

	decfsz	TEMP1, F
	goto	TxData_2

	rrf		KBD, F

	bcf		KBDdatapin

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1

BANK1
bsf		KBDdatapin
BANK0

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1

	btfsc	PORTB,0
	goto	$-1
	
	btfss	PORTB,0
	goto	$-1
ATIVAR_INTE
return

_ISR_KBDxmit
	movwf	KBD
	clrf	KBDcnt

	movf	KBD, W
	movwf	TEMP3		; target, which the parity bit is built from
	movlw	0x08
	movwf	TEMP4		; loop counter
	clrf	TEMP5		; the ones' counter / bit counter
_ODDpar	btfsc	TEMP3,0x00	; check for ones
	incf	TEMP5,F		; increment ones' counter
	rrf		TEMP3,F
	decfsz	TEMP4,F		; decrement loop counter
	goto	_ODDpar
	bcf		PARITY		; clear parity
	btfss	TEMP5,0x00	; check ones' counter for even value
	bsf		PARITY		; if even, set parity bit (= odd parity)



	DESATIVAR_INTE

	bcf		PORTB,0
	bcf		KBDdatapin
	BANK1
	bcf		TRISB,0
	BANK0
	call	Delay_64us
	BANK1
	bcf		KBDdatapin
	BANK0

	BANK1
	bsf		TRISB,0
	BANK0



	;*** data transmission ***
Init_KBDxmit
	
	btfsc	PORTB,0
	goto	$-1
	
	movfw	KBDcnt		; get kbd scan pattern acquisition counter
	sublw	d'7'		; w = d'7' - KBDcnt (*)
	bnc		_KBDparo	; branch if negative (carry == 0)
	btfss	PORTB,0		; serial transmission of keyboard data
	bcf		KBDdatapin
	btfsc	PORTB,0	
	bsf		KBDdatapin
	rrf		KBD,F		; rotate right keyboard TX data register
	goto	_INCF		; exit

	;*** parity transmission ***
_KBDparo movfw	KBDcnt		; get kbd scan pattern acquisition counter
	sublw	d'8'		; w = d'8' - KBDcnt
	bnc		_KBDrel		; branch if negative (carry == 0)
	btfss	PARITY		; put parity bit on keyboard data line
	bcf		KBDdatapin
	btfsc	PARITY
	bsf		KBDdatapin
	goto	_INCF		; exit

	;*** data and parity transmission completed, turn around cycle ***
_KBDrel	movfw	KBDcnt		; get kbd scan pattern acquisition counter
	sublw	d'9'		; w = d'9' - KBDcnt
	bnc		_KBDack		; branch if negative (carry == 0)
	BANK1
	bsf		KBDdatatris	; release keyboard data line, set to input
	BANK0
	goto	_INCF		; exit

_KBDack	movfw	KBDcnt		; get kbd scan pattern acquisition counter
	sublw	d'11'		; w = d'11' - KBDcnt
	bnc		_INCF		; exit if negative (carry == 0)
	goto	End_KBD

	_INCF
	incf	KBDcnt, F

;	btfsc	PORTB,0
;	goto	$-1

	goto	Init_KBDxmit

End_KBD
	btfss	PORTB,0
	goto	$-1

	ATIVAR_INTE
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
	return

Delay_64us
			;58 cycles
	movlw	0x13
	movwf	delay1
Delay_64us_0
	decfsz	delay1, f
	goto	Delay_64us_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return




END