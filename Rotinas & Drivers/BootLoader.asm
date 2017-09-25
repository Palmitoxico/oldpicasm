 bcf		INTCON, GIE
BANK2
clrf	EEADRH
clrf	EEADR

BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	NumeroDeBytes
bcf		STATUS, C
rrf		NumeroDeBytes, 1

BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEADR


BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEADRH

GravarDataBytes:
BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEDATA

BANK0
btfss	PIR1 , RCIF
goto	$-1
movf	RCREG, W
BANK2
movwf	EEDATH

call	Gravar_Instrucao

incfsz	EEADR, F
goto	$+2
incf	EEADRH, F

decfsz	NumeroDeBytes, F
goto	GravarDataBytes


movlw	0x17
call	Enviar_byte_rs232_BootL
goto	Bootloader

sleep

Gravar_Instrucao:
	BANK3
	bsf		EECON1,EEPGD
	bsf		EECON1,WREN
	movlw   0x55
	movwf   EECON2
	movlw   0xAA
	movwf   EECON2	
	bsf     EECON1 , 1
	nop    
	nop   
	btfsc   EECON1 , 1
	goto    $-1
	bcf     EECON1 , 2
	BANK2
	return

Enviar_byte_rs232_BootL
	BANK1						; ALTERA P/ BANCO 1 DA RAM
	btfss	TXSTA,TRMT			; O BUFFER DE TX ESTÁ VAZIO ?
	goto	$-1					; NÃO - AGUARDA ESVAZIAR
	BANK0						; SIM - VOLTA P/ BANCO 0 DA RAM
	movwf	TXREG				; SALVA WORK EM TXREG (INICIA TX)
	return