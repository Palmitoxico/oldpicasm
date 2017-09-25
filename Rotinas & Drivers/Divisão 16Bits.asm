;Divisão de 16 bits:
cblock 0x20						;Definições de variáveis
Divisor_L
Divisor_H
Dividendo_L
Dividendo_H
Resultado_L
Resultado_H
Base_Index_L
Base_Index_H
Temp1
endc

DIVV16
	movf	Divisor_L,F
	btfss 	STATUS,Z
	goto	ZERO_TEST_SKIPPED
	movf	Divisor_H,F
	btfsc	STATUS,Z
return

ZERO_TEST_SKIPPED
	movlw   1
	movwf   Base_Index_L
	clrf    Base_Index_H
	clrf    Resultado_L
	clrf    Resultado_H

SHIFT_IT16
	btfsc   Divisor_H,7
	goto 	DIVU16LOOP
	bcf     STATUS,C
  	rlf     Base_Index_L,F
  	rlf     Base_Index_H,F
  	bcf     STATUS,C
  	rlf     Divisor_L,F
  	rlf     Divisor_H,F
  	goto    SHIFT_IT16

DIVU16LOOP
	call    SUB16
	btfsc   STATUS,C
	goto    COUNTX
	call    ADD16BIS
	goto    FINALX
COUNTX
	movf    Base_Index_L,W
	addwf   Resultado_L
	btfsc   STATUS,C
	incf    Resultado_H,F
	movf    Base_Index_H,W
	addwf   Resultado_H
FINALX
	bcf     STATUS,C
	rrf     Divisor_H,F
	rrf     Divisor_L,F
	bcf     STATUS,C
	rrf     Base_Index_H,F
	rrf     Base_Index_L,F
	btfss   STATUS,C
	goto    DIVU16LOOP
return

SUB16
	movf    Divisor_H,W
	movwf   Temp1
	movf    Divisor_L,W
	subwf   Dividendo_L
	btfss   STATUS,C
	incf    Temp1,F
	movf    Temp1,W
	subwf   Dividendo_H
return

ADD16BIS
	movf    Divisor_L,W
	addwf   Dividendo_L
	btfsc   STATUS,C
	incf    Dividendo_H,F
	movf    Divisor_H,W
	addwf   Dividendo_H
return
