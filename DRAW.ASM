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

; compile-time constants (with macros)
VMEMADDR EQU 0A0000h	; video memory address
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


PROC draw_board

	USES 	eax, ebx, ecx, edx
	LOCAL	@@x:dword
	LOCAL	@@y:dword

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
	mov 	ax, 10h
	add 	[WORD PTR @@x], ax
	inc	bx

	inc 	dx
	cmp 	dx, 08h
	jl 	@@loop2

	xor	ax, ax
	mov	[WORD PTR @@x], ax

	inc	bx
	inc 	cx
	mov 	ax, 10h
	add 	[WORD PTR @@y], ax
	cmp 	cx, 08h
	jl 	@@loop1

	ret
ENDP draw_board

PROC highlight_square ;WPO4
	ARG 	@@x0:dword, @@y0:dword, @@col: dword
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

STACK 100H

END
