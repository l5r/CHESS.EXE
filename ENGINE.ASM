IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG

PROC do_move
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	ebx, ecx, edx

	mov	eax, [@@move_from]
	cmp	[@@move_to], eax
	jz	@@return_fail

	xor	ebx, ebx
	mov	bl, ah
	add	ebx, OFFSET BOARD
	and	eax, 0FFh
	push	eax
	push	ebx
	mov	bl, [ebx + eax*8]
	push	ebx

	; Don't take a piece of the same color
	mov	bl, dl
	xor	bl, cl
	test	bl, COLOR_MASK
	jz	@@return_fail

	; Don't move empty pieces
	mov	bl, cl
	test	ebx, KIND_MASK
	jz	@@return_fail

	mov	eax, [MOVE_VALIDATION_TABLE + ebx * 4]
	call	eax, [@@move_from], [@@move_to]

	cmp	eax, 0h
	jz	@@return

	mov	eax, [@@move_to]
	xor	ebx, ebx
	mov	bl, ah
	add	ebx, OFFSET BOARD
	and	eax, 0FFh
	pop	ecx
	mov	[ebx + eax*8], cl

	pop	ebx
	pop	eax
	mov	[BYTE PTR ebx + eax*8], 0h
	jmp	@@return

@@return_fail:
	xor	eax, eax
@@return:
	ret
ENDP do_move

PROC is_not_empty
	ARG	@@tile:dword
	USES	ebx

	mov	eax, [@@move_to]
	xor	ebx, ebx
	mov	bl, ah
	add	ebx, OFFSET BOARD
	and	eax, 0FFh
	mov	al, [ebx + eax*8]
	and	al, KIND_MASK
	ret
ENDP

PROC always_ok
	ARG 	@@move_from:dword, @@move_to:dword
	mov	eax, 1
	ret
ENDP always_ok

PROC validate_king
 	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

	mov 	ah, bh
	sub 	ah, ch
	shl 	ah, 1
	cmp 	ah, 1
	jne 	@@not_ok

@@last_check:
	call	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_king

PROC validate_queen
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx, edx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

	mov 	dl, bl	; y offset
	sub 	dl, cl
	cmp 	dl, 0
	jne 	@@dl_not_zero
	jmp 	@@dh_offset
@@dl_not_zero:
	cmp 	dl, 0
	jg 	@@dl_positive
	mov 	dl, -1
	jmp 	@@validate
@@dl_positive:
	mov 	dl, 1
	jmp 	@@validate
@@dh_offset:
	mov 	dh, bh	; y offset
	sub 	dh, ch
	cmp 	dh, 0
	jne 	@@dh_not_zero
	jmp 	@@validate
@@dh_not_zero:
	cmp 	dh, 0
	jg 	@@dh_positive
	mov 	dh, -1
	jmp 	@@validate
@@dh_positive:
	mov 	dh, 1
@@validate:
	cmp	cl, bl ; y == y
	jz	@@iterate

	cmp	ch, bh ; x == x
	jz 	@@iterate

	cmp 	bl, bh ; y2 == x2
	jz	@@iterate

	jmp 	@@not_ok
@@iterate:
	cmp 	cl, bl
	jmp 	@@last_check
	add 	ch, dh
	add 	cl, dl
	call 	is_not_empty, ecx
	cmp	ecx, 0
	je 	@@iterate
	jmp 	@@not_ok
@@last_check:
	call 	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
	ret
@@not_ok:
 	xor 	eax, eax
	ret

ENDP validate_queen

PROC validate_rook
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

	mov 	dl, bl	; y offset
	sub 	dl, cl
	cmp 	dl, 0
	jne 	@@dl_not_zero
	jmp 	@@dh_offset
@@dl_not_zero:
	cmp 	dl, 0
	jg 	@@dl_positive
	mov 	dl, -1
	jmp 	@@validate
@@dl_positive:
	mov 	dl, 1
	jmp 	@@validate
@@dh_offset:
	mov 	dh, bh	; y offset
	sub 	dh, ch
	cmp 	dh, 0
	jne 	@@dh_not_zero
	jmp 	@@validate
@@dh_not_zero:
	cmp 	dh, 0
	jg 	@@dh_positive
	mov 	dh, -1
	jmp 	@@validate
@@dh_positive:
	mov 	dh, 1
@@validate:
	cmp	cl, bl ; y == y
	jz	@@iterate

	cmp	ch, bh ; x == x
	jz	@@iterate

	jmp 	@@not_ok
@@iterate:
	cmp 	cl, bl
	jmp 	@@last_check
	add 	ch, dh
	add 	cl, dl
	call 	is_not_empty, ecx
	cmp	ecx, 0
	je 	@@iterate
	jmp 	@@not_ok
@@last_check:
	call 	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_rook

PROC validate_knight
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov 	ecx, [@@move_from]
	mov 	ebx, [@@move_to]

	cmp	cl, bl ; y == y
	jz	@@not_ok

	cmp	ch, bh ; x == x
	jz	@@not_ok

	mov 	ah, bh
	sub 	ah, ch
	shl 	ah, 1

	cmp 	ah, 4
	jle 	@@validate1
	jmp 	@@not_ok

	mov 	al, bl
	sub 	al, cl
	shl 	al, 1

	cmp 	al, 4
	jle 	@@validate2
	jmp 	@@not_ok

;first we check whether our x difference is 1 or 2
@@validate1:
	cmp 	ah, 1
	je	@@validate3
	cmp 	al, 1
	je 	@@last_check
	jmp 	@@not_ok
@@validate3:
	cmp 	al, 4
	je 	@@last_check
	jmp 	@@not_ok

;then we check whether our y difference is 1 or 2
@@validate2:
	cmp 	al, 1
	je	@@validate4
	cmp 	ah, 1
	je 	@@last_check
	jmp 	@@not_ok
@@validate4:
	cmp 	ah, 4
	je 	@@last_check
	jmp 	@@not_ok
@@last_check:
	call 	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_knight

PROC validate_bishop
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

	mov 	dl, bl	; y offset
	sub 	dl, cl
	cmp 	dl, 0
	jne 	@@dl_not_zero
	jmp 	@@dh_offset
@@dl_not_zero:
	cmp 	dl, 0
	jg 	@@dl_positive
	mov 	dl, -1
	jmp 	@@validate
@@dl_positive:
	mov 	dl, 1
	jmp 	@@validate
@@dh_offset:
	mov 	dh, bh	; y offset
	sub 	dh, ch
	cmp 	dh, 0
	jne 	@@dh_not_zero
	jmp 	@@validate
@@dh_not_zero:
	cmp 	dh, 0
	jg 	@@dh_positive
	mov 	dh, -1
	jmp 	@@validate
@@dh_positive:
	mov 	dh, 1
@@validate:
	cmp 	bl, bh ; y2 == x2
	je 	@@iterate
	jmp	@@not_ok
@@iterate:
	cmp 	cl, bl
	jmp 	@@last_check
	add 	ch, dh
	add 	cl, dl
	call 	is_not_empty, ecx
	cmp	ecx, 0
	je 	@@iterate
	jmp 	@@not_ok
@@last_check:
	call 	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_bishop

PROC validate_pawn
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	eax, ebx, ecx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

@@validate:
	cmp 	cl, bl ; y1 == y2
	jz	@@forward_move

	mov 	al, bl
	sub 	al, cl
	shl	al, 1

	cmp 	al, 1
	jne	@@not_ok
	jmp 	@@last_check
@@forward_move:
	mov 	ah, bh
	sub 	ah, ch
	cmp 	ah, 0
	jg 	@@validate_x

	sub 	ah, bh	; add positive val to inter reg
	mov 	bh, ah	; restore in bh
@@validate_x:
	cmp 	ch, 2
	je 	@@first_move

	cmp 	ch, 7
	je 	@@first_move

	cmp 	bh, 1
	jne	@@not_ok
	jmp 	@@last_check
@@first_move:
	cmp 	bh, 2
	jg	@@not_ok
	dec 	ch
	call 	is_not_empty, ecx
	cmp 	eax, 1
	je 	@@not_ok
@@last_check:
	call 	is_not_empty, ebx
	cmp 	eax, 1
	jne 	@@not_ok
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
