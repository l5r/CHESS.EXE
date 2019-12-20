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
VMEMADDR EQU 0A0000h	; video memory address
SCR_WIDTH EQU 320		; screen witdth
SCR_HEIGHT EQU 230		; screen height
; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG


PROC VideoMode
	ARG	@@VM:dword
	USES	eax

	mov 	ax, [WORD PTR @@VM]
	int 	10h

	ret
ENDP VideoMode

PROC Background
	ARG	@@color:dword
	USES	eax, ecx, edi

	mov 	edi, VMEMADDR

	mov 	ecx, SCR_WIDTH*SCR_HEIGHT
	mov	al, [BYTE PTR @@color]
	rep 	stosb

	ret
ENDP Background

PROC draw_square

	ARG	@@color:dword, @@x:dword, @@y:dword
	USES	eax, ecx, edx

	mov 	cx, [WORD PTR @@x]
	mov 	dx, [WORD PTR @@y]

@@draw_square_horizontal:
	mov 	ah, 0Ch     	 ; set the config to writing a pixel
	mov 	al, [BYTE PTR @@color]; set color to white
	mov 	bh, 00h    	 ; set the page number
	int 	10h       	 ; execute the config

	inc 	cx        	 ; CX is counter and you higher item
	mov 	ax, cx    	 ; move column into AX registers
	sub 	ax,[WORD PTR @@x]
	cmp 	ax,[SQUARE_SIZE]
	jng 	@@draw_square_horizontal

	mov 	cx, [WORD PTR @@x]	 ; CX register goed back to initial column
	inc 	dx        	 ; we advance one line

	mov 	ax,dx
	sub 	ax,[WORD PTR @@y]
	cmp 	ax, [SQUARE_SIZE]
	jng 	@@draw_square_horizontal

	ret
ENDP draw_square


PROC draw_board

	USES 	eax, ecx, edx
	LOCAL	@@x:dword
	LOCAL	@@y:dword

	xor 	ecx,ecx
	mov	[@@x],ecx
	mov	[@@y],ecx

@@loop1:
	xor 	dx,dx

	@@loop2:
		test 	dx, 01h
		jz 	@@draw_white
		call 	draw_square,08h,[@@x],[@@y]
		mov 	ax, 0Fh
		add 	[WORD PTR @@x], ax

	@@draw_white:
		call 	draw_square,0Fh,[@@x],[@@y]
		mov 	ax, 0Fh
		add 	[WORD PTR @@y], ax

	inc 	dx
	cmp 	dx, 08h
	jle 	@@loop2

	inc 	cx
	mov 	ax, 0Fh
	add 	[WORD PTR @@y], ax
	cmp 	cx, 08h
	jle 	@@loop1

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
	movzx	edx, [SQUARE_SIZE]	; store width in edx for later reuse
	mov	ecx, edx
	mov	al,[BYTE PTR SQUARE_SIZE]
	rep stosb
	sub	edi, edx		; reset edi to left-top corner

	; plot both vertical edges
	movzx	ecx,[SQUARE_SIZE]
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
SQUARE_X DB 00h ; x coordinate SQUARE
SQUARE_Y DB 00h ; y coordinate SQUARE
SQUARE_SIZE DW 0Fh ;square must be 16px

STACK 100H

END
