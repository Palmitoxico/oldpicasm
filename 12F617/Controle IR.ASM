;******************************************************************************
;   This file is a basic relocatable code template for code generation        *
;   on the  PIC12F617. This file contains the basic code                      *
;   building blocks to build upon.                                            *
;                                                                             *
;   Refer to the MPASM User's Guide for additional information on             *
;   features of the assembler.                                                *
;                                                                             *
;   Refer to the respective data sheet for additional                         *
;   information on the instruction set.                                       *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:         xxx.asm                                                *
;    Date:                                                                    *
;    File Version:                                                            *
;                                                                             *
;    Author:                                                                  *
;    Company:                                                                 *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Files Required: P12F617.INC                                              *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Notes:                                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Revision History:                                                        *
;                                                                             *
;******************************************************************************

     list      p=12F617            ; list directive to define processor
     #include <p12F617.inc>        ; processor specific variable definitions

; '__CONFIG' directive is used to embed configuration word within .asm file.
; The lables following the directive are located in the respective .inc file.
; See data sheet for additional information on configuration word settings.

     __CONFIG   _CP_OFF & _BOR_OFF & _MCLRE_ON & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _IOSCFS_8MHZ & _WRT_OFF

;***** VARIABLE DEFINITIONS
w_temp        EQU     0x7e        ; variable used for context saving 
status_temp   EQU     0x7f        ; variable used for context saving

;**********************************************************************
START     ORG     0x0000            ; processor reset vector
          goto    MAIN              ; go to beginning of program

ISR       ORG     0x0004            ; interrupt vector location
     
;         Context saving for ISR
          MOVWF   w_temp            ; save off current W register contents
          SWAPF   STATUS, w         ; Swap status to be saved into W
                                    ; Swaps are used because they do not 
                                    ; affect the status bits
          MOVWF   status_temp       ; save off contents of STATUS register

;         INSERT INTERRUPT CODE HERE

;         Restore context before returning from interrupt
          SWAPF   status_temp,w   ; swap status_temp register into W
          MOVWF   STATUS          ; restore pre-isr STATUS register contents
          SWAPF   w_temp,f
          SWAPF   w_temp,w        ; restore pre-isr W register contents
          RETFIE                  ; return from interrupt
          
;**********************************************************************
MAIN

; SET OSCILLATOR TO FACTORY FREQUENCY AND CLEAR GPR's 

          errorlevel -302     ; disable warning accessing register not in bank 0
          banksel OSCTUNE     ; select bank 1 using mpasm macro 
          movlw   0x00        ; set oscillator to factory calibrated frequency 
          movwf   OSCTUNE
          banksel GPIO        ; select bank 0 using mpasm macro 
          errorlevel +302     ; re-enable warning accessing register not in bank 0

          goto $

          END
