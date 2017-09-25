; -------------------------------------------------------------------------
; Projeto: Configuração padrão da placa ClpPic40-v3.
; Microcontrolador: PIC16F877A
; Data: 01/08/2010
; Autor: Wagner Santos Maurício.
; Obs.:
; Precisão:
; Versão: 3.0
; -------------------------------------------------------------------------
#include<P16F877A.INC>
__CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _BODEN_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC
; _CP_OFF Memória de programa desprotegida contra leitura;
; _WRT_OFF Sem permissão para escrever na memória de programa durante execução do programa;
; _DEBUG_OFF Debug desativado;
; _CPD_OFF Memória Eeprom protegida contra leitura;
; _LVP_OFF Programação em baixa tensão desabilitada;
; _WDT_OFF WDT desativado;
; _BODEN_OFF Brown - out desativado;
; _PWRTE_ON Power-on reset ativado;
; _XT_OSC Oscilador a cristal (4MHz)
ERRORLEVEL -302
#DEFINE BANK1 BSF STATUS,RP0 ;VAI PARA O BANCO 1
#DEFINE BANK0 BCF STATUS,RP0 ;VAI PARA O BANCO 0
;#DEFINE DISP_LCD PORTB ;UTILIZADO PARA LCD
;#DEFINE RS PORTB,4 ;UTILIZADO PARA LCD
;#DEFINE ENABLE PORTB,5 ;UTILIZADO PARA LCD
#DEFINE E1 PORTD,0 ;ENTRADA E1
#DEFINE E2 PORTD,1 ;ENTRADA E2
#DEFINE E3 PORTD,2 ;ENTRADA E3
#DEFINE E4 PORTD,3 ;ENTRADA E4
#DEFINE E5 PORTD,4 ;ENTRADA E5
#DEFINE E6 PORTD,5 ;ENTRADA E6
#DEFINE E7 PORTD,6 ;ENTRADA E7
#DEFINE E8 PORTD,7 ;ENTRADA E8
#DEFINE E9 PORTA,1 ;ENTRADA E9
#DEFINE E10 PORTA,2 ;ENTRADA E10
#DEFINE E11 PORTA,4 ;ENTRADA E11
#DEFINE E12 PORTA,3 ;ENTRADA E12
#DEFINE LIGA_SAIDA1 BSF PORTC,0 ;SAIDA 1
#DEFINE DESLIGA_SAIDA1 BCF PORTC,0 ;SAIDA 1
#DEFINE LIGA_SAIDA2 BSF PORTC,2 ;SAIDA 2
#DEFINE DESLIGA_SAIDA2 BCF PORTC,2 ;SAIDA 2
#DEFINE LIGA_SAIDA3 BSF PORTC,1 ;SAIDA 3
#DEFINE DESLIGA_SAIDA3 BCF PORTC,1 ;SAIDA 3
#DEFINE LIGA_SAIDA4 BSF PORTA,5 ;SAIDA 4
#DEFINE DESLIGA_SAIDA4 BCF PORTA,5 ;SAIDA 4
#DEFINE LIGA_SAIDA5 BSF PORTE,0 ;SAIDA 5
#DEFINE DESLIGA_SAIDA5 BCF PORTE,0 ;SAIDA 5
#DEFINE LIGA_SAIDA6 BSF PORTE,1 ;SAIDA 6
#DEFINE DESLIGA_SAIDA6 BCF PORTE,1 ;SAIDA 6
#DEFINE LIGA_SAIDA7 BSF PORTE,2 ;SAIDA 7
#DEFINE DESLIGA_SAIDA7 BCF PORTE,2 ;SAIDA 7
#DEFINE LIGA_SAIDA8 BSF PORTC,5 ;SAIDA 8
#DEFINE DESLIGA_SAIDA8 BCF PORTC,5 ;SAIDA 8
CBLOCK 0X20
delay1
delay2
delay3
ENDC
; .....................................................................................
ORG 0x00
GOTO CONFIGURACAO
; .....................................................................................
ORG 0X04
RETFIE
;.....................................................................................
BANK1
;"1" É ENTRADA E "0" É SAIDA
MOVLW B'11011111' ; RA0 pode ser entrada analógica ou entrada/saída TTL, se não for utilizar deixe como entrada (TTL)="1"
MOVWF TRISA ; RA1, RA2 e RA3 só pode ser configurado como entrada - "1"
; RA4 pode ser entrada (E12) ou saida TTL (RS485) - no momento está configurado como entrada (E12)
; RA5 deve ser configurado como saída - "0"
; RA6 e RA7 deixe sempre como entrada = "1"
MOVLW B'11111111' ; Se não for utilizar o conector LCD deixe sempre configurado como entrada todos os pinos = "1".
MOVWF TRISB
MOVLW B'11011000' ; RC0, RC1, RC2 e RC5 devem ser configurados sempre como saída = "0"
MOVWF TRISC ; RC3 e RC4 é utilizado para comunicação I2C (Memória EEprom e/ou RTC), deixe como entrada = "1"
; RC6 e RC7 são utilizados para RS232 ou RS485, deixe como entrada = "1".
MOVLW B'11111111' ;Todo PortD deve ser configurado como entrada = "1".
MOVWF TRISD ;
MOVLW B'00000000' ; RE0,RE1 e RE2 deve ser configurado como saida = "0"
MOVWF TRISE ; ou seja todo o port deve ficar como está

MOVLW B'00001111' ;Bit 7 RBPU: PORTB Pull-up Enable bit
MOVWF OPTION_REG ; 1 = PORTB pull-ups are disabled
; 0 = PORTB pull-ups are enabled by individual port latch values
;Bit 6 INTEDG: Interrupt Edge Select bit
; 1 = Interrupt on rising edge of RB0/INT pin
; 0 = Interrupt on falling edge of RB0/INT pin
;Bit 5 T0CS: TMR0 Clock Source Select bit
; 1 = Transition on RA4/T0CKI pin
; 0 = Internal instruction cycle clock (CLKO)
;Bit 4 T0SE: TMR0 Source Edge Select bit
; 1 = Increment on high-to-low transition on RA4/T0CKI pin
; 0 = Increment on low-to-high transition on RA4/T0CKI pin
;Bit 3 PSA: Prescaler Assignment bit
; 1 = Prescaler is assigned to the WDT
; 0 = Prescaler is assigned to the Timer0 module
;Bit 2-0 PS2:PS0: Prescaler Rate Select bits
;Legend:
;VALOR TMR0 WDT
;000 1:2 1:1
;001 1:4 1:2
;010 1:8 1:4
;011 1:16 1:8
;100 1:32 1:16
;101 1:64 1:32
;110 1:128 1:64
;111 1:256 1:128
MOVLW B'11000000' ;Bit 7 GIE: Global Interrupt Enable bit
MOVWF INTCON ; 1 = Enables all unmasked interrupts
; 0 = Disables all interrupts
;Bit 6 PEIE: Peripheral Interrupt Enable bit
; 1 = Enables all unmasked peripheral interrupts
; 0 = Disables all peripheral interrupts
;Bit 5 TMR0IE: TMR0 Overflow Interrupt Enable bit
; 1 = Enables the TMR0 interrupt
; 0 = Disables the TMR0 interrupt
;Bit 4 INTE: RB0/INT External Interrupt Enable bit
; 1 = Enables the RB0/INT external interrupt
; 0 = Disables the RB0/INT external interrupt
;Bit 3 RBIE: RB Port Change Interrupt Enable bit
; 1 = Enables the RB port change interrupt
; 0 = Disables the RB port change interrupt
;Bit 2 TMR0IF: TMR0 Overflow Interrupt Flag bit
; 1 = TMR0 register has overflowed (must be cleared in software)
; 0 = TMR0 register did not overflow
;Bit 1 INTF: RB0/INT External Interrupt Flag bit
; 1 = The RB0/INT external interrupt occurred (must be cleared in software)
; 0 = The RB0/INT external interrupt did not occur
;Bit 0 RBIF: RB Port Change Interrupt Flag bit
; 1 = At least one of the RB7:RB4 pins changed state; a mismatch condition will continue to set
; the bit. Reading PORTB will end the mismatch condition and allow the bit to be cleared
; (must be cleared in software).
; 0 = None of the RB7:RB4 pins have changed state
MOVLW B'00000001' ;Bit 7 PSPIE: Parallel Slave Port Read/Write Interrupt Enable bit(1)
MOVWF PIE1 ; 1 = Enables the PSP read/write interrupt
; 0 = Disables the PSP read/write interrupt
; Note 1: PSPIE is reserved on PIC16F873A/876A devices; always maintain this bit clear.
;Bit 6 ADIE: A/D Converter Interrupt Enable bit
; 1 = Enables the A/D converter interrupt
; 0 = Disables the A/D converter interrupt
;Bit 5 RCIE: USART Receive Interrupt Enable bit
; 1 = Enables the USART receive interrupt
; 0 = Disables the USART receive interrupt
;Bit 4 TXIE: USART Transmit Interrupt Enable bit
; 1 = Enables the USART transmit interrupt
; 0 = Disables the USART transmit interrupt
;Bit 3 SSPIE: Synchronous Serial Port Interrupt Enable bit
; 1 = Enables the SSP interrupt
; 0 = Disables the SSP interrupt
;Bit 2 CCP1IE: CCP1 Interrupt Enable bit
; 1 = Enables the CCP1 interrupt
; 0 = Disables the CCP1 interrupt
;Bit 1 TMR2IE: TMR2 to PR2 Match Interrupt Enable bit
; 1 = Enables the TMR2 to PR2 match interrupt
; 0 = Disables the TMR2 to PR2 match interrupt
;Bit 0 TMR1IE: TMR1 Overflow Interrupt Enable bit
; 1 = Enables the TMR1 overflow interrupt
; 0 = Disables the TMR1 overflow interrupt
MOVLW B'00000000' ;Bit 7 Unimplemented: Read as '0'
MOVWF PIE2 ;Bit 6 CMIE: Comparator Interrupt Enable bit
; 1 = Enables the comparator interrupt
; 0 = Disable the comparator interrupt
;Bit 5 Unimplemented: Read as '0'
;Bit 4 EEIE: EEPROM Write Operation Interrupt Enable bit
; 1 = Enable EEPROM write interrupt
; 0 = Disable EEPROM write interrupt
;Bit 3 BCLIE: Bus Collision Interrupt Enable bit
; 1 = Enable bus collision interrupt
; 0 = Disable bus collision interrupt
;Bit 2-1 Unimplemented: Read as '0'
;Bit 0 CCP2IE: CCP2 Interrupt Enable bit
; 1 = Enables the CCP2 interrupt
; 0 = Disables the CCP2 interrupt
MOVLW B'00000101' ;Bit 0,LIGA E DESLIGA A ENTRADA ANALÓGICA - BIT 2, STATUS ANALÓGICO
MOVWF ADCON0
MOVLW B'00001110' ;B'00001110' - An0 somente será analógico e restante digital
MOVWF ADCON1
MOVLW B'11000000' ;Bit 7 GIE: Global Interrupt Enable bit
MOVWF INTCON ; 1 = Enables all unmasked interrupts
; 0 = Disables all interrupts
;Bit 6 PEIE: Peripheral Interrupt Enable bit
; 1 = Enables all unmasked peripheral interrupts
; 0 = Disables all peripheral interrupts
;Bit 5 TMR0IE: TMR0 Overflow Interrupt Enable bit
; 1 = Enables the TMR0 interrupt
; 0 = Disables the TMR0 interrupt
;Bit 4 INTE: RB0/INT External Interrupt Enable bit
; 1 = Enables the RB0/INT external interrupt
; 0 = Disables the RB0/INT external interrupt
;Bit 3 RBIE: RB Port Change Interrupt Enable bit
; 1 = Enables the RB port change interrupt
; 0 = Disables the RB port change interrupt
;Bit 2 TMR0IF: TMR0 Overflow Interrupt Flag bit
; 1 = TMR0 register has overflowed (must be cleared in software)
; 0 = TMR0 register did not overflow
;Bit 1 INTF: RB0/INT External Interrupt Flag bit
; 1 = The RB0/INT external interrupt occurred (must be cleared in software)
; 0 = The RB0/INT external interrupt did not occur
;Bit 0 RBIF: RB Port Change Interrupt Flag bit
; 1 = At least one of the RB7:RB4 pins changed state; a mismatch condition will continue to set
; the bit. Reading PORTB will end the mismatch condition and allow the bit to be cleared
; (must be cleared in software).
; 0 = None of the RB7:RB4 pins have changed state
MOVLW B'00000001' ;Bit 7 PSPIE: Parallel Slave Port Read/Write Interrupt Enable bit(1)
MOVWF PIE1 ; 1 = Enables the PSP read/write interrupt
; 0 = Disables the PSP read/write interrupt
; Note 1: PSPIE is reserved on PIC16F873A/876A devices; always maintain this bit clear.
;Bit 6 ADIE: A/D Converter Interrupt Enable bit
; 1 = Enables the A/D converter interrupt
; 0 = Disables the A/D converter interrupt
;Bit 5 RCIE: USART Receive Interrupt Enable bit
; 1 = Enables the USART receive interrupt
; 0 = Disables the USART receive interrupt
;Bit 4 TXIE: USART Transmit Interrupt Enable bit
; 1 = Enables the USART transmit interrupt
; 0 = Disables the USART transmit interrupt
;Bit 3 SSPIE: Synchronous Serial Port Interrupt Enable bit
; 1 = Enables the SSP interrupt
; 0 = Disables the SSP interrupt
;Bit 2 CCP1IE: CCP1 Interrupt Enable bit
; 1 = Enables the CCP1 interrupt
; 0 = Disables the CCP1 interrupt
;Bit 1 TMR2IE: TMR2 to PR2 Match Interrupt Enable bit
; 1 = Enables the TMR2 to PR2 match interrupt
; 0 = Disables the TMR2 to PR2 match interrupt
;Bit 0 TMR1IE: TMR1 Overflow Interrupt Enable bit
; 1 = Enables the TMR1 overflow interrupt
; 0 = Disables the TMR1 overflow interrupt
MOVLW B'00000000' ;Bit 7 Unimplemented: Read as '0'
MOVWF PIE2 ;Bit 6 CMIE: Comparator Interrupt Enable bit
; 1 = Enables the comparator interrupt
; 0 = Disable the comparator interrupt
;Bit 5 Unimplemented: Read as '0'
;Bit 4 EEIE: EEPROM Write Operation Interrupt Enable bit
; 1 = Enable EEPROM write interrupt
; 0 = Disable EEPROM write interrupt
;Bit 3 BCLIE: Bus Collision Interrupt Enable bit
; 1 = Enable bus collision interrupt
; 0 = Disable bus collision interrupt
;Bit 2-1 Unimplemented: Read as '0'
;Bit 0 CCP2IE: CCP2 Interrupt Enable bit
; 1 = Enables the CCP2 interrupt
; 0 = Disables the CCP2 interrupt
MOVLW B'00000101' ;Bit 0,LIGA E DESLIGA A ENTRADA ANALÓGICA - BIT 2, STATUS ANALÓGICO
MOVWF ADCON0
MOVLW B'00001110' ;B'00001110' - An0 somente será analógico e restante digital
MOVWF ADCON1 ;CONVERSOR A-D (RA0 LIGADO)

