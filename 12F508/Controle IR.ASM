;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC12F508. This file contains the basic code               *
;   building blocks to build upon.                                    *
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P12F508.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************

	list      p=12F508            ; list directive to define processor
	#include <p12F508.inc>        ; processor specific variable definitions

	__CONFIG   _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC

; '__CONFIG' directive is used to embed configuration word within .asm file.
; The lables following the directive are located in the respective .inc file. 
; See respective data sheet for additional information on configuration word.




;***** VARIABLE DEFINITIONS
temp	EQU     0x07        ;example variable definition



;**********************************************************************
	ORG     0x1FF             ; processor reset vector

; Internal RC calibration value is placed at location 0x1FF by Microchip
; as a movlw k, where the k is a literal value.

	ORG     0x000             ; coding begins here
	movwf   OSCCAL            ; update register with factory cal value 




start	
	nop                       ; example code
	movlw   0xFF              ; example code
	movwf   temp              ; example code

; remaining code goes here






	END                       ; directive 'end of program'

