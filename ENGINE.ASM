IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "ENGINE.INC"

CODESEG

PROC do_move
	ARG @@move_from:dword, @@move_to:dword
	USES eax, ebx

	mov eax, 0h
	mov ebx, [@@move_from]
	mov [@@move_to], ebx
	mov [@@move_from], eax

ENDP do_move


DATASEG

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
		<w,R>, <w,N>, <w,B>, <w,Q>, <w,K>, <w,B>, <w,N>, <w,R>, \
		<w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P>, <w,P> \

; vim:set noet filetype=tasm:

END