BANK0
MOVLW B'00000000' ;Bit 7 PSPIF: Parallel Slave Port Read/Write Interrupt Flag bit(1)
MOVWF PIR1 ; 1 = A read or a write operation has taken place (must be cleared in software)
; 0 = No read or write has occurred
; Note 1: PSPIF is reserved on PIC16F873A/876A devices; always maintain this bit clear.
;Bit 6 ADIF: A/D Converter Interrupt Flag bit
; 1 = An A/D conversion completed
; 0 = The A/D conversion is not complete
;Bit 5 RCIF: USART Receive Interrupt Flag bit
; 1 = The USART receive buffer is full
; 0 = The USART receive buffer is empty
;Bit 4 TXIF: USART Transmit Interrupt Flag bit
; 1 = The USART transmit buffer is empty
; 0 = The USART transmit buffer is full
;Bit 3 SSPIF: Synchronous Serial Port (SSP) Interrupt Flag bit
; 1 = The SSP interrupt condition has occurred and must be cleared in software before returning
; from the Interrupt Service Routine. The conditions that will set this bit are:
; . SPI - A transmission/reception has taken place.
; . I2C Slave - A transmission/reception has taken place.
; . I2C Master
; - A transmission/reception has taken place.
; - The initiated Start condition was completed by the SSP module.
; - The initiated Stop condition was completed by the SSP module.
; - The initiated Restart condition was completed by the SSP module.
; - The initiated Acknowledge condition was completed by the SSP module.
; - A Start condition occurred while the SSP module was Idle (multi-master system).
; - A Stop condition occurred while the SSP module was Idle (multi-master system).
; 0 = No SSP interrupt condition has occurred
;Bit 2 CCP1IF: CCP1 Interrupt Flag bit
; Capture mode:
; 1 = A TMR1 register capture occurred (must be cleared in software)
; 0 = No TMR1 register capture occurred
;Compare mode:
; 1 = A TMR1 register compare match occurred (must be cleared in software)
; 0 = No TMR1 register compare match occurred
; PWM mode:
; Unused in this mode.
;Bit 1 TMR2IF: TMR2 to PR2 Match Interrupt Flag bit
; 1 = TMR2 to PR2 match occurred (must be cleared in software)
; 0 = No TMR2 to PR2 match occurred
;Bit 0 TMR1IF: TMR1 Overflow Interrupt Flag bit
; 1 = TMR1 register overflowed (must be cleared in software)
; 0 = TMR1 register did not overflow
MOVLW B'00000000' ;Bit 7 Unimplemented: Read as '0'
MOVWF PIR2 ;Bit 6 CMIF: Comparator Interrupt Flag bit
; 1 = The comparator input has changed (must be cleared in software)
; 0 = The comparator input has not changed
;Bit 5 Unimplemented: Read as '0'
;Bit 4 EEIF: EEPROM Write Operation Interrupt Flag bit
; 1 = The write operation completed (must be cleared in software)
; 0 = The write operation is not complete or has not been started
;Bit 3 BCLIF: Bus Collision Interrupt Flag bit
; 1 = A bus collision has occurred in the SSP when configured for I2C Master mode
; 0 = No bus collision has occurred
;Bit 2-1 Unimplemented: Read as '0'
;Bit 0 CCP2IF: CCP2 Interrupt Flag bit
; Capture mode:
; 1 = A TMR1 register capture occurred (must be cleared in software)
; 0 = No TMR1 register capture occurred
; Compare mode:
; 1 = A TMR1 register compare match occurred (must be cleared in software)
; 0 = No TMR1 register compare match occurred
; PWM mode:
; Unused.
MOVLW B'00110000' ;Bit 7-6 Unimplemented: Read as '0'
MOVWF T1CON ;Bit 5-4 T1CKPS1:T1CKPS0: Timer1 Input Clock Prescale Select bits
; 11 = 1:8 prescale value
; 10 = 1:4 prescale value
; 01 = 1:2 prescale value
; 00 = 1:1 prescale value
;Bit 3 T1OSCEN: Timer1 Oscillator Enable Control bit
; 1 = Oscillator is enabled
; 0 = Oscillator is shut-off (the oscillator inverter is turned off to eliminate power drain)
;Bit 2 T1SYNC: Timer1 External Clock Input Synchronization Control bit
; When TMR1CS = 1:
; 1 = Do not synchronize external clock input
; 0 = Synchronize external clock input
; When TMR1CS = 0:
; This bit is ignored. Timer1 uses the internal clock when TMR1CS = 0.
;Bit 1 TMR1CS: Timer1 Clock Source Select bit
; 1 = External clock from pin RC0/T1OSO/T1CKI (on the rising edge)
; 0 = Internal clock (FOSC/4)
;Bit 0 TMR1ON: Timer1 On bit
; 1 = Enables Timer1
; 0 = Stops Timer1
CLRF PORTA
CLRF PORTB
CLRF PORTC
CLRF PORTD
CLRF PORTE
CLRWDT
;.....................................................................................
INICIO ;Inicia a programação

LIGA_SAIDA1
call	Delay_500ms
DESLIGA_SAIDA1
LIGA_SAIDA2
call	Delay_500ms
DESLIGA_SAIDA2
LIGA_SAIDA3
call	Delay_500ms
DESLIGA_SAIDA3
LIGA_SAIDA4
call	Delay_500ms
DESLIGA_SAIDA4
LIGA_SAIDA5
call	Delay_500ms
DESLIGA_SAIDA5
LIGA_SAIDA6
call	Delay_500ms
DESLIGA_SAIDA6
LIGA_SAIDA7
call	Delay_500ms
DESLIGA_SAIDA7
LIGA_SAIDA8
call	Delay_500ms
DESLIGA_SAIDA8

goto	INICIO

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

end