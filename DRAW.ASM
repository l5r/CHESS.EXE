; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	Leander Lismond, Vincent Mostert
; date:		2019-11-13
; program:	CHESS.EXE
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

	PROC main:
	PUSH ds      	; push ds segments to the STACK
	SUB AX, AX   	; clean AX
	PUSH AX	    	; push AX to stack
	MOV AX, ds  	; save on AX content of ds
	MOV ds, AX	; save on ds content of AX
	POP AX		; release top item from stack
	POP AX		; same

		MOV AH, 10h	;set config to video mode
		MOV AL, 13h	;choose video mode
		INT 10h		;execute

		MOV AH, 0Bh	;set config to background color
		MOV BH, 00h	;
		MOV BL, 00h	;set bg as black
		INT 10h		;execute

		CALL draw_square

		RET

	ENDP main

	PROC draw_square:

		MOV CX, SQUARE_X
		MOV DX, SQUARE_Y

		DRAW_SQUARE_HORIZONTAL:
			MOV AH,0Ch     ; set the config to writing a pixel
			MOV AL,0Fh     ; set color to white
			MOV BH,00h     ; set the page number
			INT 10h        ; execute the config

			INC CX         ; CX is counter and you higher item
			MOV AX, CX     ; move column into AX registers
			SUB AX,SQUARE_X
			CMP AX,SQUARE_SIZE
			JNG DRAW_SQUARE_HORIZONTAL

			MOV CX, SQUARE_X ; CX register goed back to initial column
			INC DX         ; we advance one line

			MOV AX,DX
			SUB AX,SQUARE_Y
			CMP AX, SQUARE_SIZE
			JNG DRAW_SQUARE_HORIZONTAL

			RET
		DRAW_SQUARE ENDP

DATASEG
SQUARE_X DW 00h ; x coordinate SQUARE
SQUARE_Y DW 00h ; y coordinate SQUARE
SQUARE_SIZE DW 0Fh ;square must be 16px

STACK 100 H

END main
