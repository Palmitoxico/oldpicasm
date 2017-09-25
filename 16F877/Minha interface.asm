;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Controlador de Teclado de Computador 		    ;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4.000MHZ                              ;;
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
delay1
delay2
delay3
endc



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

BANKSEL	PIE1
btfsc	PIE1, RCIF
goto	Int_USART
retfie

Int_USART
BANK0


movf	RCREG, W
;sublw	'P'
;btfss	STATUS,Z
;goto	Fim_GravarPrograma
call	Enviar_byte_rs232
;BANK1
;bcf		PIR1,RCIF
Int_Fim:
BANK0
movf	W_2
movf	STATUS_2,W
movwf	STATUS

retfie
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Rotina Principal:
Main
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

BANKSEL	PIE1
bsf		PIE1, RCIE
BANK0

movlw	b'00000111'
movwf	CMCON

movlw	b'11000000'			;
movwf	INTCON				;
movlw	B'10010000'
movwf	RCSTA				;Habilita RX

call	Delay_200ms

movlw	'A'
call	Enviar_byte_rs232

nop
goto	$-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Começo das sub-rotinas:
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

			;4 cycles (including call)
	return


END