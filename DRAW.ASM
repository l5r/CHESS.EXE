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
WIDTH EQU 256		; screen witdth
HEIGHT EQU 256		; screen height
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

	mov 	edi, VIDMEM

	mov 	ecx, WIDTH*HEIGHT
	mov	al, [@@color]
	rep 	stosb

	ret
ENDP Background

PROC draw_square:

	ARG	@@color:byte, @@x:byte, @@y:byte
	USES	eax, ecx, edx

	mov 	cx, [@@x]
	mov 	dx, [@@y]

DRAW_SQUARE_HORIZONTAL:
	mov 	ah,0Ch     	 ; set the config to writing a pixel
	mov 	al,[@@color]   	 ; set color to white
	mov 	bh,00h    	 ; set the page number
	int 	10h       	 ; execute the config

	inc 	cx        	 ; CX is counter and you higher item
	mov 	ax, cx    	 ; move column into AX registers
	sub 	ax,[@@x]
	cmp 	ax,[SQUARE_SIZE]
	jng 	DRAW_SQUARE_HORIZONTAL

	mov 	cx, [@@x]	 ; CX register goed back to initial column
	inc 	dx        	 ; we advance one line

	mov 	ax,dx
	sub 	ax,[@@y]
	cmp 	ax, [SQUARE_SIZE]
	jng 	DRAW_SQUARE_HORIZONTAL

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
		jz 	draw_white
		call 	draw_square,08h,[SQUARE_X],[SQUARE_Y]
		mov 	ax, 0Fh
		add 	[SQUARE_X], ax

	inc 	dx
	cmp 	dx, 08h
	jle 	loop2

draw_white:
	call 	draw_square,0Fh,[SQUARE_X],[SQUARE_Y]
	mov 	ax, 0Fh
	add 	[SQUARE_X], ax

	inc 	cx
	mov 	ax, 0Fh
	add 	[SQUARE_Y], ax
	cmp 	cx, 08h
	jle 	loop1

	ret
ENDP draw_board

PROC clean_screen

	ARG
	USES

	mov	ah,0Ch
	mov	cx,100h

loop1:
	mov 	dx,100h

	loop2:
		int 	10h
		cmp	dx,0h
		dec	dx
		jne	loop2

	loop	loop1

	ret
ENDP clean_screen

DATASEG
SQUARE_X DB 00h ; x coordinate SQUARE
SQUARE_Y DB 00h ; y coordinate SQUARE
SQUARE_SIZE DB 0Fh ;square must be 16px

STACK 100 H

END main
