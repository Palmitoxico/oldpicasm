

cblock 0x20

VAR	;Byte do número a ser convertido
DSP1	;Dígito unidade
DSP2	;Dígito dezena
DSP3	;Dígito centena

endc
	

Converter_Bin_Dec_8bit
	movwf	VAR
	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	movlw	.100
	subwf	VAR, 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP3 , 1
	goto	$-4
	movlw	.100
	addwf	VAR, 1
	movlw	.10
	subwf	VAR, 1
	btfss	STATUS , 0
	goto	$+3	
	incf	DSP2 , 1
	goto	$-4
	movlw	.10
	addwf	VAR, 0
	movwf	DSP1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	return