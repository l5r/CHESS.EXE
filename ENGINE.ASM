IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG

PROC do_move
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx

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
	ARG 	@@move_from:dword, @@move_to:dword
	mov	eax, 1
	ret
ENDP always_ok

PROC validate_king
 	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov	eax, [@@move_from]
	mov	ebx, [@@move_to]

	sub 	bl, al
	cmp 	bl, 0
	jg 	@@validate

	sub 	cl, bl	; add positive val to inter reg
	mov 	bl, cl	; restore in bl

	sub 	bh, ah
	cmp 	bl, 0
	jg 	@@validate

	sub 	cl, bh	; add positive val to inter reg
	mov 	bh, cl	; restore in bh
@@validate:
	cmp 	bl, 1
	jg 	@@not_ok

	cmp 	bh, 1
	jg 	@@not_ok

	mov 	eax, 1
	ret
	USES 	eax, ebx
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_king

PROC validate_queen
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov	eax, [@@move_from]
	mov	ebx, [@@move_to]

	cmp	al, bl ; y == y
	jz	@@ok

	cmp	ah, bh ; x == x
	cmp 	bl, bh ; y2 == x2
	jz	@@ok

	cmp 	bl, bh
	je 	@@ok

	xor	eax, eax
	ret
@@ok:
	mov	eax, 1
	ret
ENDP validate_queen

PROC validate_rook
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx

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

PROC validate_knight
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov 	eax, [@@move_from]
	mov 	ebx, [@@move_to]

	cmp 	al, bl ; y == y
	jz 	@@not_ok

	cmp 	ah, bh ; x == x
	jz 	@@not_ok

	ENDP validate_knight
	jz 	@@not_ok

	sub 	bl, al
	cmp 	bl, 0
	jg 	@@validate

	sub 	cl, bl	; add positive val to inter reg
	mov 	bl, cl	; restore in bl

	sub 	bh, ah
	cmp 	bl, 0
	jg 	@@validate

	sub 	cl, bh	; add positive val to inter reg
	mov 	bh, cl	; restore in bh

@@validate:
	cmp 	bl, 2 ; y2 > 2
	jg	@@not_ok

	cmp 	bh, 2 ; x2 > 2
	jg 	@@not_ok

	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret

PROC validate_bishop
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx

	mov 	eax, [@@move_from]

	mov 	ebx, [@@move_to]

	cmp 	al, bl ; y == y
	jz 	@@not_ok
	cmp 	ah, bh ; x == x
	jz 	@@not_ok

	cmp 	bl, bh ; y2 == x2
	jne 	@@not_ok

	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_bishop

PROC validate_pawn
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov 	eax, [@@move_from]
	mov 	ebx, [@@move_to]

	cmp 	al, bl ; y1 == y2
	jz	@@forward_move

	sub 	bl, al
	cmp	bl, 0
	jg	@@validate_y

	sub 	cl, bl	; add positive val to inter reg
	mov 	bl, cl	; restore in bl
@@validate_y:
	cmp 	bl, 1
	jne	@@not_ok
@@forward_move:
	sub 	bh, ah
	cmp 	bh, 0
	jg 	@@validate_x

	sub 	cl, bh	; add positive val to inter reg
	mov 	bh, cl	; restore in bh
@@validate_x:
	cmp 	bh, 1
	jne	@@not_ok

	cmp 	ah, 2
	je 	@@first_move

	cmp 	ah, 7
	je 	@@first_move
@@first_move:
	cmp 	bh, 2
	jg	@@not_ok

	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_pawn

DATASEG

MOVE_VALIDATION_TABLE \
DD	always_ok,	\ ; No piece, should this be possible?
	validate_king, 	\ ; King
	validate_queen, 	\ ; Queen
	validate_rook,	\ ; Rook
	validate_knight,\ ; Knight
	validate_bishop,\ ; Bishop
	validate_pawn  	  ; Pawn


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
