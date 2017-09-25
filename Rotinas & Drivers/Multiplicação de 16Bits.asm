;Multiplicação de 16 bits:
cblock 0x20						;Definições de variáveis
Multiplicador_L
Multiplicador_H
Multiplicando_L
Multiplicando_H
Resultado_L
Resultado_H
endc

MULV16 
	clrf    Resultado_L
	clrf    Resultado_H
MULU16LOOP
	btfsc	Multiplicando_L,0
	call	ADD16
	bcf		STATUS,C
	rrf 	Multiplicando_H,F
	rrf 	Multiplicando_L,F
	bcf 	STATUS,C
	rlf 	Multiplicador_L,F
	rlf 	Multiplicador_H,F
	movf	Multiplicando_L,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	movf	Multiplicando_H,F
	btfss	STATUS,Z
	goto	MULU16LOOP
	return

ADD16
	movf	Multiplicador_L,W
	addwf	Resultado_L
	btfsc	STATUS,C
	incf	Resultado_H
	movf	Multiplicador_H,W
	addwf	Resultado_H
	return
