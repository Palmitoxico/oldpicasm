	#INCLUDE <p16f873.inc>      
 __CONFIG _BODEN_OFF & _CP_OFF & _WDT_OFF & _HS_OSC
	


#define BANK0 BCF STATUS,RP0
#define BANK1 BSF STATUS,RP0

;Definindo Entradas 

#define BTN1 PORTA,0   ; Definindo Botao 1 no pino 0 da porta A
#define BTN2 PORTA,1   ; Definindo Botao 2 no pino 1 da porta A
#define BTN3 PORTA,2   ; Definindo Botao 3 no pino 2 da porta A
#define BTN4 PORTA,3   ; Definindo Botao 4 no pino 3 da porta A
#define CIMA PORTA,4   ; Definindo Botao cima no pino 4 da porta A
#define BAIXO PORTA,5  ; Definindo Botao baixo no pino 5 da porta A

#define LIGA PORTB,0      ; Definindo Botao Liga no pino 0 da porta B
#define DESLIGA PORTB,1   ; Definindo Botao Desliga no pino 1 da porta B


Cont1	EQU	0x30
Cont2	EQU	0x31

 
ANGULO set 0  ; Definindo variavel angulo
SENTIDO set 0 ; Definindo variavel sentido


	ORG 0x00; Vetor Reset
	GOTO INICIO ; Vai para programa principal

	ORG 0x04; Vetor de Interrupçoes
	GOTO INICIO

INICIO ; INICIO DO PROGRAMA

	BANK1
	MOVLW B'00111111'   
	MOVWF TRISA   ; Definindo pinos de 0 a 5 da porta A como entradas

	MOVLW B'00000011'   
	MOVWF TRISB   ; Definindo pinos de 0 a 5 da porta A como entradas
	
	MOVLW B'00000000'
	MOVWF TRISC   ; Definindo pinos 0 e 7 da porta C como saídas
	BANK0

TESTELIG

	BTFSS LIGA        ; Testa se o botao liga foi acionado 
	
	GOTO TESTELIG
	
;--------------------------------------------------------       DESLOCANDO MOTOR DA HORIZONTAL PARA O CENTRO   -----------------------------------------------------------------------------------------------------
	

; se foi acionado motor da horizontal vai para a posição 90 graus (12 passos)


	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	
      	
;-----------------------------------------------------------     DESLOCANDO MOTOR DA VERTICAL PARA O CENTRO      ---------------------------------------------------------------------------

; se foi acionado o botao liga o motor da vertical também vai para a posição 90 graus (12 passos)

   call MOTOR_ANTI_2
   call MOTOR_ANTI_2
   call MOTOR_ANTI_2
   call MOTOR_ANTI_2
   call MOTOR_ANTI_2
   call MOTOR_ANTI_2
      


;-------------------------------------------------  VERIFICANDO SE BOTOES DE DESOLOCAMENTO HORIZONTAL FORAM ACIONADOS  ----------------------------------------------

VERIFICA_BTN


	BTFSS BTN1          ; Testa se botao 1 ( posiçao 45 graus ) foi acionado
	goto  VERIFICA_BTN2   ; Se o botao 1 nao foi acionado, Verifica o botao 2 

	
	call MOTOR_ANTI_1   ; Chama sub rotina para o motor da horizontal ir para a posiçao 45 graus
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1

	VARIABLE ANGULO=0          ; reset na variavel angulo, para saber que o motor movimentou 45 graus
	VARIABLE SENTIDO=1         ; set na variavel sentido, para saber que o motor movimentou no sentido anti horario
 	
	GOTO VERIFICA_CB



VERIFICA_BTN2


	BTFSS BTN2	      ; Testa se botao 2 foi acionado
	goto  VERIFICA_BTN3    ; Se o botao 2 nao foi acionado, chama sub rotina para verificar o botao 3

	call MOTOR_HORARIO_1  ; Chama sub rotina para o motor da horizontal ir para a posiçao 135
	call MOTOR_HORARIO_1  
	call MOTOR_HORARIO_1  
	call MOTOR_HORARIO_1  

	VARIABLE ANGULO=0         ; reset na variavel angulo, para saber que o motor movimentou 45 graus
	VARIABLE SENTIDO=0        ; reset na variavel sentido, para saber que o motor movimentou no sentido horario

	GOTO VERIFICA_CB

;	RETURN	;Retorna para o call VERIFICA_BTN2

VERIFICA_BTN3


	BTFSS BTN3	     ; Testa se o botao 3 foi acionado
	goto  VERIFICA_BTN4   ; Se o o botao 3 nao foi acionado, verifica o botao 4

	call MOTOR_ANTI_1    ; chama sub rotina para o o motor da horizontal ir para a posiçao 0 graus
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1

	VARIABLE ANGULO=1          ; set na variavel angulo, para saber que o motor movimentou 90 graus
	VARIABLE SENTIDO=1         ; set na variavel sentido, para saber que o motor movimentou no sentido anti horario

	GOTO VERIFICA_CB
	

;	return	;Retorna para o call VERIFICA_BTN3


VERIFICA_BTN4

	
	BTFSS BTN4	      ; Verifica se o botao 4 foi acionado
	GOTO VERIFICA_BTN     ; Se o botao 4 nao foi acionado, vai para VERIFICA_BTN
	
	call MOTOR_HORARIO_1  ; chama sub rotina para o motor da horizontal ir para a posiçao 180 graus
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1


	VARIABLE ANGULO=1        ; set na variavel angulo, para saber que o motor movimentou 90 graus
	VARIABLE SENTIDO=0         ; reset na variavel sentido, para saber que o motor movimentou no sentido  horario

	GOTO VERIFICA_CB

