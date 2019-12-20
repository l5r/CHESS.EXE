
; vim:ft=tasm:tw=8

ENUM piece_color black, white
ENUM piece_kind {
	king
	queen	
	rook
	knight
	bishop
	pawn
}

STRUC piece 
	color DB ?
	kind DB ?
ENDS

STRUC position
	x DB ?
	y DB ?
ENDS

STRUC move
	from position ?
	to position ?
ENDS

GLOBAL	board:piece:64, \
	do_move:PROC
