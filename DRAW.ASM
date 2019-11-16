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

	ARG	@@color:byte, @@x:byte, @@y:byte
	USES	eax, ecx, edx

	MOV 	cx, [@@x]
	MOV 	dx, [@@y]

DRAW_SQUARE_HORIZONTAL:
	MOV 	ah,0Ch     	 ; set the config to writing a pixel
	MOV 	al,[@@color]   	 ; set color to white
	MOV 	bh,00h    	 ; set the page number
	INT 	10h       	 ; execute the config

	INC 	cx        	 ; CX is counter and you higher item
	MOV 	ax, cx    	 ; move column into AX registers
	SUB 	ax,[@@x]
	CMP 	ax,[SQUARE_SIZE]
	JNG 	DRAW_SQUARE_HORIZONTAL

	MOV 	cx, [@@x]	 ; CX register goed back to initial column
	INC 	dx        	 ; we advance one line

	MOV 	ax,dx
	SUB 	ax,[@@y]
	CMP 	ax, [SQUARE_SIZE]
	JNG 	DRAW_SQUARE_HORIZONTAL

	ret
ENDP draw_square

PROC draw_board:

	ARG
	USES 	eax, ecx, edx

	xor 	cx,cx

loop1:
	xor 	dx,dx

loop2:
	test 	dx, 01h
	JZ 	draw_white
	CALL 	draw_square,08h,[SQUARE_X],[SQUARE_Y]
	MOV 	ax, 0Fh
	ADD 	[SQUARE_X], ax

	inc 	dx
	cmp 	dx, 08h
	jle 	loop2

draw_white:
	CALL 	draw_square,0Fh,[SQUARE_X],[SQUARE_Y]
	MOV 	ax, 0Fh
	ADD 	[SQUARE_X], ax

	inc 	cx
	MOV 	ax, 0Fh
	ADD 	[SQUARE_Y], ax
	cmp 	cx, 08h
	jle 	loop1

	ret
ENDP draw_board


DATASEG
SQUARE_X DB 00h ; x coordinate SQUARE
SQUARE_Y DB 00h ; y coordinate SQUARE
SQUARE_SIZE DB 0Fh ;square must be 16px
COLOR DW

STACK 100 H

END main
