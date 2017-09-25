;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Animações gráficas.asm                ;;
;;                                                      ;;
;;Desenvolvido por: Augusto Fraga Giachero              ;;
;;Data: 14/07/2010                                      ;;
;;                                                      ;;
;;Displays compatíveis: Displays gráficos 128x64 com o  ;;
;;controlador KS0108B                                   ;;
;;                                                      ;;
;;Microcontrolador: PIC 16F877                          ;;
;;Cristal:4MHz                                          ;;
;;                                                      ;;
;;Pinagem:                                              ;;
;;        RB0~RB7 --> DB0~DB7                           ;;
;;        RE0     --> Enable                            ;;
;;        RE1     --> RW                                ;;
;;        RE2     --> RS                                ;;
;;        RC0     --> CS1                               ;;
;;        RC1     --> CS2                               ;;
;;                                                      ;;
;;Caso os pinos CS1 e CS2 estiverem com sinal negado:   ;;
;;___   ___                                             ;;
;;CS1 e CS2                                             ;;
;;                                                      ;;
;;Defina a variável CS_Negado como 1:	                ;;
;;                                                      ;;
;;#Define CS_Negado 1                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC

Cont1		EQU 0x20			;Define as constantes de endereço 
CHR1		EQU 0x21
CHR2		EQU 0x22
CHR3		EQU 0x23
CHR4		EQU 0x24
CHR5		EQU 0x25
delay1		EQU 0x26
delay2		EQU 0x27		
Cont_lcd1	EQU 0x28
Cont_lcd2	EQU 0x29
Endereco1	EQU 0x2A
Endereco2	EQU 0x2B
Valor		EQU 0x2C
VAR_BIT		EQU 0x2B
Char		EQU 0x2C
Eixo_X		EQU 0x2D
Eixo_Y		EQU 0x2E


#Define  Endereco_RTC_escrita b'10100000'
#Define  Endereco_RTC_leitura b'10100001'

#Define CS_Negado 0				;Defina a variável CS_Negado como 1, caso os pinos CS1 e CS2 estiverem com sinal negado



org 0x0000
BANK1 macro
bsf		STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf		STATUS,RP0  			   ;Volta ao banco 0
Endm

#if CS_Negado == 0 

CS1_ON macro
bsf		PORTC,0
Endm

CS2_ON macro
bsf		PORTC,1
Endm

CS1_OFF macro
bcf		PORTC,0
Endm

CS2_OFF macro
bcf		PORTC,1
Endm

#else

CS1_ON macro
bcf		PORTC,0
Endm

CS2_ON macro
bcf		PORTC,1
Endm

CS1_OFF macro
bsf		PORTC,0
Endm

CS2_OFF macro
bsf		PORTC,1
Endm

#EndIf

E_0 macro
bcf		PORTE,0
Endm

E_1 macro
bsf		PORTE,0
Endm

RW_0 macro
bcf		PORTE,1
Endm

RW_1 macro
bsf		PORTE,1
Endm

RS_0 macro
bcf		PORTE,2
Endm

RS_1 macro
bsf		PORTE,2
Endm


Main
	movlw	b'00101000'
	movwf	SSPCON
	clrf	Endereco1
	clrf	Endereco2
	clrf	PORTB
	movlw	0xFF			   
	movwf	PORTE
	clrf	PORTC
	BANK1  	 	  		       
	clrf	TRISB	
	clrf	TRISD
	movlw	0xF8
	movwf	TRISC		   
	clrf	TRISE
	bcf		SSPSTAT,CKE
	movlw	0x02
	movwf	SSPADD
	BANK0		
	bcf		SSPSTAT,2		
	call	Ligar_GLCD
	call	GLCD_esperar
	call	Ligar_GLCD
	call	GLCD_esperar
	CS1_ON
	CS2_OFF 
;	movlw	B'100'
;	movwf	PORTE
;	movlw	0x3F
;	movwf	PORTB
;	movlw	B'001'
;	movwf	PORTE
;	movlw	B'100'
;	movwf	PORTE
call	GLCD_apagar

call	Char_54
call	GLCD_buffer_char

call	Char_65
call	GLCD_buffer_char

call	Char_73
call	GLCD_buffer_char

call	Char_74
call	GLCD_buffer_char

