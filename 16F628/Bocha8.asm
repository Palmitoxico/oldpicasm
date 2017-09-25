;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Desenvolvido por Augusto Fraga Giachero		;;
;;Cristal 4MHz									;;
;;												;;
;;												;;
;;												;;
;;Data: 06/04/2010								;;
;;												;;
;;PIC 16F628									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

processor 16F628
include <p16f628.inc>
__config _WDT_OFF & _PWRTE_ON & _XT_OSC & _LVP_OFF


Cont1	EQU 0x20					;Define as constantes de endereço
EE_DATA	EQU 0x20
Cont2	EQU 0x21
Dado	EQU 0x22
Letra	EQU 0x23
DSP1 	EQU 0x24
DSP2 	EQU 0x25
DSP3  	EQU 0x26
DSP4  	EQU 0x27
DSP5  	EQU 0x28
Multp.	EQU 0x29
delay1	EQU 0x2A
delay2	EQU 0x2B	
delay3	EQU 0x2C	
p_lcd 	EQU 0x2D
byte 	EQU 0x2E
N1_C 	EQU 0x2F
N2_C 	EQU 0x30
BIT_V 	EQU 0x31
Cont_e 	EQU 0x32

#define	CONTAR	BIT_V,0
#define	LQ		BIT_V,1
#define	BIP_V	BIT_V,2
#define	INICIO	PORTC,0
#define	CABO	PORTC,1
#define	FIM		PORTC,2
#define	START	PORTC,3
#define	BIP		PORTC,4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Definição de macrocomandos
BANK2 macro						;
bcf		STATUS,RP0				;
bsf		STATUS,RP1 			    ;Muda para o banco 2
Endm							;
								;
BANK1 macro						;
bsf		STATUS,RP0 			    ;Muda para o banco 1
bcf		STATUS,RP1				;
Endm							;
								;
BANK0 macro						;
bcf		STATUS,RP0  			    ;Volta ao banco 0
bcf		STATUS,RP1				;
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
;decfsz	Cont2 , 1				;A interrupção acontece a cada 100 milisegundos
;goto	INT_FIM					;Contador para ajustar o tempo de 100 milisegundos para 1 segundo
;movlw	.10						;
;movwf	Cont2					;
;btfss	CONTAR
;goto	FIM_INC
;btfsc	INICIO
;goto	Derrota
;decfsz	Cont2 , 1				;A interrupção acontece a cada 100 milisegundos
;goto	INT_FIM					;Contador para ajustar o tempo de 100 milisegundos para 1 segundo
;movlw	.100						;
;movwf	Cont2
;movlw	.10						;
;movwf	Cont1					;
;call	Limpar_LCD
;movf 	Cont_e,0 				;
;iorlw	0x30
;call	enviar_char_lcd		;
;call	ler_BF				;
;decfsz	Cont_e,1
;goto	INT_FIM
;call	Limpar_LCD
;bcf		CONTAR



movlw	.70
subwf	N2_C,0
btfsc	STATUS,Z	
bcf		BIP




FIM_INC
btfss	CABO
goto	Derrota
btfss	FIM
goto	Completo


movf	N1_C,1
btfsc	STATUS,Z
goto	N1_C_0

decfsz	N2_C,1
goto	Cont_FIM1
movlw	.99
movwf	N2_C
decfsz	N1_C,1
goto	Cont_FIM1
N1_C_0
decfsz	N2_C,1
goto	Cont_FIM1
goto	Tempo_expirado
Cont_FIM1
movlw	.7
call	Endereco_LCD

movf	N1_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP2,1
movf	DSP2,0
call	enviar_char_lcd			;
movf	N1_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP3,1
movf	DSP3,0
call	enviar_char_lcd			;


movlw	','					;
call	enviar_char_lcd		;


