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

; compile-time constants (with macros)
VIDMEM EQU 0A0000h	; video memory address
WIDTH EQU 320		; screen witdth
HEIGHT EQU 200		; screen height
; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG


PROC VideoMode
	ARG	@@VM:byte
	USES	eax

	movzx 	ax, [@@VM]
	int 	10h

	ret
ENDP VideoMode

PROC Background
	ARG	@@color:byte
	USES	eax, ecx, edi

	MOV 	edi, VIDMEM

	MOV 	ecx, WIDTH*HEIGHT
	MOV	al, [@@color]
	rep 	stosb

	ret
ENDP Background

PROC draw_square:

	MOV 	cx, SQUARE_X
	MOV 	dx, SQUARE_Y

DRAW_SQUARE_HORIZONTAL:
	MOV 	ah,0Ch     	 ; set the config to writing a pixel
	MOV 	al,0Fh    	 ; set color to white
	MOV 	bh,00h    	 ; set the page number
	INT 	10h       	 ; execute the config

	INC 	cx        	 ; CX is counter and you higher item
	MOV 	ax, cx    	 ; move column into AX registers
	SUB 	ax,SQUARE_X
	CMP 	ax,SQUARE_SIZE
	JNG 	DRAW_SQUARE_HORIZONTAL

	MOV 	cx, SQUARE_X 	 ; CX register goed back to initial column
	INC 	dx        	 ; we advance one line

	MOV 	ax,dx
	SUB 	ax,SQUARE_Y
	CMP 	ax, SQUARE_SIZE
	JNG 	DRAW_SQUARE_HORIZONTAL

	ret
ENDP draw_square





DATASEG
SQUARE_X DW 00h ; x coordinate SQUARE
SQUARE_Y DW 00h ; y coordinate SQUARE
SQUARE_SIZE DW 0Fh ;square must be 16px

STACK 100 H

END main