call	Char_65
call	GLCD_buffer_char

call	Char_20
call	GLCD_buffer_char

call	Char_31
call	GLCD_buffer_char

movlw	.1
call	GLCD_linha
clrw
call	GLCD_coluna	

call	Char_43
call	GLCD_buffer_char

call	Char_teste
call	GLCD_buffer_char

call	Char_6F
call	GLCD_buffer_char



;	movlw	b'01010101'
	
;	   

	inicio
;	movlw	0xF0
;	movlw	B'100'
;	movwf	PORTE
;	call	Ler_EEPROM
;	movwf	PORTB
;	movwf	PORTD
;	movlw	B'001'
;	movwf	PORTE
;	movlw	B'100'
;	movwf	PORTE
;	call	Ler_EEPROM
;	movwf	PORTB
;	movwf	PORTD
;	movlw	B'001'
;	movwf	PORTE
;
;	cont_screen
;	incfsz	Endereco1,1
;	goto	$+2
;	goto	Fim_screen
;	movlw	B'100'
;	movwf	PORTE
;	call	Ler_EEPROM
;	movwf	PORTB
;	movwf	PORTD
;	movlw	B'001'
;	movwf	PORTE
;	goto	cont_screen
;	Fim_screen
;
;
;	clrf	Endereco1
;
;	cont_screen2
;	incfsz	Endereco1,1
;	goto	$+2
;	goto	Fim_screen2
;	movlw	B'100'
;	movwf	PORTE
;	call	Ler_EEPROM
;	movwf	PORTB
;	movwf	PORTD
;	movlw	B'001'
;	movwf	PORTE
;	goto	cont_screen2
;	Fim_screen2
;
;
;
;	sleep
;	movlw	B'01111110'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;
;	movlw	B'100'
;	movwf	PORTE
;
;	movlw	B'00010001'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;
;	movlw	B'100'
;	movwf	PORTE
;
;	movlw	B'00010001'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;
;	movlw	B'100'
;	movwf	PORTE
;
;	movlw	B'00010001'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;
;	movlw	B'100'
;	movwf	PORTE
;
;	movlw	B'01111110'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;
;	movlw	B'100'
;	movwf	PORTE
;
;	movlw	B'01111110'
;	movwf	PORTB
;
;	movlw	B'001'
;	movwf	PORTE
;	
;
	
	

	sleep

	GLCD_enviar_byte
	movwf	PORTB

	movlw	b'001'
	movwf	PORTE

	movlw	b'000'
	movwf	PORTE

	movlw	b'001'
	movwf	PORTE
	return

	Ligar_GLCD
	CS1_ON
	CS2_ON
	movlw	b'001'
	movlw	b'00111111'
	call	GLCD_enviar_byte
	return

	GLCD_linha
	movwf	Eixo_Y
	andlw	b'10111111'
	iorlw	b'10111000'
	call	GLCD_enviar_byte
	return

	GLCD_coluna
	movwf	Eixo_X
	andlw	b'01111111'
	iorlw	b'01000000'
	call	GLCD_enviar_byte
	return

	GLCD_esperar
	movlw	b'011'
	movwf	PORTE
	clrf	PORTB
	BANK1
	movlw	b'11111111'
	movwf	TRISB
	BANK0
	movlw	b'010'
	movwf	PORTE
	btfsc	PORTB,7
	goto	GLCD_esperar
	movlw	b'001'
	movwf	PORTE
	BANK1
	clrf	TRISB
	BANK0
	return

	GLCD_apagar
	bsf		VAR_BIT,0
	CS1_ON
	CS2_ON
	Init_clear
	movlw	0xC0
	movwf	Cont_lcd1
	movlw	0xFC
	movwf	Cont_lcd2
	Rotina_Agagar
	clrw
	call	GLCD_escrever_byte
	call	GLCD_esperar
	incfsz	Cont_lcd1,1
	goto	Rotina_Agagar
	incfsz	Cont_lcd2,1
	goto	Rotina_Agagar
	movlw	.4
	call	GLCD_linha
	clrw
	call	GLCD_coluna
	btfss	VAR_BIT,0
	goto	$+3
	bcf		VAR_BIT,0
	goto	Init_clear
	clrw
	call	GLCD_linha
	clrw
	call	GLCD_coluna
	CS1_ON
	CS2_OFF
	return

	GLCD_escrever_byte
	incf	Eixo_X
	movwf	PORTB
	movlw	b'101'
	movwf	PORTE
	movlw	b'100'
	movwf	PORTE
	movlw	b'001'
	movwf	PORTE
	call	GLCD_esperar
	return

	GLCD_buffer_char
	movf	CHR1,0
	call	GLCD_escrever_byte	
	movf	CHR2,0
	call	GLCD_escrever_byte
	movf	CHR3,0
	call	GLCD_escrever_byte
	movf	CHR4,0
	call	GLCD_escrever_byte
	movf	CHR5,0
	call	GLCD_escrever_byte
	clrw
	call	GLCD_escrever_byte
	return					

	Gravar_EEPROM
	movwf	Valor
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco2,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco1,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Valor,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	return




	Ler_EEPROM
	BANK1
	bsf		SSPCON2,SEN
	btfsc	SSPCON2,SEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_escrita
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco2,0
	movwf	SSPBUF

	call	Espera_I2C

	movf	Endereco1,0
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,RSEN
	btfsc	SSPCON2,RSEN
	goto	$-1
	BANK0

	movlw	Endereco_RTC_leitura
	movwf	SSPBUF

	call	Espera_I2C

	BANK1
	bsf		SSPCON2,RCEN
	BANK0


	call	Espera_I2C
	movf	SSPBUF,0
	movwf	Valor
	call	Enviar_NACK
	call	Espera_I2C
	BANK1
	bsf		SSPCON2,PEN
	btfsc	SSPCON2,PEN
	goto	$-1
	BANK0
	movf	Valor,0
	return

	Espera_I2C
	BANK1
	btfsc	SSPSTAT,R_W
	goto	$-1
	movf	SSPCON2,0
	andlw	B'00011111'
	btfss	STATUS,Z
	goto	$-3
	BANK0
	return

	Enviar_NACK
	BANK1
	bsf		SSPCON2,ACKDT
	bsf		SSPCON2,ACKEN
	BANK0
	return

	Delay_1ms

	movlw	0xC7
	movwf	delay1
	movlw	0x01
	movwf	delay2
