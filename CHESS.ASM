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
	call 	highlight_all

@@read_key:
	; check keystroke
	mov 	ah,01h
	int 	16h
	jz	@@end_pressed_key

	; get contents of key
	mov 	ah, 0h
	int	16h

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
	cmp	ah, 01Ch ; Enter
	jz	@@select_key_pressed
	cmp	ah, 039h ; Space
	jz	@@select_key_pressed
	cmp	ah, 001h ; ESC
	jz	@@quit
	jmp	@@read_key

@@left_key_pressed:
	call	move_selection, -01h, 0h
	jmp	@@end_pressed_key
@@right_key_pressed:
	call	move_selection, 01h, 0h
	jmp	@@end_pressed_key
@@up_key_pressed:
	call	move_selection, 0h, -01h
	jmp	@@end_pressed_key
@@down_key_pressed:
	call	move_selection, 0h, 01h
	jmp	@@end_pressed_key

@@select_key_pressed:

	call	set_selection
	cmp	ecx, 0h
	jz	@@end_pressed_key
	call	do_move, eax, ebx
	mov	bh, al
	and	bh, 07Fh ;KIND_MASK
	cmp	bh, 1
	jz	@@win
	call	draw_board
	call	reset_highlight


@@end_pressed_key:
	call 	highlight_all
	jmp	@@read_key

@@win:
	and	al, COLOR_MASK
	shr	al, 7
	mov	ecx, [WIN_MESSAGE_TABLE + eax*4]

	; Write message
	mov	ah, 02h
	mov	dx, 0A0Ah
	mov	bh, 0
	int	10h
	mov	ah, 09h
	mov	edx, ecx
	int	21h

@@await_key:
	; check keystroke
	mov 	ah,01h
	int 	16h
	jz	@@await_key
	
@@quit:
	; Reset video mode for the terminal.
	call	video_mode, 03h

	; Terminate process with return code in response to a keystroke.
	mov	ax,4C00h
	int 	21h

; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG

WIN_MESSAGE_TABLE DD WIN_WHITE, WIN_BLACK

WIN_BLACK DB 'Black wins!$'
WIN_WHITE DB 'White wins!$'

; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END start
; vim:set noet filetype=tasm:
