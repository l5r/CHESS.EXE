
; vim:ft=tasm:tw=8

ENUM piece_color black = 0, white = 1
BLACK EQU piece_color black
WHITE EQU piece_color white

ENUM piece_kind {
	none = 0
	king
	queen	
	rook
	knight
	bishop
	pawn
}

RECORD piece {
	color:1 = 0
	kind:7 = 0
}

STRUC position
	x DB ?
	y DB ?
ENDS

STRUC move
	from position ?
	to position ?
ENDS

GLOBAL BOARD:piece:64, \
	do_move:PROC
