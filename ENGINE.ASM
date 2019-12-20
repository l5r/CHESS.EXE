IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG


DATASEG 

P EQU piece
B EQU BLACK
W EQU WHITE
K EQU piece_kind king
Q EQU piece_kind queen	
R EQU piece_kind rook
N EQU piece_kind knight
B EQU piece_kind bishop
P EQU piece_kind pawn

BOARD piece	P <B,R>, <B,N>, 62 DUP (<>)
; vim:set noet filetype=tasm:

END
