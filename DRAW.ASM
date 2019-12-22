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

INCLUDE "DRAW.INC"
INCLUDE "ENGINE.INC"
INCLUDE "ASSETS.INC"

; compile-time constants (with macros)
VMEMADDR EQU 0A0000h		; video memory address
SCR_WIDTH EQU 320		; screen width
SCR_HEIGHT EQU 200		; screen height
SQUARE_SIZE EQU 16
PX_UNSET EQU 0DEADBEEFh

ENUM selection_mode mode_from, mode_to

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG


PROC video_mode
	ARG	@@VM:dword
	USES	eax

	mov 	ax, [WORD PTR @@VM]
	int 	10h

	ret
ENDP video_mode

PROC load_palette
	USES	eax, edx

	cld

	mov	dx, 03C8h
	mov	al, 0h
	out	dx, al

	mov	dx, 03C9h
	mov	esi, offset PALLETTE
	mov	ecx, PALLETTE_SIZE

	rep outsb

	ret

ENDP load_palette

PROC background
	ARG	@@color:dword
	USES	eax, ecx, edi

	mov 	edi, VMEMADDR

	mov 	ecx, SCR_WIDTH*SCR_HEIGHT
	mov	al, [BYTE PTR @@color]
	rep 	stosb

	ret
ENDP background

PROC draw_square

	ARG	@@color:dword, @@x:dword, @@y:dword
	USES	eax, ebx, ecx, edx

	mov 	eax, [@@y]
	mov	edx, SCR_WIDTH
	mul	edx

	add	eax, VMEMADDR
	add	eax, [@@x]
	mov	edi, eax

	cld
	xor	ebx,ebx

@@draw_line:
	mov	ecx, SQUARE_SIZE
	mov	eax, [@@color]

	rep stosb

	add	edi, SCR_WIDTH
	sub	edi, SQUARE_SIZE
	inc	ebx

	cmp	ebx, SQUARE_SIZE
	jnz	@@draw_line

	ret
ENDP draw_square

PROC draw_piece

	ARG 	@@piece:dword, @@x:dword, @@y:dword
	USES 	eax, ebx, ecx, edx

	mov	eax, [@@piece]
	mov	ebx, eax
	and	eax, KIND_MASK
	cmp	eax, 0
	jz	@@return
	dec	eax

	and	ebx, COLOR_MASK
	shr	ebx, 7

	shl	eax, 1
	add	eax, ebx
	mov	ebx, [PIECE_IMG_TABLE + eax * 4]

	mov	eax, [@@y]
	mov	edx, SCR_WIDTH
	mul	edx

	add	eax, VMEMADDR
	add	eax, [@@x]

	xor	dh, dh
@@loop_y:

	xor	ecx, ecx
@@loop_x:

	mov	dl, [ebx]
	;mov	dl, 6
	cmp	dl, 0
	jz	@@alpha_no_copy
	mov	[eax], dl

@@alpha_no_copy:
	inc	ebx
	inc	ecx
	inc	eax

	cmp	ecx, SQUARE_SIZE
	jnz	@@loop_x

	add	eax, SCR_WIDTH
	sub	eax, SQUARE_SIZE

	inc	dh
	cmp	dh, SQUARE_SIZE
	jnz	@@loop_y

@@return:
	ret

ENDP draw_piece


PROC draw_board

	USES 	eax, ebx, ecx, edx, esi
	LOCAL	@@x:dword
	LOCAL	@@y:dword

	mov	eax, offset BOARD

	xor 	ecx,ecx
	mov	[@@x],ecx
	mov	[@@y],ecx

	xor	bx, bx

@@loop1:
	xor 	dx,dx

@@loop2:
	test	bx, 1
	jz 	@@draw_white
	call 	draw_square,03h,[@@x],[@@y]
	jmp	@@end_draw_white
@@draw_white:
	call 	draw_square,04h,[@@x],[@@y]
@@end_draw_white:

	call	draw_piece, [DWORD PTR eax], [@@x], [@@y]
	inc	eax

	add 	[WORD PTR @@x], SQUARE_SIZE
	inc	bx

	inc 	dx
	cmp 	dx, 08h
	jl 	@@loop2

	mov	[WORD PTR @@x], 0

	inc	bx
	inc 	cx
	add 	[WORD PTR @@y], SQUARE_SIZE
	cmp 	cx, 08h
	jl 	@@loop1

	ret
ENDP draw_board

PROC move_selection
	ARG	@@dx:dword, @@dy:dword
	USES	eax, ebx, ecx, edx

	cmp	[CURRENT_MODE], mode_from
	jz	@@mode_from

	mov	eax, [TO_X]
	mov	ebx, [TO_Y]
	push	eax
	push	ebx

	add	eax, [@@dx]
	mov	[TO_X], eax
	add	ebx, [@@dy]
	mov	[TO_Y], ebx
	jmp	@@erase_highlight

@@mode_from:
	mov	eax, [FROM_X]
	mov	ebx, [FROM_Y]
	push	eax
	push	ebx

	add	eax, [@@dx]
	mov	[FROM_X], eax
	add	ebx, [@@dy]
	mov	[FROM_Y], ebx

