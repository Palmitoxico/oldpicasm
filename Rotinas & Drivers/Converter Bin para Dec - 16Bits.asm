
cblock 0x20

VAR_L	;Byte menos significativo do número a ser convertido
VAR_H	;Byte mais significativo do número a ser convertido
DSP1	;Dígito unidade
DSP2	;Dígito dezena
DSP3	;Dígito centena
DSP4	;Dígito unidade de milhar
DSP5	;Dígito dezena de milhar

endc


Converter_Bin_Dec_16bit

	clrf	DSP1
	clrf	DSP2
	clrf	DSP3
	clrf	DSP4
	clrf	DSP5


	Ajuste_DSP5

	movlw	0x10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0x10
	addwf	VAR_L, F
	goto	FIM_DSP5


	movlw	0x27
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP5
	goto	Ajuste_DSP5

	movlw	0x10
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x27
	addwf	VAR_H, F


	FIM_DSP5




	Ajuste_DSP4

	movlw	0xE8
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	0xE8
	addwf	VAR_L, F
	goto	FIM_DSP4


	movlw	0x03
	subwf	VAR_H, F
	btfss	STATUS, C
	goto	$+3
	incf	DSP4
	goto	Ajuste_DSP4

	movlw	0xE8
	addwf	VAR_L, F
	btfsc	STATUS, C
	incf	VAR_H, F

	movlw	0x03
	addwf	VAR_H, F


	FIM_DSP4


	Ajuste_DSP3

	movlw	.100
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.100
	addwf	VAR_L, F
	goto	FIM_DSP3

	incf	DSP3, F
	goto	Ajuste_DSP3

	FIM_DSP3


	Ajuste_DSP2

	movlw	.10
	subwf	VAR_L, F
	btfsc	STATUS, C
	goto	$+9
	movlw	.1
	subwf	VAR_H, F
	btfsc	STATUS, C
	goto	$+5
	incf	VAR_H, F
	movlw	.10
	addwf	VAR_L, F
	goto	FIM_DSP2

	incf	DSP2, F
	goto	Ajuste_DSP2

	FIM_DSP2


	Ajuste_DSP1

	movf	VAR_L, W
	movwf	DSP1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Parte opcional do programa para a conversão de BCD para ASCII
	movlw	0x30
	addwf	DSP1, F
	addwf	DSP2, F
	addwf	DSP3, F
	addwf	DSP4, F
	addwf	DSP5, F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	return