Delay_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_0

	goto	$+1

	return

;GLCD_enviar_char
;addwf	PCL
;goto	Char_00
;goto	Char_01
;goto	Char_02
;goto	Char_03
;goto	Char_04
;goto	Char_05
;goto	Char_06
;goto	Char_07
;goto	Char_08
;goto	Char_09
;goto	Char_0A
;goto	Char_0B
;goto	Char_0C
;goto	Char_0D
;goto	Char_0E
;goto	Char_0F
;goto	Char_10
;goto	Char_11
;goto	Char_12
;goto	Char_13
;goto	Char_14
;goto	Char_15
;goto	Char_16
;goto	Char_17
;goto	Char_18
;goto	Char_19
;goto	Char_1A
;goto	Char_1B
;goto	Char_1C
;goto	Char_1D
;goto	Char_1E
;goto	Char_1F
;goto	Char_20
;goto	Char_21
;goto	Char_22
;goto	Char_23
;goto	Char_24
;goto	Char_25
;goto	Char_26
;goto	Char_27
;goto	Char_28
;goto	Char_29
;goto	Char_2A
;goto	Char_2B
;goto	Char_2C
;goto	Char_2D
;goto	Char_2E
;goto	Char_2F
;goto	Char_30
;goto	Char_31
;goto	Char_32
;goto	Char_33
;goto	Char_34
;goto	Char_35
;goto	Char_36
;goto	Char_37
;goto	Char_38
;goto	Char_39
;goto	Char_3A
;goto	Char_3B
;goto	Char_3C
;goto	Char_3D
;goto	Char_3E
;goto	Char_3F
;goto	Char_40
;goto	Char_41
;goto	Char_42
;goto	Char_43
;goto	Char_44
;goto	Char_45
;goto	Char_46
;goto	Char_47
;goto	Char_48
;goto	Char_49
;goto	Char_4A
;goto	Char_4B
;goto	Char_4C
;goto	Char_4D
;goto	Char_4E
;goto	Char_4F
;goto	Char_50
;goto	Char_51
;goto	Char_52
;goto	Char_53
;goto	Char_54
;goto	Char_55
;goto	Char_56
;goto	Char_57
;goto	Char_58
;goto	Char_59
;goto	Char_5A
;goto	Char_5B
;goto	Char_5C
;goto	Char_5D
;goto	Char_5E
;goto	Char_5F
;goto	Char_60
;goto	Char_61
;goto	Char_62
;goto	Char_63
;goto	Char_64
;goto	Char_65
;goto	Char_66
;goto	Char_67
;goto	Char_68
;goto	Char_69
;goto	Char_6A
;goto	Char_6B
;goto	Char_6C
;goto	Char_6D
;goto	Char_6E
;goto	Char_6F
;goto	Char_70
;goto	Char_71
;goto	Char_72
;goto	Char_73
;goto	Char_74
;goto	Char_75
;goto	Char_76
;goto	Char_77
;goto	Char_78
;goto	Char_79
;goto	Char_7A
;goto	Char_7B
;goto	Char_7C
;goto	Char_7D
;goto	Char_7E
;goto	Char_7F
;goto	Char_80
;goto	Char_81
;goto	Char_82
;goto	Char_83
;goto	Char_84
;goto	Char_85
;goto	Char_86
;goto	Char_87
;goto	Char_88
;goto	Char_89
;goto	Char_8A
;goto	Char_8B
;goto	Char_8C
;goto	Char_8D
;goto	Char_8E
;goto	Char_8F
;goto	Char_90
;goto	Char_91
;goto	Char_92
;goto	Char_93
;goto	Char_94
;goto	Char_95
;goto	Char_96
;goto	Char_97
;goto	Char_98
;goto	Char_99
;goto	Char_9A
;goto	Char_9B
;goto	Char_9C
;goto	Char_9D
;goto	Char_9E
;goto	Char_9F
;goto	Char_A0
;goto	Char_A1
;goto	Char_A2
;goto	Char_A3
;goto	Char_A4
;goto	Char_A5
;goto	Char_A6
;goto	Char_A7
;goto	Char_A8
;goto	Char_A9
;goto	Char_AA
;goto	Char_AB
;goto	Char_AC
;goto	Char_AD
;goto	Char_AE
;goto	Char_AF
;goto	Char_B0
;goto	Char_B1
;goto	Char_B2
;goto	Char_B3
;goto	Char_B4
;goto	Char_B5
;goto	Char_B6
;goto	Char_B7
;goto	Char_B8
;goto	Char_B9
;goto	Char_BA
;goto	Char_BB
;goto	Char_BC
;goto	Char_BD
;goto	Char_BE
;goto	Char_BF
;goto	Char_C0
;goto	Char_C1
;goto	Char_C2
;goto	Char_C3
;goto	Char_C4
;goto	Char_C5
;goto	Char_C6
;goto	Char_C7
;goto	Char_C8
;goto	Char_C9
;goto	Char_CA
;goto	Char_CB
;goto	Char_CC
;goto	Char_CD
;goto	Char_CE
;goto	Char_CF
;goto	Char_D0
;goto	Char_D1
;goto	Char_D2
;goto	Char_D3
;goto	Char_D4
;goto	Char_D5
;goto	Char_D6
;goto	Char_D7
;goto	Char_D8
;goto	Char_D9
;goto	Char_DA
;goto	Char_DB
;goto	Char_DC
;goto	Char_DD
;goto	Char_DE
;goto	Char_DF
;goto	Char_E0
;goto	Char_E1
;goto	Char_E2
;goto	Char_E3
;goto	Char_E4
;goto	Char_E5
;goto	Char_E6
;goto	Char_E7
;goto	Char_E8
;goto	Char_E9
;goto	Char_EA
;goto	Char_EB
;goto	Char_EC
;goto	Char_ED
;goto	Char_EE
;goto	Char_EF
;goto	Char_F0
;goto	Char_F1
;goto	Char_F2
;goto	Char_F3
;goto	Char_F4
;goto	Char_F5
;goto	Char_F6
;goto	Char_F7
;goto	Char_F8
;goto	Char_F9
;goto	Char_FA
;goto	Char_FB
;goto	Char_FC
;goto	Char_FD
;goto	Char_FE
;goto	Char_FF

return

Char_20
movlw   b'00000000'
movwf  CHR1
movlw   b'00000000'
movwf  CHR2
movlw   b'00000000'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_21
movlw   b'00000000'
movwf  CHR1
movlw   b'00000000'
movwf  CHR2
movlw   b'01001111'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_22
movlw	b'00000000'
movwf  CHR1
movlw   b'00000111'
movwf  CHR2
movlw   b'00000000'
movwf  CHR3
movlw   b'00000111'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_23
movlw   b'00010100'
movwf  CHR1
movlw   b'01111111'
movwf  CHR2
movlw   b'00010100'
movwf  CHR3
movlw   b'01111111'
movwf  CHR4
movlw   b'00010100'
movwf  CHR5
return



Char_24
movlw   b'00100100'
movwf  CHR1
movlw   b'00101010'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'00101010'
movwf  CHR4
movlw   b'00010010'
movwf  CHR5
return

Char_teste
movlw   b'00100010'
movwf  CHR1
movlw   b'01010101'
movwf  CHR2
movlw   b'01010101'
movwf  CHR3
movlw   b'01010110'
movwf  CHR4
movlw   b'01111001'
movwf  CHR5
return


Char_25
movlw   b'00100011'
movwf  CHR1
movlw   b'00010011'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'01100100'
movwf  CHR4
movlw   b'01100010'
movwf  CHR5
return



