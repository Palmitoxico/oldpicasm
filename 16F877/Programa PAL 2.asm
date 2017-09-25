processor 16F877
include <p16f877.inc>
__config _WDT_OFF & _PWRTE_ON


cont1 EQU 0x20
cont2 EQU 0x21


;#define	VIDEO_PORT  PORTE
;#define	COLOR_BLACK 0x00
;#define	COLOR_SYNC  0x00
;#define	COLOR_GRAY  0x00
;#define	COLOR_WHITE 0x01

org 0x0000

BANK1 macro
bsf    STATUS,RP0 			   ;Muda para o banco 1
Endm

BANK0 macro
bcf   STATUS,RP0  			   ;Volta ao banco 0
Endm

main:  
	clrf  PORTE
	BANK1
	clrf  TRISE
	clrf  TRISD
	BANK0
	movlw 0x0F
	movwf PORTD
	inicio

	movlw 0x00		 	;get sync level (1) 
						;**** 4us sync ****  
	movwf PORTE		 	;set port value(1) 
	movlw 3 			;setup delaytime 
	call	DELAY		;delay for 3us (9) 
	movlw 0x00		 	;get black level (1) 
						; **** 8 us delay ****  
	movwf PORTE		 	;set port value (1) 
	movlw 7 			;setup delaytime (1) 
	call	DELAY		;delay for 7us (21) 
	movlw 0x10		 	;get gray color (1) 
						; **** 52 image data ****  
	movwf PORTE		 	;set port value (1) 
	movlw 3 			;setup delaytime (1) 
	call	DELAY		;delay for 3us (9) 
	movlw 0x00		 	;get black level (1) 
	movwf PORTE		 	;set port value (1) 
	movlw 19 			;setup delaytime (1) 
	call	DELAY		;delay for 19us (57) 
	movlw 0x11		 	;get white level (1) 
	movwf PORTE		 	;set port value (1) 	
	movlw 3 			;setup delaytime (1) 
	call	DELAY		;delay for 3us (9) 
	movlw 0x00		 	;get black level (1) 
	movwf PORTE		 	;set port value (1) 
	movlw 19 			;setup delaytime (1) 
	call	DELAY		;delay for 19us (57) 
	movlw 0x10		 	;get gray level (1) 
	movwf PORTE		 	;set port value (1) 
	movlw 2 			;setup delaytime (1) 
	call	DELAY 		;delay for 2us (6) 
	NOP 				;delay for 2 clocks (2) 
	NOP
	goto inicio			;loop forever jump (3) 
	
	DELAY
	movwf cont2
	movlw 4
	movwf cont1
	Delay_1
	decfsz cont1 , 1
	goto   Delay_1	
	decfsz cont2 , 1
	goto   Delay_1
	return
	
	
END