processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


org 0x0000
Dado		EQU 0x20
Valor_p		EQU 0x21
W2			EQU 0x22
Teste		EQU 0x23
DSP1		EQU 0x24
DSP2		EQU 0x25
DSP3		EQU 0x26
Resultado	EQU 0x27
Cont1		EQU 0x28
Cont2		EQU 0x29
Cont3		EQU 0x2A
RX_Byte		EQU 0x2B
delay1		EQU 0x2C
delay2		EQU 0x2D





org 0x0000
BANK1 macro
bsf   STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm

Entrada macro
BANK1
movlw	0xFF
movwf	TRISB
movwf	TRISD
BANK0
Endm

Saida macro
BANK1
clrf	TRISB
clrf	TRISD
BANK0
Endm

;A2 A1 A0 CS1 CS0
;CS0=0
;CS1=1
;A0=1
;A1=1
;A2=1

STATUS_COMANDO_HD macro	
movlw	b'11110'
movwf	PORTC
Saida
Endm
;CS0=0
;CS1=1
;A0=0
;A1=1
;A2=1
Head_Device macro
movlw	b'11010'
movwf	PORTC
Endm
;CS0=0
;CS1=1
;A0=0
;A1=0
;A2=1

LC_HD macro
movlw	b'10010'
movwf	PORTC
Endm

;CS0=0
;CS1=1
;A0=1
;A1=0
;A2=1

HC_HD macro
movlw	b'10110'
movwf	PORTC
Endm

;CS0=0
;CS1=1
;A0=1
;A1=1
;A2=0

Setor_HD macro
movlw	b'01010'
movwf	PORTC
Endm

;CS0=0
;CS1=1
;A0=0
;A1=0
;A2=0

Dados_HD macro
movlw	b'00010'
movwf	PORTC
Endm

RD_1 macro
movlw	b'111'
movwf	PORTE
Endm

RD_0 macro
movlw	b'101'
movwf	PORTE
Endm

WR_1 macro
movlw	b'111'
movwf	PORTE
Endm

WR_0 macro
movlw	b'110'
movwf	PORTE
Endm

Main

	clrf	PORTA
	clrf	PORTB
	clrf	PORTC
	clrf	PORTD
	clrf	PORTE


	BANK1
	movlw	B'00100100'
	movwf	TXSTA			; CONFIGURA USART
							; HABILITA TX
							; MODO ASSINCRONO
							; TRANSMISSÃO DE 8 BITS
							; LOW SPEED BAUD RATE
	movlw	.12
	movwf	SPBRG			; ACERTA BAUD RATE -> 19200bps

	bcf		TRISA,5
	movlw	0xE0
	movwf	TRISC
	clrf	TRISE
	BANK0					; SELECIONA BANCO 0 DA RAM

	movlw	B'10010000'
	movwf	RCSTA			; CONFIGURA USART
							; HABILITA RX
							; RECEPÇÃO DE 8 BITS
							; RECEPÇÃO CONTÍNUA
							; DESABILITA ADDRESS DETECT
	Saida

	
	bsf		PORTA,5
	bcf		PORTC,0
	bsf		PORTC,1
	bsf		PORTC,2
	bsf		PORTC,3

	movlw	0xFF
	movwf	PORTE



	MOD_1
	btfss	PIR1 , RCIF
	goto	$-1
	
	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_COM

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'O'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_COM

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'M'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_COM

	goto	Inicio1

	Fim_COM

	movlw	'D'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_D

	STATUS_COMANDO_HD
	movlw	0xE0
	movwf	PORTB
	WR_0
	WR_1

	Fim_D

	movlw	'L'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_L

	STATUS_COMANDO_HD
	movlw	0xE1
	movwf	PORTB
	WR_0
	WR_1

	Fim_L

									;Rotina para a escrita no HD
	movlw	'W'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_W
	
	Saida

	Head_Device
	movlw	b'11100000'
	movwf	PORTB
	WR_0
	WR_1



	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte

	Head_Device
	movf	RX_Byte,0
	andlw	b'00001111'
	iorlw	b'11100000'
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte

	
	HC_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte


	LC_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte


	Setor_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	Comandos_HD
	movlw	0x30
	movwf	PORTB
	WR_0
	WR_1
	btfsc	PORTA,4
	goto	$-1

	movlw	0xFF
	movwf	Cont1

	Dados_HD
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTB

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTD

	WR_0
	WR_1


	Setor_Write
	WR_1
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTB

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTD

	WR_0
	decfsz	Cont1,1
	goto	Setor_Write

	Fim_W
	movlw	'R'						;Rotina para a leitura do HD
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_R
	
	Saida

	movlw	0xFF
	movwf	Cont1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte

	
	Head_Device
	movf	RX_Byte,0
	andlw	b'00001111'
	iorlw	b'11100000'
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte

	
	HC_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte


	LC_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	RX_Byte


	Setor_HD
	movf	RX_Byte,0
	movwf	PORTB
	WR_0
	WR_1

	STATUS_COMANDO_HD
	movlw	0x20
	movwf	PORTB
	WR_0
	WR_1
	btfsc	PORTA,4
	goto	$-1

	Entrada
	Dados_HD
	RD_0
	call	Delay_1ms
	movf	PORTB , 0
	call	enviar_byte_rs232

	movf	PORTD , 0
	call	enviar_byte_rs232


	RD_1

	Setor_READ
	RD_0
	call	Delay_1ms
	movf	PORTB , 0
	call	enviar_byte_rs232

	movf	PORTD , 0
	call	enviar_byte_rs232


	RD_1
	decfsz	Cont1,1
	goto	Setor_READ

	Fim_R
									;Fim da rotina
	goto	MOD_1



	Inicio1
	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'P'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_P

	movf	PORTB,0
	call	enviar_byte_rs232


	movf	PORTD,0
	call	enviar_byte_rs232


	Fim_P
	movlw	'A'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_A
	btfss	PORTA,4
	goto	$+4
	movlw	'1'
	call	enviar_byte_rs232
	goto	Fim_A
	movlw	'0'
	call	enviar_byte_rs232
	Fim_A

	movlw	'V'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_V

	btfss	PIR1 , RCIF
	goto	$-1

	movlw	'B'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PB
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTB
	Fim_PB

	movlw	'C'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PC
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG,0
	movwf	PORTC
	Fim_PC

	movlw	'D'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_PD
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTD
	Fim_PD

	movlw	'E'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_V
	btfss	PIR1 , RCIF
	goto	$-1
	movf	RCREG , 0
	movwf	PORTE

	Fim_V

	movlw	'S'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	fim_exit

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'A'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	fim_exit

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'I'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	fim_exit

	btfss	PIR1 , RCIF
	goto	$-1
	movlw	'R'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	fim_exit
	goto	MOD_1
	fim_exit


	movlw	'I'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Fim_I
	Entrada
	Fim_I

	movlw	'O'
	subwf	RCREG , 0
	btfss	STATUS , 2
	goto	Inicio1
	Saida
	goto	Inicio1

	enviar_byte_rs232
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return

Delay_1ms
			;993 cycles
	movlw	0xC6
	movwf	delay1
	movlw	0x01
	movwf	delay2
Delay_1ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_1ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return




;	Converter
;	clrf	DSP1
;	clrf	DSP2
;	clrf	DSP3
;	movlw	.100
;	subwf	Dado , 1
;	btfss	STATUS , 0
;	goto	$+3	
;	incf	DSP1 , 1
;	goto	$-4
;	movlw	.100
;	addwf	Dado , 1
;	movlw	.10
;	subwf	Dado , 1
;	btfss	STATUS , 0
;	goto	$+3	
;	incf	DSP2 , 1
;	goto	$-4
;	movlw	.10
;	addwf	Dado , 0
;	movwf	DSP3
;	return

END