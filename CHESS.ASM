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

INCLUDE "ENGINE.INC"
INCLUDE "DRAW.INC"

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

start:
	sti            ; set The Interrupt Flag => enable interrupts
	cld            ; clear The Direction Flag

	; Setup for string functions
	push	ds
	pop		es

	call	video_mode, 13h
	call	background, 0bh
	call	draw_board
	call 	highlight_square(BEGIN_X, BEGIN_Y)
	; check keystroke
	mov 	ah,01h
	int 	16h
	jz	@@not_pressed_key

@@pressed_key:
	mov 	ah, 0h
	cmp 	cx, 2190
	jz	@@left_key_pressed
	cmp 	cx, 2191
	jz 	@@up_key_pressed
	cmp 	cx, 2192
	jnz 	@@down_key_pressed
	mov 	dx, 10h

@@right_key_pressed:

	sub 	[BEGIN_X], dx
	call 	highlight_square(BEGIN_X, BEGIN_Y)
	ret

@@left_key_pressed:

	add 	[BEGIN_X], dx
	call 	highlight_square(BEGIN_X, BEGIN_Y)
	ret

@@up_key_pressed:

	add	[BEGIN_Y], dx
	call 	highlight_square(BEGIN_X, BEGIN_Y)
	ret

@@down_key_pressed:
	sub 	[BEGIN_Y], dx
	call 	highlight_square(BEGIN_X, BEGIN_Y)
	ret

	int 	16h

@@no_pressed_key:

	; Reset video mode for the terminal.
	call	video_mode, 03h

	; Terminate process with return code in response to a keystroke.
    	mov	ax,4C00h
	int 	21h

; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG
BEGIN_X 0h
BEGIN_Y 0h
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END start
; vim:set noet sts=4 sw=4 ts=4 filetype=tasm:
