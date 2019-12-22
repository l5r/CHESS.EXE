IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG

PROC do_move
	ARG 	@@move_from:dword, @@move_to:dword
	USES 	ebx, ecx, edx

	mov     eax, [@@move_from]
	cmp     [@@move_to], eax
	jz      @@return_fail
	xor     ebx, ebx
	mov     bl, ah
	add     ebx, OFFSET BOARD
	and     eax, 0FFh
	; Store these to write to later
	push    eax
	push    ebx
	xor     ecx, ecx
	mov     cl, [ebx + eax*8]

	; Only move pieces from the same color as your turn.
	mov	bl, cl
	shr	bl, 7
	cmp	[TURN], bl
	jnz	@@return_fail_2

	mov     eax, [@@move_to]
	xor     ebx, ebx
	mov     bl, ah
	add     ebx, OFFSET BOARD
	and     eax, 0FFh
	; Store these to write to later
	push    eax
	push    ebx
	xor     edx, edx
	mov     dl, [ebx + eax*8]

	; Don't take a piece of the same color
	test	dl, KIND_MASK
	jz	@@empty_piece_no_color; empty pieces don't have a color.
	mov	bl, dl
	xor	bl, cl
	test	bl, COLOR_MASK
	jz	@@return_fail_4
@@empty_piece_no_color:

	; Don't move empty pieces
	mov	bl, cl
	and	ebx, KIND_MASK
	jz	@@return_fail_4

	mov	eax, [MOVE_VALIDATION_TABLE + ebx * 4]
	call	eax, [@@move_from], [@@move_to], ecx, edx

	cmp	eax, 0h
	jz	@@return_fail_4

	pop	ebx
	pop	eax
	mov	[ebx + eax*8], cl

	pop	ebx
	pop	eax
	mov	[BYTE PTR ebx + eax*8], 0h

	not	[TURN]
	and	[TURN], 1h

	xor	eax, eax
	mov	al, dl

	jmp	@@return

@@return_fail_2:
	sub	esp, 2*4
	jmp	@@return_fail
@@return_fail_4:
	sub	esp, 4*4
@@return_fail:
	xor	eax, eax
@@return:
	ret
ENDP do_move

PROC is_not_empty
	ARG	@@tile:dword
	USES	ebx

	mov	eax, [@@tile]
	xor	ebx, ebx
	mov	bl, ah
	add	ebx, OFFSET BOARD
	and	eax, 0FFh
	mov	al, [ebx + eax*8]
	and	al, KIND_MASK
	ret
ENDP

PROC always_ok
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	mov	eax, 1
	ret
ENDP always_ok

PROC validate_king
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ebx, ecx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]


	mov 	al, bl
	sub 	al, cl
	cmp 	al, 1
	je 	@@check_x
	cmp 	al, 0
	je 	@@check_x
	cmp 	al, -1
	je 	@@check_x

	xor 	eax, eax
	ret
@@check_x:
	mov 	ah, bh
	sub 	ah, ch
	cmp 	ah, 1
	je 	@@ok
	cmp 	ah, 0
	je 	@@ok
	cmp 	ah, -1
	je 	@@ok

	xor 	eax, eax
	ret
@@ok:
	mov 	eax, 1
	ret
ENDP validate_king

PROC validate_queen
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ebx, ecx

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
	jz	@@iterate_x

	cmp	ch, bh ; x == x
	jz 	@@iterate_y

	mov 	ah, bh
	sub 	ah, ch
	mov 	al, bl
	sub 	al, cl
	cmp 	ah, al
	jz 	@@iterate
	not 	al
	inc 	al
	cmp 	ah, al
	jz 	@@iterate

	jmp 	@@not_ok
@@iterate:
	cmp 	cl, bl
	je 	@@finish
	add 	ch, dh
	add 	cl, dl
	call 	is_not_empty, ecx
	jnz 	@@iterate		;veranderen
	jmp 	@@not_ok
@@iterate_x:
	cmp 	ch, bh
	jmp 	@@finish
	add 	ch, dh
	call 	is_not_empty, ecx
	jnz	@@iterate_x
	jmp 	@@not_ok
@@iterate_y:
	cmp 	cl, bl
	jmp 	@@finish
	add 	cl, dl
	call 	is_not_empty, ecx
	jnz	@@iterate_y
	jmp 	@@not_ok
@@finish:
	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret

ENDP validate_queen

PROC validate_rook
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ecx, ebx, edx

	mov	ecx, [@@move_from]
	mov	ebx, [@@move_to]

	mov 	dl, bl	; y offset
	sub 	dl, cl
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
	jz	@@iterate_x

	cmp	ch, bh ; x == x
	jz	@@iterate_y

	jmp 	@@not_ok
@@iterate_x:
	cmp 	ch, bh
	jmp 	@@finish
	add 	ch, dh
	call 	is_not_empty, ecx
	jnz	@@iterate_x
	jmp 	@@not_ok
@@iterate_y:
	cmp 	cl, bl
	jmp 	@@finish
	add 	cl, dl
	call 	is_not_empty, ecx
	jnz	@@iterate_y
	jmp 	@@not_ok
@@finish:
	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_rook

PROC validate_knight
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ebx, ecx

	mov 	ecx, [@@move_from]
	mov 	ebx, [@@move_to]

	cmp	cl, bl ; y == y
	jz	@@not_ok

	cmp	ch, bh ; x == x
	jz	@@not_ok

	mov 	ah, bh
	sub 	ah, ch
	cmp 	ah, 1
	je 	@@validate1
	cmp 	ah, -1
	je	@@validate1

	mov 	al, bl
	sub 	al, cl
	cmp 	al, 1
	je 	@@validate2
	cmp 	al, -1
	je	@@validate2

	jmp 	@@not_ok

@@validate1:
	mov 	al, bl
	sub 	al, cl
	cmp 	al, 2
	je 	@@finish
	cmp 	al, -2
	je 	@@finish

	jmp 	@@not_ok
@@validate2:
	mov 	ah, bh
	sub 	ah, ch
	cmp 	ah, 2
	je 	@@finish
	cmp 	ah, -2
	je 	@@finish

	jmp 	@@not_ok
@@finish:
	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_knight

PROC validate_bishop ;KAN NIET 2 naar links
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ebx, ecx, edx

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
	cmp 	bl, cl; y2 == y1
	je 	@@not_ok
	cmp 	bh, ch; x2 == x1
	je 	@@not_ok

	mov 	ah, bh
	sub 	ah, ch
	mov 	al, bl
	sub 	al, cl
	cmp 	ah, al
	jz 	@@iterate
	not 	al
	inc 	al
	cmp 	ah, al
	jz 	@@iterate

	jmp 	@@not_ok
@@iterate:
	cmp 	cl, bl
	je 	@@finish
	add 	ch, dh
	add 	cl, dl
	call 	is_not_empty, ecx
	jnz 	@@iterate		;veranderen
	jmp 	@@not_ok
@@finish:
	mov 	eax, 1
	ret
@@not_ok:
 	xor 	eax, eax
	ret
ENDP validate_bishop

PROC validate_pawn
	ARG 	@@move_from:dword, @@move_to:dword, @@piece_from:dword, @@piece_to:dword
	USES 	ebx, ecx, edx

	mov	ecx, [@@move_from]
	mov	edx, [@@move_to]

	; Normalise positions to the POV of black (higher y => forwards)
	test	[@@piece_from], COLOR_MASK
	jz	@@normalisation_done
	mov	ax, 0707h
	sub	ax, cx; Underflow shouldn't be possible
	mov	cx, ax
	mov	bx, 0707h
	sub	bx, dx
	mov	dx, bx
@@normalisation_done:

	sub	ch, dh; xfrom - xto
	jnz	@@diagonal_move

	test	[@@piece_to], KIND_MASK
	jnz	@@not_ok

	sub	cl, dl; yto - yfrom
	cmp	cl, -1
	jz	@@ok

	cmp	cl, -2
	jnz	@@not_ok

	; Check if starting on first row
	;cmp	dl, 1
	;jg	@@not_ok

	; Average from and to to get the piece inbetween.
	mov	eax, [@@move_from]
	add	eax, [@@move_to]
	shr	ax, 1
	call	is_not_empty, eax
	jnz	@@ok
	jmp	@@not_ok

@@diagonal_move:
	; Diagonal move is only allowed when taking a piece.
	test	[@@piece_to], KIND_MASK
	jz	@@not_ok

	; abs(ch)
	; https://stackoverflow.com/questions/2639173/x86-assembly-abs-implementation#14194764
	mov	al, ch
	sar	al, 1
	xor	ch, al
	sub	ch, al

	; Only allow going 1 place to the side diagonally
	cmp	ch, 1
	jnz	@@not_ok

	; Only allow going 1 space forwards
	sub	cl, dl; yfrom - yto
	cmp	cl, -1
	jz	@@ok
	jmp	@@not_ok

@@ok:
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
	validate_queen, \ ; Queen
	validate_rook,	\ ; Rook
	validate_knight,\ ; Knight
	validate_bishop,\ ; Bishop
	validate_pawn  	  ; Pawn

TURN piece_color black


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
