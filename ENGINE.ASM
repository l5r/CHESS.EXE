IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG

PROC do_move
	ARG @@move_from:dword, @@move_to:dword
	USES eax, ebx

	mov	eax, [@@move_from]
	xor	ebx, ebx
	mov	bl, ah
	add	ebx, OFFSET BOARD
	and	eax, 0FFh
	mov	bl, [ebx + eax*8]

	and	ebx, KIND_MASK
	cmp	ebx, 0h
	jz	@@return ; Don't move empty pieces
	mov	eax, [MOVE_VALIDATION_TABLE + ebx * 4]
	call	eax, [@@move_from], [@@move_to]

	cmp	eax, 0h
	jz	@@return

	mov	eax, [@@move_from]
	mov	[@@move_to], eax
	mov	[@@move_from], 0h

@@return:
	ret
ENDP do_move

PROC always_ok
	ARG @@move_from:dword, @@move_to:dword
	mov	eax, 1
	ret
ENDP always_ok

PROC validate_rook
	ARG @@move_from:dword, @@move_to:dword

	USES ebx
	mov	eax, [@@move_from]
	mov	ebx, [@@move_to]

	cmp	al, bl ; y == y
	jz	@@ok
	
	cmp	ah, bh ; x == x
	jz	@@ok

	xor	eax, eax
	ret
@@ok:
	mov	eax, 1
	ret
ENDP validate_rook


DATASEG

MOVE_VALIDATION_TABLE \
DD	always_ok,	\ ; No piece, should this be possible?
	always_ok, 	\ ; King
	always_ok, 	\ ; Queen
	validate_rook,	\ ; Rook
	always_ok,	\ ; Knight
	always_ok, 	\ ; Bishop
	always_ok  	  ; Pawn


b EQU 0
w EQU 1
K EQU 1
Q EQU 2
R EQU 3
N EQU 4
B EQU 5
P EQU 6

BOARD piece	<b,R>, <b,N>, <b,B>, <b,Q>, <b,K>, <b,B>, <b,N>, <b,R>, \
		<b,P>, <b,P>, <b,P>, <b,P>, <b,P>, <b,P>, <b,P>, <b,P>, \
		32 DUP (<>), \
		<w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P>, \
		<w,R>, <w,N>, <w,B>, <w,K>, <w,Q>, <w,B>, <w,N>, <w,R>

; vim:set noet filetype=tasm:

END