;	RETURN ; Retorna para o call VERIFICA_BTN4	


; --------------------------------------------------  VERIFICANDO SE BOTOES DE DESOLOCAMENTO VERTICAL FORAM ACIONADOS  ------------------------------------------------------------------------------------------------------------------------------------
	
VERIFICA_CB

	BTFSS CIMA		 ; Verifica se o botao CIMA foi acionado
	call VERIFICA_BAIXO      ; Se o botao CIMA nao foi acionado, vai para VERIFICA_BAIXO

	call MOTOR_ANTI_2	 ;chama sub rotina para o motor da vertical ir para a posiçao 180 graus 
 	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2

	call MOTOR_HORARIO_2    ; chama sub rotina para o motor da vertical voltar para a posiçao inicial (90 graus)
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2

	CALL VERIFICA_ANG
	
	GOTO TEST_DESL


VERIFICA_BAIXO

	BTFSS BAIXO	    	; Verifica se o botao BAIXO foi acionado
	call VERIFICA_CB	; Se nao foi vai para VERIFICA_CB

	call MOTOR_HORARIO_2    ; chama sub_rotina para o motor da vertical ir para a posiçao 0 graus
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	
	call MOTOR_ANTI_2       ; chama sub_rotina para o motor da vertical voltar para a posiçao 90 graus
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2
	call MOTOR_ANTI_2

	CALL VERIFICA_ANG
	
	GOTO TEST_DESL



;-----------------------------------------------------------------------   ACIONAMENTO MOTOR HORIZONTAL  --------------------------------------------------------------

MOTOR_HORARIO_1
	
	MOVLW .8
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .4
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .2
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .1
	MOVWF PORTC
	call  DELAY_5_MS
	RETURN


MOTOR_ANTI_1

	MOVLW .1
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .2
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .4
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .8
	MOVWF PORTC
	call  DELAY_5_MS

	RETURN

	


;-------------------------------------------------------------------------    ACIONAMENTO MOTOR VERTICAL  --------------------------------------------------------------

	
MOTOR_HORARIO_2
	
	MOVLW .128
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .64
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .32
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .16
	MOVWF PORTC
	call  DELAY_5_MS
	RETURN


MOTOR_ANTI_2

	MOVLW .16
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .32
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .64
	MOVWF PORTC
	call  DELAY_5_MS
	MOVLW .128
	MOVWF PORTC
	call  DELAY_5_MS

	RETURN


;-----------------------------------------------------------------------   ROTINA PARA DELAY DE 5 MS ---------------------------------------------------


DELAY_5_MS
	movlw	0x61
	movwf	Cont2
	movlw	0xA8
	movwf	Cont1

	decfsz	Cont1,1
	goto	$-1
	decfsz	Cont2,1
	goto	$-3


	return



;-----------------------------------------------------------------------   VOLTANDO MOTOR HORIZONTAL ---------------------------------------------------


VERIFICA_ANG

	If ANGULO      ; verifica se o angulo de deslocamento na horizotal é 90 graus ( se angulo=1 )
    call VOLTAR_90_A    ; se o angulo for de 90 graus, chama sub rotina VOLTAR_90_A	
	else
    goto VOLTAR_45_A      ; se o angulo for de 45 graus, vai para VOLTAR_45_A
	endif

	RETURN


VOLTAR_45_A
	If SENTIDO            ; Verifica se o sentido é anti-horario ( se sentido=1 )
	call VOLTAR_45_H        ; Se a o sentido for anti-horario, chama sub rotina VOLTAR_90_H
	else
	call MOTOR_HORARIO_1    ; chama sub rotina para voltar o motor da horizontal para a posiçao inicial ( 90 graus )
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	endif
	GOTO TEST_DESL		; Vai para o teste da chave desliga
	


VOLTAR_45_H
	if SENTIDO	    	; Verifica se o sentido é horario ( se sentido=0)
	call VOLTAR_45_A    ; se o sentidoo nao for horario ( = 0 ) chama sub rotina voltar_45_A
	else
	call MOTOR_ANTI_1	; se o sentido for horario ( =0) chama sub rotina MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	endif
	GOTO TEST_DESL		; Vai para o teste da chave desliga
	

	RETURN

VOLTAR_90_A
	if SENTIDO		; Verifica se o sentido é anti horario (sentido=1)
	call MOTOR_HORARIO_1    ; chama sub rotina para voltar o motor da horizontal para a posiçao inicial ( 90 graus )
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	call MOTOR_HORARIO_1
	else	
    call VOLTAR_90_H	; se o sentido nao for horario, chama sub rotina VOLTAR_90_H



	GOTO TEST_DESL		; Vai para o teste da chave desliga


VOLTAR_90_H
	if SENTIDO   ;=0		; verifica se o sentido é horario ( sentido=o)
	GOTO TEST_DESL		; Vai para o teste da chave desliga
	else
	call MOTOR_ANTI_1	;
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	endif
	GOTO TEST_DESL		; Vai para o teste da chave desliga


;----------------------------------------------------------------------  VERIFICANDO O BOTAO DESLIGA ------------------------------------------------------------------

	
TEST_DESL

	BTFSS DESLIGA		; verifica se o botao desliga foi acionado
	GOTO VERIFICA_BTN	; se o botao desliga nao foi acionado volta para VERIFICARBTN


	 
	call MOTOR_ANTI_1	; Volta com o motor da horizontal para 0 graus
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1
	call MOTOR_ANTI_1

	call MOTOR_HORARIO_2	; Volta com o motor da vertical para 0 graus
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2
	call MOTOR_HORARIO_2	

	GOTO INICIO

	END