Char_26
movlw   b'00110110'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01010101'
movwf  CHR3
movlw   b'00100010'
movwf  CHR4
movlw   b'01010000'
movwf  CHR5
return



Char_27
movlw   b'00000000'
movwf  CHR1
movlw   b'00000101'
movwf  CHR2
movlw   b'00000011'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_28
movlw   b'00000000'
movwf  CHR1
movlw   b'00011100'
movwf  CHR2
movlw   b'00100010'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_29
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'00100010'
movwf  CHR3
movlw   b'00011100'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_2A
movlw   b'00010100'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00111110'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00010100'
movwf  CHR5
return



Char_2B
movlw   b'00001000'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00111110'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_2C
movlw   b'00000000'
movwf  CHR1
movlw   b'01010000'
movwf  CHR2
movlw   b'00110000'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_2D
movlw   b'00001000'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_2E
movlw   b'00000000'
movwf  CHR1
movlw   b'00110000'
movwf  CHR2
movlw   b'00110000'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_2F
movlw   b'00100000'
movwf  CHR1
movlw   b'00010000'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'00000010'
movwf  CHR5
return



Char_30
movlw   b'00111110'
movwf  CHR1
movlw   b'01010001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01000101'
movwf  CHR4
movlw   b'00111110'
movwf  CHR5
return



Char_31
movlw   b'00000000'
movwf  CHR1
movlw   b'01000010'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_32
movlw   b'01000010'
movwf  CHR1
movlw   b'01100001'
movwf  CHR2
movlw   b'01010001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'01000110'
movwf  CHR5
return



Char_33
movlw   b'00100001'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000101'
movwf  CHR3
movlw   b'01001011'
movwf  CHR4
movlw   b'00110001'
movwf  CHR5
return



Char_34
movlw   b'00011000'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00010010'
movwf  CHR3
movlw   b'01111111'
movwf  CHR4
movlw   b'00010000'
movwf  CHR5
return



Char_35
movlw   b'00100111'
movwf  CHR1
movlw   b'01000101'
movwf  CHR2
movlw   b'01000101'
movwf  CHR3
movlw   b'01000101'
movwf  CHR4
movlw   b'00111001'
movwf  CHR5
return



Char_36
movlw   b'00111100'
movwf  CHR1
movlw   b'01001010'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'00110000'
movwf  CHR5
return



Char_37
movlw   b'00000001'
movwf  CHR1
movlw   b'01110001'
movwf  CHR2
movlw   b'00001001'
movwf  CHR3
movlw   b'00000101'
movwf  CHR4
movlw   b'00000011'
movwf  CHR5
return



Char_38
movlw   b'00110110'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'00110110'
movwf  CHR5
return



Char_39
movlw   b'00000110'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'00101001'
movwf  CHR4
movlw   b'00011110'
movwf  CHR5
return



Char_3A
movlw   b'00000000'
movwf  CHR1
movlw   b'00110110'
movwf  CHR2
movlw   b'00110110'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_3B
movlw   b'00000000'
movwf  CHR1
movlw   b'01010110'
movwf  CHR2
movlw   b'00110110'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_3C
movlw   b'00001000'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00100010'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_3D
movlw   b'00010100'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00010100'
movwf  CHR3
movlw   b'00010100'
movwf  CHR4
movlw   b'00010100'
movwf  CHR5
return



Char_3E
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'00100010'
movwf  CHR3
movlw   b'00010100'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_3F
movlw   b'00000010'
movwf  CHR1
movlw   b'00000001'
movwf  CHR2
movlw   b'01010001'
movwf  CHR3
movlw   b'00001001'
movwf  CHR4
movlw   b'00000110'
movwf  CHR5
return



Char_40
movlw   b'00110010'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01111001'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00111110'
movwf  CHR5
return



Char_41
movlw   b'01111110'
movwf  CHR1
movlw   b'00010001'
movwf  CHR2
movlw   b'00010001'
movwf  CHR3
movlw   b'00010001'
movwf  CHR4
movlw   b'01111110'
movwf  CHR5
return



Char_42
movlw   b'01111111'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'00110110'
movwf  CHR5
return



Char_43
movlw   b'00111110'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00100010'
movwf  CHR5
return



Char_44
movlw   b'01111111'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'00100010'
movwf  CHR4
movlw   b'00011100'
movwf  CHR5
return



Char_45
movlw   b'01111111'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'00100010'
movwf  CHR4
movlw   b'00011100'
movwf  CHR5
return



Char_46
movlw   b'01111111'
movwf  CHR1
movlw   b'00001001'
movwf  CHR2
movlw   b'00001001'
movwf  CHR3
movlw   b'00001001'
movwf  CHR4
movlw   b'00000001'
movwf  CHR5
return



Char_47
movlw   b'00111110'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'01111010'
movwf  CHR5
return



Char_48
movlw   b'01111111'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'01111111'
movwf  CHR5
return



Char_49
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_4A
movlw   b'00100000'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'00111111'
movwf  CHR4
movlw   b'00000001'
movwf  CHR5
return



Char_4B
movlw   b'01111111'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00010100'
movwf  CHR3
movlw   b'00100010'
movwf  CHR4
movlw   b'01000001'
movwf  CHR5
return



Char_4C
movlw   b'01111111'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'01000000'
movwf  CHR5
return



Char_4D
movlw   b'01111111'
movwf  CHR1
movlw   b'00000010'
movwf  CHR2
movlw   b'00000100'
movwf  CHR3
movlw   b'00000010'
movwf  CHR4
movlw   b'01111111'
movwf  CHR5
return



Char_4E
movlw   b'01111111'
movwf  CHR1
movlw   b'00000100'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00010000'
movwf  CHR4
movlw   b'01111111'
movwf  CHR5
return



Char_4F
movlw   b'00111110'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00111110'
movwf  CHR5
return



Char_50
movlw   b'01111111'
movwf  CHR1
movlw   b'00001001'
movwf  CHR2
movlw   b'00001001'
movwf  CHR3
movlw   b'00001001'
movwf  CHR4
movlw   b'00000110'
movwf  CHR5
return



Char_51
movlw   b'00111110'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01010001'
movwf  CHR3
movlw   b'00100001'
movwf  CHR4
movlw   b'01011110'
movwf  CHR5
return



Char_52
movlw   b'01111111'
movwf  CHR1
movlw   b'00001001'
movwf  CHR2
movlw   b'00011001'
movwf  CHR3
movlw   b'00101001'
movwf  CHR4
movlw   b'01000110'
movwf  CHR5
return



Char_53
movlw   b'01000110'
movwf  CHR1
movlw   b'01001001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01001001'
movwf  CHR4
movlw   b'00110001'
movwf  CHR5
return



Char_54
movlw   b'00000001'
movwf  CHR1
movlw   b'00000001'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'00000001'
movwf  CHR4
movlw   b'00000001'
movwf  CHR5
return



Char_55
movlw   b'00111111'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00111111'
movwf  CHR5
return



Char_56
movlw   b'00011111'
movwf  CHR1
movlw   b'00100000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'00100000'
movwf  CHR4
movlw   b'00011111'
movwf  CHR5
return