@@erase_highlight:
	mov	ebx, [esp]; Y
	xor	ebx, [esp + 4]; X
	test	ebx, 01h

	pop	ebx
	pop	eax
	jz	@@highlight_white

	call	highlight_square, eax, ebx, 3
	ret

@@highlight_white:
	call	highlight_square, eax, ebx, 4
	ret

ENDP move_selection

; Moves to the next state of selection. If a move is finalised, ecx is set
; to a nonzero value, and eax and ebx contain the from amd to positions in
; STRUC position format, as opposed to pixel format.
PROC set_selection
	USES	eax, ecx

	cmp	[CURRENT_MODE], mode_to
	jz	@@finalize_move

	mov	[CURRENT_MODE], mode_to
	mov	eax, [FROM_X]
	mov	[TO_X], eax
	mov	eax, [FROM_Y]
	mov	[TO_Y], eax
	xor	ecx, ecx
	ret

@@finalize_move:

	mov	eax, [FROM_Y]
	mov	ebx, [FROM_X]
	mov	ah, bl

	mov	ebx, [TO_Y]
	mov	ecx, [TO_X]
	mov	bh, cl

	mov	ecx, 1h

	ret
ENDP set_selection

PROC highlight_all
	USES 	eax, ebx, ecx, esi, edi

	lea si, [TO_ARRAY]
	mov ecx, LEN_ARRAY - 1
@@iterate:
	lea di, [TO_ARRAY + 4]
	mov ax, [si]
	mov bx, [di]
	call highlight_square, ax, bx, 06h
	loop @@iterate

	call	highlight_square, [FROM_X], [FROM_Y], 05h
	cmp	[TO_X], PX_UNSET
	jz	@@return
	call	highlight_square, [TO_X], [TO_Y], 06h

@@return:
	ret

ENDP highlight_all

PROC reset_highlight

	mov	[CURRENT_MODE], mode_from
	mov	[FROM_X], 0
	mov	[FROM_Y], 0
	mov	[TO_X], PX_UNSET
	mov	[TO_Y], PX_UNSET
	ret
ENDP reset_highlight

PROC highlight_square ;WPO4
	ARG 	@@x0:dword, @@y0:dword, @@color:dword
	USES 	eax, ebx, ecx, edx, edi ; note: MUL uses edx!

	; Compute the index of the rectangle's top left corner
	mov	eax, [@@y0]
	shl	eax, 4

	mov	edx, SCR_WIDTH
	mul	edx		; move to row

	mov	ebx, [@@x0]
	shl 	ebx, 4
	add	eax, ebx 	; move to column

	; Compute top left corner address
	mov edi, VMEMADDR
	add edi, eax

	; Plot the top horizontal edge.
	mov	edx, SQUARE_SIZE	; store width in edx for later reuse
	mov	ecx, edx
	mov	al, [BYTE PTR @@color]
	rep stosb
	sub	edi, edx		; reset edi to left-top corner

	; plot both vertical edges
	mov	ecx,SQUARE_SIZE
	@@vertLoop:
		mov	[edi],al		; left edge
		mov	[edi+edx-1],al	; right edge
		add	edi, SCR_WIDTH
		loop @@vertLoop
	; edi should point at the bottom-left corner now
	sub edi, SCR_WIDTH

	; Plot the bottom horizontal edge.
	mov	ecx, edx
	rep stosb
	ret
ENDP highlight_square

PROC clean_screen

	USES	eax, ecx, edx

	mov	ah,0Ch
	mov	cx,100h

@@loop1:
	mov 	dx,100h

	@@loop2:
		int 	10h
		cmp	dx,0h
		dec	dx
		jne	@@loop2

	loop	@@loop1

	ret
ENDP clean_screen



DATASEG

PIECE_IMG_TABLE DD	IMG_KING_B_DATA,	IMG_KING_W_DATA,	\
			IMG_QUEEN_B_DATA,	IMG_QUEEN_W_DATA,	\
			IMG_TURRET_B_DATA,	IMG_TURRET_W_DATA,	\
			IMG_HORSE_B_DATA,	IMG_HORSE_W_DATA,	\
			IMG_BISHOP_B_DATA,	IMG_BISHOP_W_DATA,	\
			IMG_PAWN_B_DATA,	IMG_PAWN_W_DATA

PALLETTE DB	000h, 033h/4, 099h/4, \ ; Background
		008h, 008h, 008h, \ ; Piece black
		030h, 030h, 030h, \ ; Piece white
		00Fh, 00Fh, 00Fh, \ ; Tile black
		02Ah, 02Ah, 02Ah, \ ; Tile white
		0FFh/4, 066h/4, 000h, \ ; From highlight
		0FFh/4, 066h/4, 000h  \ ; To highlight

PALLETTE_SIZE = $ - PALLETTE

TO_ARRAY DD 100h dup(?)
LEN_ARRAY = $-TO_ARRAY

FROM_X DD 0
FROM_Y DD 0
TO_X DD PX_UNSET
TO_Y DD PX_UNSET
CURRENT_MODE selection_mode mode_from

STACK 100H

END

; vim:set noet filetype=tasm:
