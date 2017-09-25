

processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON


Cont1 EQU 0x20
Cont2 EQU 0x21
byte  EQU 0x22
Letra EQU 0x23
delay1 EQU 0x24
delay2 EQU 0x25
delay3 EQU 0x26
Nibble  EQU 0x27


#define	LCD_RS	PORTB,1
#define	LCD_RW	PORTB,2
#define	LCD_E	PORTB,3

org 0x0000
BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm



Main
;	BANK1
;	clrf	TRISB
;	BANK0
	call	Delay_5S
	call	Init_LCD
	
	movlw	'4'
	call	Enviar_char_lcd
	movlw  '-'
	call   Enviar_char_lcd
	movlw  'B'
	call   Enviar_char_lcd
	movlw  'i'
	call   Enviar_char_lcd
	movlw  't'
	call   Enviar_char_lcd
	movlw  ' '
	call   Enviar_char_lcd
	movlw  'M'
	call   Enviar_char_lcd
	movlw  'o'
	call   Enviar_char_lcd
	movlw  'd'
	call   Enviar_byte_lcd
	movlw  'e'
	call   Enviar_byte_lcd

	
	sleep					   ;Coloca o microcontrolador em modo de baixo consumo
	
								;Começo das sub-rotinas:
	Limpar_LCD					;
	movlw	b'00000001'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_5mS			;	
	return

	Init_LCD
	BANK1
	clrf	TRISB
	BANK0
	clrf	PORTB
	bsf		LCD_E
	bcf		LCD_RS
	bcf		LCD_RW
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

	Enviar_byte_lcd				;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	swapf	byte,0
	call	Enviar_nibble_lcd
	movf	byte,0
	call	Enviar_nibble_lcd

	return						;Retorna da sub-rotina

	Enviar_nibble_lcd
	movwf	Nibble
	movlw	b'00001111'
	andwf	PORTB
	andwf	Nibble
	swapf	Nibble,0
	iorwf	PORTB
	bcf		LCD_E				;Coloca o pino enable em 0
	nop
	nop
	bsf		LCD_E				;Volta o pino enable em 1	
	return

	Enviar_char_lcd				;Sub-rotina para enviar um caracter para o display lcd
	bsf		LCD_RS
	call	Enviar_byte_lcd
	bcf		LCD_RS
	call	Delay_5mS			;
	return						;Retorna da sub-rotina
								;
								;
	Endereco_LCD
	iorlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return

	Linha_1_LCD
	movlw	b'10000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return	

	Linha_2_LCD
	movlw	b'11000000'
	call	Enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return



Delay_40uS
	call	Delay_5mS
			;34 cycles
	movlw	0x0B
	movwf	delay1
Delay_40uS_0
	decfsz	delay1, f
	goto	Delay_40uS_0

			;2 cycles
	goto	$+1

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


Delay_5S
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_5S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_5S_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


	Aguardar_BF
	BANK1
	movlw	0xF0
	movwf	TRISB
	BANK0
	bsf		LCD_RW
Inicio_BF
	bcf		LCD_E

	bsf		LCD_E
	btfss	PORTB,4
	goto	Fim_BF

	bcf		LCD_E

	bsf		LCD_E
	goto	Inicio_BF

	Fim_BF
	bcf		LCD_RW
	return

	
	
	
	
	
END