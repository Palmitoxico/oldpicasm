;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Interface com display LCD 16x2 modo 4-bits    ;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;                                              ;;
;;Cristais: 1MHz 2MHz 3MHz 4MHz 5MHz 6MHz 7MHz  ;;
;;10MHz 11MHz 12MHz 13MHz 14MHz 15MHz 16MHz     ;;
;;17MHz 18MHz 19MHz 20MHz                       ;;
;;                                              ;;
;;Versão:2.02                                   ;;
;;                                              ;;
;;                                              ;;
;;Data de início: 30/06/2011                    ;;
;;Data da última versão: 15/07/2012             ;;
;;                                              ;;
;;Compatível com qualquer pic de série 16 com   ;;
;;pinagem suficiente                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cblock	0x20
byte
Nibble
delay1
delay2
delay3
Temp1
endc

#define	LCD_RW	PORTB,1
#define	LCD_RS	PORTB,2
#define	LCD_E	PORTB,3

#define	LCD_D4	PORTB,4
#define	LCD_D5	PORTB,5
#define	LCD_D6	PORTB,6
#define	LCD_D7	PORTB,7


;De um delay de 200 ms antes de inicializar o display
								;Começo das sub-rotinas:

Init_LCD
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LDC_RW
	bcf		LCD_D4
	bcf		LCD_D5
	bcf		LCD_D6
	bcf		LCD_D7
	BANK1
	bcf		LCD_E
	bcf		LCD_RS
	bcf		LDC_RW
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 1MHz
Delay_5ms
			;1243 cycles
	movlw	0xF8
	movwf	delay1
	movlw	0x01
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
			;49993 cycles
	movlw	0x0E
	movwf	delay1
	movlw	0x28
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 2MHz
Delay_5ms
			;2493 cycles
	movlw	0xF2
	movwf	delay1
	movlw	0x02
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
			;99993 cycles
	movlw	0x1E
	movwf	delay1
	movlw	0x4F
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 3MHz
Delay_5ms
			;3743 cycles
	movlw	0xEC
	movwf	delay1
	movlw	0x03
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
			;149993 cycles
	movlw	0x2E
	movwf	delay1
	movlw	0x76
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 4MHz
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
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 5MHz
Delay_5ms
			;6243 cycles
	movlw	0xE0
	movwf	delay1
	movlw	0x05
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
			;249993 cycles
	movlw	0x4E
	movwf	delay1
	movlw	0xC4
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 6MHz
Delay_5ms
			;7493 cycles
	movlw	0xDA
	movwf	delay1
	movlw	0x06
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
			;299993 cycles
	movlw	0x5E
	movwf	delay1
	movlw	0xEB
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 7MHz
Delay_5ms
			;8743 cycles
	movlw	0xD4
	movwf	delay1
	movlw	0x07
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
			;349991 cycles
	movlw	0x4E
	movwf	delay1
	movlw	0xC4
	movwf	delay2
	movlw	0x01
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;5 cycles
	goto	$+1
	goto	$+1
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 8MHz
Delay_5ms
			;9993 cycles
	movlw	0xCE
	movwf	delay1
	movlw	0x08
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
			;399992 cycles
	movlw	0x35
	movwf	delay1
	movlw	0xE0
	movwf	delay2
	movlw	0x01
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;4 cycles
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 9MHz
Delay_5ms
			;11243 cycles
	movlw	0xC8
	movwf	delay1
	movlw	0x09
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
			;449993 cycles
	movlw	0x1C
	movwf	delay1
	movlw	0xFC
	movwf	delay2
	movlw	0x01
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 10MHz
Delay_5ms
			;12493 cycles
	movlw	0xC2
	movwf	delay1
	movlw	0x0A
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
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 11MHz
Delay_5ms
			;13743 cycles
	movlw	0xBC
	movwf	delay1
	movlw	0x0B
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
			;549995 cycles
	movlw	0xEA
	movwf	delay1
	movlw	0x33
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;1 cycle
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 12MHz
Delay_5ms
			;14993 cycles
	movlw	0xB6
	movwf	delay1
	movlw	0x0C
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
			;599996 cycles
	movlw	0xD1
	movwf	delay1
	movlw	0x4F
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 13MHz
Delay_5ms
			;16243 cycles
	movlw	0xB0
	movwf	delay1
	movlw	0x0D
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
			;649990 cycles
	movlw	0xB7
	movwf	delay1
	movlw	0x6B
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 14MHz
Delay_5ms
			;17493 cycles
	movlw	0xAA
	movwf	delay1
	movlw	0x0E
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
			;699991 cycles
	movlw	0x9E
	movwf	delay1
	movlw	0x87
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;5 cycles
	goto	$+1
	goto	$+1
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 15MHz
Delay_5ms
			;18743 cycles
	movlw	0xA4
	movwf	delay1
	movlw	0x0F
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
			;749992 cycles
	movlw	0x85
	movwf	delay1
	movlw	0xA3
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;4 cycles
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 16MHz
Delay_5ms
			;19993 cycles
	movlw	0x9E
	movwf	delay1
	movlw	0x10
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
			;799993 cycles
	movlw	0x6C
	movwf	delay1
	movlw	0xBF
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 17MHz
Delay_5ms
			;21243 cycles
	movlw	0x98
	movwf	delay1
	movlw	0x11
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
			;849994 cycles
	movlw	0x53
	movwf	delay1
	movlw	0xDB
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 18MHz
Delay_5ms
			;22493 cycles
	movlw	0x92
	movwf	delay1
	movlw	0x12
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
			;899995 cycles
	movlw	0x3A
	movwf	delay1
	movlw	0xF7
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;1 cycle
	nop

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 19MHz
Delay_5ms
			;23743 cycles
	movlw	0x8C
	movwf	delay1
	movlw	0x13
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
			;949996 cycles
	movlw	0x21
	movwf	delay1
	movlw	0x13
	movwf	delay2
	movlw	0x03
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Delays para cristal de 20MHz
Delay_5ms
			;24993 cycles
	movlw	0x86
	movwf	delay1
	movlw	0x14
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
			;999990 cycles
	movlw	0x07
	movwf	delay1
	movlw	0x2F
	movwf	delay2
	movlw	0x03
	movwf	delay3
Delay_200ms_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_200ms_0

			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

