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
	pop	es

	call	video_mode, 13h
	call	load_palette
	call	background, 00h
	call	draw_board
	call 	highlight_square, [BEGIN_X], [BEGIN_Y]

@@read_key:
	; check keystroke
	mov 	ah,01h
	int 	16h
	jz	@@end_pressed_key

	; get contents of key
	mov 	ah, 0h
	int	16h

	mov 	edx, 10h

	cmp 	ah, 01Eh ; A
	jz	@@left_key_pressed
	cmp	ah, 020h ; D
	jz	@@right_key_pressed
	cmp 	ah, 011h ; W
	jz	@@up_key_pressed
	cmp 	ah, 01Fh ; S
	jz 	@@down_key_pressed
	cmp 	ah, 023h ; H
	jz	@@left_key_pressed
	cmp	ah, 026h ; L
	jz	@@right_key_pressed
	cmp 	ah, 025h ; W
	jz	@@up_key_pressed
	cmp 	ah, 024h ; J
	jz 	@@down_key_pressed
	cmp	ah, 081h ; ESC
	jz	@@quit
	jmp	@@quit
	jmp	@@read_key

@@left_key_pressed:
	sub 	[BEGIN_X], edx
	jmp	@@end_pressed_key
@@right_key_pressed:
	add 	[BEGIN_X], edx
	jmp	@@end_pressed_key
@@up_key_pressed:
	sub	[BEGIN_Y], edx
	jmp	@@end_pressed_key
@@down_key_pressed:
	add 	[BEGIN_Y], edx
	jmp	@@end_pressed_key

@@end_pressed_key:
	call 	highlight_square, [BEGIN_X], [BEGIN_Y]
	jmp	@@read_key

@@quit:
	; Reset video mode for the terminal.
	call	video_mode, 03h

	; Terminate process with return code in response to a keystroke.
	mov		ax,4C00h
	int 	21h

; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG
BEGIN_X DD 0h
BEGIN_Y DD 0h
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END start
; vim:set noet filetype=tasm:
