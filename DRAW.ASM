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
SCR_WIDTH EQU 320		; screen witdth
SCR_HEIGHT EQU 200		; screen height
SQUARE_SIZE EQU 16
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
	ARG	@@idx:dword, @@r:dword, @@g:dword, @@b:dword
	USES	eax, edx

	cld

	mov	dx, 03C8h
	mov	al, 0h
	out	dx, al
	
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

	ARG @@piece:dword, @@x:dword, @@y:dword
	USES eax, ebx, ecx, edx

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
	call 	draw_square,08h,[@@x],[@@y]
	jmp	@@end_draw_white
@@draw_white:
	call 	draw_square,0Fh,[@@x],[@@y]
@@end_draw_white:

	call	draw_piece, [eax], [@@x], [@@y]
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

PROC highlight_square ;WPO4
	ARG 	@@x0:dword, @@y0:dword
	USES 	eax, ecx, edx, edi ; note: MUL uses edx!

	; Compute the index of the rectangle's top left corner
	mov	eax, [@@y0]
	mov	edx, SCR_WIDTH
	mul	edx
	add	ax, [WORD PTR @@x0]

	; Compute top left corner address
	mov edi, VMEMADDR
	add edi, eax

	; Plot the top horizontal edge.
	mov	edx, SQUARE_SIZE	; store width in edx for later reuse
	mov	ecx, edx
	mov	al,SQUARE_SIZE
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

STACK 100H

END
