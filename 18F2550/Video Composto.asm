;//////////////////////////////////////////////////////////////////////////////////////////////////// 
#INCLUDE <P18F2550.INC>


			CONFIG PLLDIV = 5			;ACEITA APENAS 20 MHZ NO BLOCO -> 96MHZ PLL (4 X 1 = 4MHZ)DIV 1,2,3,4,5,6,10 e 12
			CONFIG CPUDIV = OSC1_PLL2 	;2,3,4 ou 6 
;...................... 20 MHZ CRISTAL .........................................
			;PLLDIV = 5 / / 20MHz / 5 = 4 MHz, a entrada para a 96 MHz PLL
			;CPUDIV = OSC1_PLL2 / / CPU Clock = 96 MHz / 2 = 48 MHz
			;USBDIV = 2 / 96MHz PLL / 2 = 48 MHz para o relógio USB
			;FOSC = HSPLL_HS / tipo / OSC: High Speed Crystal / Resonator com PLL habilitado
			;VREGEN = ON / USB Interno regulador de tensão habilitada
;==================================================
;   CPU System Clock Postscaler:
;     CPUDIV = OSC1_PLL2   [OSC1/OSC2 Src: /1][96 MHz PLL Src: /2]
;     CPUDIV = OSC2_PLL3   [OSC1/OSC2 Src: /2][96 MHz PLL Src: /3]
;     CPUDIV = OSC3_PLL4   [OSC1/OSC2 Src: /3][96 MHz PLL Src: /4]
;     CPUDIV = OSC4_PLL6   [OSC1/OSC2 Src: /4][96 MHz PLL Src: /6]
;..............................................................
			CONFIG USBDIV = 2			;1 OU 2
			CONFIG FOSC = 	HSPLL_HS	;CRYSTAL/RESONATOR WITH PLL ENABLED / CRYSTAL/RESONATOR
			CONFIG FCMEN = 	OFF			;FCMEN: FAIL-SAFE CLOCK MONITOR ENABLE BIT
			CONFIG IESO = 	OFF			;IESO: INTERNAL/EXTERNAL OSCILLATOR SWITCHOVER BIT
			CONFIG PWRT = 	ON			;PWRTEN: POWER-UP TIMER ENABLE BIT()
;			CONFIG BOR = 	ON			;BROWN-OUT RESET()
			CONFIG BOR = 	OFF			;BROWN-OUT RESET()
			CONFIG BORV = 	2			;BORV1:BORV0: BROWN-OUT RESET VOLTAGE BITS
			CONFIG VREGEN = ON			;VREGEN: USB INTERNAL VOLTAGE REGULATOR ENABLE BIT(REGULADOR INTERNO 3,3V(VUSB PINO 14))
			CONFIG WDT = 	OFF			;WATCHDOG TIMER
			CONFIG WDTPS = 	32768		;WATCHDOG TIMER POSTSCALE
			CONFIG MCLRE = 	ON			;MCLR PIN ENABLE BIT
			CONFIG LPT1OSC = OFF		;LPT1OSC: LOW-POWER TIMER1 OSCILLATOR ENABLE BIT
			CONFIG PBADEN = OFF			;PBADEN: PORTB A/D ENABLE BIT (ANALOGICO OU DIGITAL NOS PINOS)
;			CONFIG PBADEN = ON			;PBADEN: PORTB A/D ENABLE BIT (ANALOGICO OU DIGITAL NOS PINOS)
;====================================================================================================================
			CONFIG CCP2MX = ON			;CCP2MX: CCP2 MUX bit,DETERMINA QUAL PINO CCP2(CAPTURE INPUT,COMPARE E PWM OUTPUT) SERÁ MULTIPLEXADO(RC1 PADRÃO)RB3 SE CLEAR
			CONFIG STVREN = OFF			;STVREN: STACK FULL/UNDERFLOW RESET ENABLE BIT (SE STACK CHEIO OU UNDERFLOW CAUSA RESET)
			CONFIG LVP = 	OFF			;LVP: SINGLE-SUPPLY ICSP™ ENABLE BIT (LVP ,BAIXA VOLTAGEM DE PROGRAMAÇÃO //SE HABILITADO, RB5/KBI1/PGM É USADO)
		;	CONFIG ICPRT = OFF  ;AVAILABLE ONLY ON PIC18F4455/4550 DEVICES IN 44-PIN TQFP PACKAGES.
			CONFIG XINST = OFF			;XINST: EXTENDED INSTRUCTION SET ENABLE BIT (INCLUI 8 INSTRUÇÕES A MAIS (ADDFSR,ADDULNK,CALLW,MOVSF,MOVSS,PUSHL,SUBFSR E SUBULNK))
			CONFIG DEBUG = OFF			;DEBUG: BACKGROUND DEBUGGER ENABLE BIT (SE BIT ZERADO,RB6 E RB7 FICAM PARA INCIRCUIT DEBUG//SE SETADO RB6 E RB7 = I/O)
			CONFIG CP0 = OFF			;CP0: CODE PROTECTION BIT ,BLOCK 0 (000800-001FFFH)
			CONFIG CP1 = OFF			;CP1: CODE PROTECTION BIT ,BLOCK 1 (002000-003FFFH)
			CONFIG CP2 = OFF			;CP2: CODE PROTECTION BIT ,BLOCK 2 (004000-005FFFH)
			CONFIG CP3 = OFF			;CP3: CODE PROTECTION BIT ,BLOCK 3 (006000-007FFFH)
			CONFIG CPB = OFF			;CPB: BOOT BLOCK CODE PROTECTION BIT (BOOT BLOCK (000000-0007FFH))
			CONFIG CPD = OFF			;CPD: DATA EEPROM CODE PROTECTION BIT (Data EEPROM)
			CONFIG WRT0 = OFF			;WRT0: WRITE PROTECTION BIT (1 = BLOCK 0, (000800-001FFFH) OR (001000-001FFFH) IS NOT WRITE-PROTECTED)
			CONFIG WRT1 = OFF			;WRT1: WRITE PROTECTION BIT (1 = BLOCK 1, IS NOT WRITE-PROTECTED(002000-003FFFH))
			CONFIG WRT2 = OFF			;WRT2: WRITE PROTECTION BIT (1 = BLOCK 2, (004000-005FFFH) IS NOT WRITE-PROTECTED)
			CONFIG WRT3 = OFF			;WRT3: WRITE PROTECTION BIT (1 = BLOCK 3, (006000-007FFFH) IS NOT WRITE-PROTECTED)
			CONFIG WRTB = OFF			;WRTB: BOOT BLOCK WRITE PROTECTION BIT (1 = BOOT BLOCK (000000-0007FFH) IS NOT WRITE-PROTECTED)
			CONFIG WRTC = OFF			;WRTC: CONFIGURATION REGISTER WRITE PROTECTION BIT(1 = CONFIGURATION REGISTERS (300000-3000FFH) ARE NOT WRITE-PROTECTED)
			CONFIG WRTD = OFF			;WRTD: DATA EEPROM WRITE PROTECTION BIT	(1 = DATA EEPROM IS NOT WRITE-PROTECTED)
			CONFIG EBTR0 = OFF			;EBTR0: TABLE READ PROTECTION BIT (1 = BLOCK 0, (000800-001FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
			CONFIG EBTR1 = OFF			;EBTR1: TABLE READ PROTECTION BIT (1 = BLOCK 1, (002000-003FFFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
			CONFIG EBTR2 = OFF			;EBTR2: TABLE READ PROTECTION BIT (1 = BLOCK 2, (004000-005FFFH) NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
			CONFIG EBTR3 = OFF			;EBTR3: TABLE READ PROTECTION BIT (1 = BLOCK 3, (006000-007FFFH) NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)
			CONFIG EBTRB = OFF			;EBTRB: BOOT BLOCK TABLE READ PROTECTION BIT (1 = BOOT BLOCK (000000-0007FFH) IS NOT PROTECTED FROM TABLE READS EXECUTED IN OTHER BLOCKS)

		

;*******************************************************************
BANK0				UDATA	
delay1				RES 1
delay2				RES 1
delay3				RES 1
Count1				RES	1



	
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///; INICIO DO CÓDIGO PRINCIPAL /////////////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
APPLICATION	CODE
MAIN
		movlw	0b11111100
		movwf	TRISC
		clrf	PORTC
		movlw	0b11111110
		movwf	TRISB
PIC_2HZ
bsf		PORTB,0
call	Delay_500ms
bcf		PORTB,0
call	Delay_500ms
bra		PIC_2HZ


Loop:	
		clrf	PORTC
		rcall	Delay_4us
		bsf		PORTC,0
		rcall	Delay_4us
		rcall	Delay_4us
		bcf		PORTC,1
		rcall	Delay_280C
		bsf		PORTC,1
		rcall	Delay_26us
		rcall	Delay_4us
		btfss	PORTB,0
		bra		Loop

Loop2:	
		clrf	PORTC
		rcall	Delay_4us
		bsf		PORTC,0
		rcall	Delay_4us
		rcall	Delay_4us
		bsf		PORTC,1
		rcall	Delay_280C
		bsf		PORTC,1
		rcall	Delay_26us
		rcall	Delay_4us

		clrf	PORTC
		rcall	Delay_4us
		bsf		PORTC,0
		rcall	Delay_4us
		rcall	Delay_4us
		bcf		PORTC,1
		rcall	Delay_280C
		bcf		PORTC,1
		rcall	Delay_26us
		rcall	Delay_4us

		clrf	PORTC
		rcall	Delay_4us
		bsf		PORTC,0
		rcall	Delay_4us
		rcall	Delay_4us
		bcf		PORTC,1
		rcall	Delay_280C
		bcf		PORTC,1
		rcall	Delay_26us
		rcall	Delay_4us

		clrf	PORTC
		rcall	Delay_4us
		bsf		PORTC,0
		rcall	Delay_4us
		rcall	Delay_4us
		bcf		PORTC,1
		rcall	Delay_280C
		bcf		PORTC,1
		rcall	Delay_26us
		rcall	Delay_4us


		btfsc	PORTB,0
		bra		Loop2
		bra		Loop

Delay_500ms
			;11999993 cycles
	movlw	0x36
	movwf	delay1
	movlw	0x15
	movwf	delay2
	movlw	0x0E
	movwf	delay3
Delay_1s_0
	decfsz	delay1, f
	bra		Delay_1s_1
	decfsz	delay2, f
Delay_1s_1
	bra		Delay_1s_2
	decfsz	delay3, f
Delay_1s_2
	bra		Delay_1s_0

	nop

			;4 cycles (including call)
	return


Delay_280C:
			;274 cycles
	movlw	0x5B
	movwf	delay1
Delay_280C_0
	decfsz	delay1, f
	bra		Delay_280C_0

			;2 cycles
	nop
	nop

			;4 cycles (including call)
	return


Delay_4us:
			;43 cycles
	movlw	0x0E
	movwf	delay1
Delay_4us_0
	decfsz	delay1, f
	bra		Delay_4us_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

Delay_26us:
			;307 cycles
	movlw	0x66
	movwf	delay1
Delay_26us_0
	decfsz	delay1, f
	bra		Delay_26us_0

			;1 cycle
	nop

			;4 cycles (including call)
	return




	END
