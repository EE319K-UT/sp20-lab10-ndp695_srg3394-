; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 
Y EQU 0
X EQU 4
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH {LR, R0}
	SUB SP, #8
	CMP R0, #10
	BLO skip
	MOV R3, #0xa
	UDIV R2, R0, R3
	MLS R1, R2, R3, R0
	MOV R0, R2
	STR R1, [SP, #X]
	BL LCD_OutDec
	LDR R0, [SP, #X]
	ADD R0, #0x30
	BL ST7735_OutChar
	B done
skip
	ADD R0, #0x30
	BL ST7735_OutChar
done
	ADD SP, #8
	

	POP {LR, R0}


      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
		MOV R1, #0
LCD_OutFixLoop
	PUSH {LR, R4, R1, R0}

	SUB SP, #8 


	MOV R4, #1000
	CMP R0, R4
	BHS asterix
	CMP R1, #3
	BEQ complete
	MOV R3, #0xa
	UDIV R2, R0, R3
	MLS R4, R2, R3, R0 
	MOV R0, R2
	STR R4, [SP, #X]
	STR R1, [SP, #Y]
	ADD R1, #1
	BL LCD_OutFixLoop
	LDR R0, [SP, #X]
	ADD R0, #0x30
	BL ST7735_OutChar
	LDR R1, [SP, #Y]
	CMP R1, #2
	BNE complete
	MOV R0, #0x2E
	BL ST7735_OutChar
	B complete
asterix
	MOV R0, #0x2A		;*
	BL ST7735_OutChar	
	MOV R0, #0x2E		;dot
	BL ST7735_OutChar	
	MOV R0, #0x2A		;*
	BL ST7735_OutChar
	MOV R0, #0x2A		;*
	BL ST7735_OutChar
complete

	

	ADD SP, #8
	
	
	POP {LR, R4, R1, R0}
     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