Char_57
movlw   b'00111111'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'00111000'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00111111'
movwf  CHR5
return



Char_58
movlw   b'01100011'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00010100'
movwf  CHR4
movlw   b'01100011'
movwf  CHR5
return



Char_59
movlw   b'00000111'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'01110000'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00000111'
movwf  CHR5
return



Char_5A
movlw   b'01100001'
movwf  CHR1
movlw   b'01010001'
movwf  CHR2
movlw   b'01001001'
movwf  CHR3
movlw   b'01000101'
movwf  CHR4
movlw   b'01000011'
movwf  CHR5
return



Char_5B
movlw   b'00000000'
movwf  CHR1
movlw   b'01111111'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_5C
movlw   b'00000010'
movwf  CHR1
movlw   b'00000100'
movwf  CHR2
movlw   b'00001000'
movwf  CHR3
movlw   b'00010000'
movwf  CHR4
movlw   b'00100000'
movwf  CHR5
return



Char_5D
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01000001'
movwf  CHR3
movlw   b'01111111'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_5E
movlw   b'00000100'
movwf  CHR1
movlw   b'00000010'
movwf  CHR2
movlw   b'00000001'
movwf  CHR3
movlw   b'00000010'
movwf  CHR4
movlw   b'00000100'
movwf  CHR5
return



Char_5F
movlw   b'01000000'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'01000000'
movwf  CHR5
return



Char_60
movlw   b'00000000'
movwf  CHR1
movlw   b'00000001'
movwf  CHR2
movlw   b'00000010'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_61
movlw   b'00100000'
movwf  CHR1
movlw   b'01010100'
movwf  CHR2
movlw   b'01010100'
movwf  CHR3
movlw   b'01010100'
movwf  CHR4
movlw   b'01111000'
movwf  CHR5
return



Char_62
movlw   b'01111111'
movwf  CHR1
movlw   b'01001000'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'01000100'
movwf  CHR4
movlw   b'00111000'
movwf  CHR5
return

Char_63
movlw   b'00111000'
movwf  CHR1
movlw   b'01000100'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'01000100'
movwf  CHR4
movlw   b'00100000'
movwf  CHR5
return



Char_64
movlw   b'00111000'
movwf  CHR1
movlw   b'01000100'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'01001000'
movwf  CHR4
movlw   b'01111111'
movwf  CHR5
return



Char_65
movlw   b'00111000'
movwf  CHR1
movlw   b'01010100'
movwf  CHR2
movlw   b'01010100'
movwf  CHR3
movlw   b'01010100'
movwf  CHR4
movlw   b'00011000'
movwf  CHR5
return



Char_66
movlw   b'00001000'
movwf  CHR1
movlw   b'01111110'
movwf  CHR2
movlw   b'00001001'
movwf  CHR3
movlw   b'00000001'
movwf  CHR4
movlw   b'00000010'
movwf  CHR5
return



Char_67
movlw   b'00001100'
movwf  CHR1
movlw   b'01010010'
movwf  CHR2
movlw   b'01010010'
movwf  CHR3
movlw   b'01010010'
movwf  CHR4
movlw   b'00111110'
movwf  CHR5
return



Char_68
movlw   b'01111111'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00000100'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'01111000'
movwf  CHR5
return



Char_69
movlw   b'00000000'
movwf  CHR1
movlw   b'01000100'
movwf  CHR2
movlw   b'01111101'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_6A
movlw   b'00100000'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'00111101'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_6B
movlw   b'01111111'
movwf  CHR1
movlw   b'00010000'
movwf  CHR2
movlw   b'00101000'
movwf  CHR3
movlw   b'01000100'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_6C
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return

Char_6D
movlw   b'01111100'
movwf  CHR1
movlw   b'00000100'
movwf  CHR2
movlw   b'00011000'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'01111000'
movwf  CHR5
return



Char_6E
movlw   b'01111100'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00000100'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'01111000'
movwf  CHR5
return



Char_6F
movlw   b'00111000'
movwf  CHR1
movlw   b'01000100'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'01000100'
movwf  CHR4
movlw   b'00111000'
movwf  CHR5
return