movf	N2_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP2,1
movf	DSP2,0
call	enviar_char_lcd			;
movf	N2_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP3,1
movf	DSP3,0
call	enviar_char_lcd			;
goto	INT_FIM
Tempo_expirado
BANK1						;
bcf		PIE1 , 0			;Desliga a contagem do timer 1
BANK0						;
call	Limpar_LCD
movlw 	'T'					;Escreve "Derrota!"
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'm'					;
call	enviar_char_lcd		;
movlw	'p'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	' '					;
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'x'					;
call	enviar_char_lcd		;
movlw	'p'					;
call	enviar_char_lcd		;
movlw	'i'					;
call	enviar_char_lcd		;
movlw	'r'					;
call	enviar_char_lcd		;
movlw	'a'					;
call	enviar_char_lcd		;
movlw	'd'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	'!'					;
call	enviar_char_lcd		;
bsf		BIP
call	Delay_1S
bcf		BIP
call	Delay_1S
call	Limpar_LCD
goto	Tela_init	

Derrota
BANK1						;
bcf		PIE1 , 0			;Desliga a contagem do timer 1
BANK0						;
call	Limpar_LCD
movlw 	'D'					;Escreve "Derrota!"
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'r'					;
call	enviar_char_lcd		;
movlw	'r'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	't'					;
call	enviar_char_lcd		;
movlw	'a'					;
call	enviar_char_lcd		;
movlw	'!'					;
call	enviar_char_lcd		;
bsf		BIP
call	Delay_1S
bcf		BIP
call	Delay_1S
call	Limpar_LCD
goto	Tela_init	

Completo
bcf		BIP
BANK1						;
bcf		PIE1 , 0			;Desliga a contagem do timer 1
BANK0						;
call	Limpar_LCD
movlw 	'P'					;Escreve "Percurso Completo!"
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'r'					;
call	enviar_char_lcd		;
movlw	'c'					;
call	enviar_char_lcd		;
movlw	'u'					;
call	enviar_char_lcd		;
movlw	'r'					;
call	enviar_char_lcd		;
movlw	's'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	' '					;
call	enviar_char_lcd		;
movlw	'c'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	'm'					;
call	enviar_char_lcd		;
movlw	'p'					;
call	enviar_char_lcd		;
movlw	'l'					;
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	't'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	'!'					;
call	enviar_char_lcd		;

call	Linha_2_LCD

movlw	'T'					;
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'm'					;
call	enviar_char_lcd		;
movlw	'p'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	':'					;
call	enviar_char_lcd		;

movf	N1_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP2,1
movf	DSP2,0
call	enviar_char_lcd			;
movf	N1_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP3,1
movf	DSP3,0
call	enviar_char_lcd			;

movlw	','					;
call	enviar_char_lcd		;

movf	N2_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP2,1
movf	DSP2,0
call	enviar_char_lcd			;
movf	N2_C,0
movwf	Dado
call	Converter
movlw	0x30
iorwf	DSP3,1
movf	DSP3,0
call	enviar_char_lcd			;

call	Delay_4S
call	Limpar_LCD
goto	Tela_init

INT_FIM							;
movlw	0xD8					;Recarrega o byte mais significativo do contador do timer 1
movwf	TMR1H					;
								;
movlw	0xF0					;Recarrega o byte menos significativo do contador do timer 1
movwf	TMR1L					;
bcf		PIR1 , TMR1IF			;Limpa a bandeira de interrupção do timer 1
retfie							;Termina a rotina da interrupção
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main							;Rotina principal
	movlw	.100				;
	movwf	Cont2				;
	movlw	.10					;
	movwf	Cont1				;
	movlw	.3					;
	movwf	Cont_e				;
	clrf	PORTB				;Limpa a porta B
	clrf	PORTC				;Limpa a porta C	
	clrf	PORTD				;Limpa a porta D
	clrf	PORTE				;Limpa a porta E		  
	clrf	p_lcd
	BANK1						;Vai para o banco 1 da memória
	bcf		OPTION_REG , 7	 	;Ativa os resistores PULL-UP da porta B
	clrf	TRISB				;Toda a porta B como saída
	bcf		BIP
	clrf	TRISE				;Toda a porta E como saída
	BANK0						;vai para o banco 0 da memória
	E_1
	call	Delay_0S5			;Delay de 500 milisegundos para garantir a inicialização de todos os componentes
								;
								;
								;
	call	Init_LCD			;Inicialização do display lcd
	call	Init_LCD			;Configuraçao: 2 linhas, 8 bits
								;Garante a inicialização do display
								;
	Tela_init
	movlw 	'>'					;Escreve ">>>>>Cabo<>Anel<<<<<"/">>>>>>>>START<<<<<<<<"
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'C'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'b'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'A'					;
	call	enviar_char_lcd		;
	movlw	'n'					;
	call	enviar_char_lcd		;
	movlw	'e'					;
	call	enviar_char_lcd		;
	movlw	'l'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	call	Linha_2_LCD			;Vai para a segunda linha do display
	movlw 	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw 	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'>'					;
	call	enviar_char_lcd		;
	movlw	'S'					;
	call	enviar_char_lcd		;
	movlw	'T'					;
	call	enviar_char_lcd		;
	movlw	'A'					;
	call	enviar_char_lcd		;
	movlw	'R'					;
	call	enviar_char_lcd		;
	movlw	'T'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
	movlw	'<'					;
	call	enviar_char_lcd		;
								;

	btfsc	START
	goto 	$-1
	call	Limpar_LCD

	movlw	'A'					;
	call	enviar_char_lcd		;
	movlw	'p'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	'i'					;
	call	enviar_char_lcd		;
	movlw	'e'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'n'					;
	call	enviar_char_lcd		;
	movlw	'e'					;
	call	enviar_char_lcd		;
	movlw	'l'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'n'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;


	call	Linha_2_LCD

	movlw	'g'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'n'					;
	call	enviar_char_lcd		;
	movlw	'c'					;
	call	enviar_char_lcd		;
	movlw	'h'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'd'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'i'					;
	call	enviar_char_lcd		;
	movlw	'n'					;
	call	enviar_char_lcd		;
	movlw	'i'					;
	call	enviar_char_lcd		;
	movlw	'c'					;
	call	enviar_char_lcd		;
	movlw	'i'					;
	call	enviar_char_lcd		;
	movlw	'o'					;
	call	enviar_char_lcd		;
	
	btfsc	INICIO
	goto 	$-1
	call	Limpar_LCD
	bsf		CONTAR
	bcf		LQ
	movlw	'3'					;
	call	enviar_char_lcd		;
	call	Delay_1S
	btfsc	LQ
	goto	Wait_Start
	call	Limpar_LCD
	movlw	'2'					;
	call	enviar_char_lcd		;
	call	Delay_1S_V
	btfsc	LQ
	goto	Wait_Start
	call	Limpar_LCD
	movlw	'1'					;
	call	enviar_char_lcd		;
	call	Delay_1S_V
	btfsc	LQ
	goto	Wait_Start
	goto	Wait_Start_FIM

Wait_Start

	call	Delay_2S
	call	Limpar_LCD
	goto	Tela_init

Wait_Start_FIM
call	Limpar_LCD
movlw	'T'					;
call	enviar_char_lcd		;
movlw	'e'					;
call	enviar_char_lcd		;
movlw	'm'					;
call	enviar_char_lcd		;
movlw	'p'					;
call	enviar_char_lcd		;
movlw	'o'					;
call	enviar_char_lcd		;
movlw	':'					;
call	enviar_char_lcd		;
movlw	.30
movwf	N1_C
movlw	.1
movwf	N2_C

	movlw	b'11000000'			;
	movwf	INTCON				;
	movlw	b'00000001'			;
	movwf	T1CON				;
	movlw	0xD8				;
	movwf	TMR1H				;Carrega o byte mais significativo do contador do timer 1
								;
	movlw	0xF0				;Carrega o byte menos significativo do contador do timer 1
	movwf	TMR1L				;
	bsf		BIP
	BANK1						;
	bsf		PIE1 , 0			;Liga a contagem do timer 1
	BANK0	
	goto	$+0
	
sleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;Começo das sub-rotinas:
	Limpar_LCD					;
	movlw	b'00000001'
	call	enviar_byte_lcd		;Envia o comando
	call	Delay_2mS			;	
	return

	Init_LCD
	E_1
	movlw	0x38				;Inicialização do display lcd
	call	enviar_byte_lcd		;Configuraçao: 2 linhas, 8 bits
	call	Delay_40uS			;
	movlw	0x0C				;
	call	enviar_byte_lcd		;
	call	Delay_40uS			;
	call	Limpar_LCD			;Limpa o display
	return

	enviar_byte_lcd				;Sub-rotina para enviar um byte para o display lcd
	movwf	byte				;
	movf	byte,0
	movwf	PORTB				;Coloca o dado na porta B
	E_0							;Coloca o pino enable em 0
	E_1							;Volta o pino enable em 1
	return						;Retorna da sub-rotina

	enviar_char_lcd				;Sub-rotina para enviar um caracter para o display lcd
	movwf	byte				;
	movlw	0x05				;
	movwf	PORTE				;
	movf	byte , 0
	movwf	PORTB				;Coloca o dado na porta B
	movlw	0x01				;Coloca o pino enable em 0
	movwf	PORTE
	movlw	0x04				;Volta o pino enable em 1
	movwf	PORTE
	call	Delay_40uS			;
	return						;Retorna da sub-rotina
								;
								;

	Endereco_LCD
	iorlw	b'10000000'
	call	enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return

	Linha_1_LCD
	movlw	b'10000000'
	call	enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return	

	Linha_2_LCD
	movlw	b'11000000'
	call	enviar_byte_lcd		;Envia o comando
	call	Delay_40uS			;
	return

Delay_40uS
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


Delay_2mS
			;1993 cycles
	movlw	0x8E
	movwf	delay1
	movlw	0x02
	movwf	delay2
Delay_2mS_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	Delay_2mS_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return


Delay_0S5
			;499994 cycles
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_0S5_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_0S5_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


Delay_2S
			;1999996 cycles
	movlw	0x11
	movwf	delay1
	movlw	0x5D
	movwf	delay2
	movlw	0x05
	movwf	delay3
Delay_2S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_2S_0

			;4 cycles (including call)
	return

Delay_4S
			;3999994 cycles
	movlw	0x23
	movwf	delay1
	movlw	0xB9
	movwf	delay2
	movlw	0x09
	movwf	delay3
Delay_4S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_4S_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return

Delay_1S
			;999990 cycles
	movlw	0x07
	movwf	delay1
	movlw	0x2F
	movwf	delay2
	movlw	0x03
	movwf	delay3
Delay_1S_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_1S_0

			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return



Delay_1S_V
			;499994 cycles
	bcf		LQ
	movlw	0x03
	movwf	delay1
	movlw	0x18
	movwf	delay2
	movlw	0x02
	movwf	delay3
Delay_1S_V_0
	btfss	INICIO
	goto	Fim_LQ
	call	Limpar_LCD
	movlw	'L'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'g'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'r'					;
	call	enviar_char_lcd		;
	movlw	'd'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	' '					;
	call	enviar_char_lcd		;
	movlw	'q'					;
	call	enviar_char_lcd		;
	movlw	'u'					;
	call	enviar_char_lcd		;
	movlw	'e'					;
	call	enviar_char_lcd		;
	movlw	'i'					;
	call	enviar_char_lcd		;
	movlw	'm'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	movlw	'd'					;
	call	enviar_char_lcd		;
	movlw	'a'					;
	call	enviar_char_lcd		;
	bsf		LQ
	return
Fim_LQ
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	$+2
	decfsz	delay3, f
	goto	Delay_1S_V_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return


	
	Converter
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
	return
								;
END								;Fim do programa