Char_70
movlw   b'01111100'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00010100'
movwf  CHR3
movlw   b'00010100'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_71
movlw   b'00001000'
movwf  CHR1
movlw   b'00010100'
movwf  CHR2
movlw   b'00010100'
movwf  CHR3
movlw   b'00011000'
movwf  CHR4
movlw   b'01111100'
movwf  CHR5
return



Char_72
movlw   b'01111100'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00000100'
movwf  CHR3
movlw   b'00000100'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_73
movlw   b'01001000'
movwf  CHR1
movlw   b'01010100'
movwf  CHR2
movlw   b'01010100'
movwf  CHR3
movlw   b'01010100'
movwf  CHR4
movlw   b'00100000'
movwf  CHR5
return



Char_74
movlw   b'00000100'
movwf  CHR1
movlw   b'00111111'
movwf  CHR2
movlw   b'01000100'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00100000'
movwf  CHR5
return



Char_75
movlw   b'00111100'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'00100000'
movwf  CHR4
movlw   b'01111100'
movwf  CHR5
return



Char_76
movlw   b'00011100'
movwf  CHR1
movlw   b'00100000'
movwf  CHR2
movlw   b'01000000'
movwf  CHR3
movlw   b'00100000'
movwf  CHR4
movlw   b'00011100'
movwf  CHR5
return



Char_77
movlw   b'00111100'
movwf  CHR1
movlw   b'01000000'
movwf  CHR2
movlw   b'00110000'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00111100'
movwf  CHR5
return



Char_78
movlw   b'01000100'
movwf  CHR1
movlw   b'00101000'
movwf  CHR2
movlw   b'00010000'
movwf  CHR3
movlw   b'00101000'
movwf  CHR4
movlw   b'01000100'
movwf  CHR5
return



Char_79
movlw   b'00001100'
movwf  CHR1
movlw   b'01010000'
movwf  CHR2
movlw   b'01010000'
movwf  CHR3
movlw   b'01010000'
movwf  CHR4
movlw   b'00111100'
movwf  CHR5
return



Char_7A
movlw   b'01000100'
movwf  CHR1
movlw   b'01100100'
movwf  CHR2
movlw   b'01010100'
movwf  CHR3
movlw   b'01001100'
movwf  CHR4
movlw   b'01000100'
movwf  CHR5
return



Char_7B
movlw   b'00000000'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00110110'
movwf  CHR3
movlw   b'01000001'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_7C
movlw   b'00000000'
movwf  CHR1
movlw   b'00000000'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'00000000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_7D
movlw   b'00000000'
movwf  CHR1
movlw   b'01000001'
movwf  CHR2
movlw   b'00110110'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00000000'
movwf  CHR5
return



Char_7E
movlw   b'00001000'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00101010'
movwf  CHR3
movlw   b'00011100'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return



Char_7F
movlw   b'00001000'
movwf  CHR1
movlw   b'00011100'
movwf  CHR2
movlw   b'00101010'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return

Char_87
movlw   b'00001110'
movwf  CHR1
movlw   b'01010001'
movwf  CHR2
movlw   b'01110001'
movwf  CHR3
movlw   b'00110001'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return


Char_A8
movlw   b'00110000'
movwf  CHR1
movlw   b'01001000'
movwf  CHR2
movlw   b'01000101'
movwf  CHR3
movlw   b'01000000'
movwf  CHR4
movlw   b'00100000'
movwf  CHR5
return


Char_DB
movlw   b'01111111'
movwf  CHR1
movlw   b'01111111'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'01111111'
movwf  CHR4
movlw   b'01111111'
movwf  CHR5
return


Char_EA
movlw   b'01011100'
movwf  CHR1
movlw   b'00100010'
movwf  CHR2
movlw   b'00000010'
movwf  CHR3
movlw   b'00100010'
movwf  CHR4
movlw   b'01011100'
movwf  CHR5
return


Char_F6
movlw   b'00001000'
movwf  CHR1
movlw   b'00001000'
movwf  CHR2
movlw   b'00101010'
movwf  CHR3
movlw   b'00001000'
movwf  CHR4
movlw   b'00001000'
movwf  CHR5
return


Char_FB
movlw   b'00010000'
movwf  CHR1
movlw   b'00100000'
movwf  CHR2
movlw   b'01111111'
movwf  CHR3
movlw   b'00000001'
movwf  CHR4
movlw   b'00000001'
movwf  CHR5
return




END