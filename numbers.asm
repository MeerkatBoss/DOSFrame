.186
.model tiny
.code
local @@

org 100h

include stdmacro.asm

include vidmacro.asm

NUMBER		equ	5418d
BOX_X		equ	(-30d) and 0FFh
BOX_Y		equ	(  5d) and 0FFh
BOX_WIDTH	equ	7d
BOX_HEIGHT	equ	1d
BORDER_CHAR	equ	03h
BORDER_COLOR	equ	03Dh
FILL_CHAR	equ	20h
FILL_COLOR	equ	30h

Start:
		.load_vbuf_es
		mov		ax,		(BOX_X		shl 8) or BOX_Y
		mov		di,		SCRWIDTH*2
		.get_offset
		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		cx,		(BORDER_COLOR 	shl 8) or BORDER_CHAR
		mov		dx,		(FILL_COLOR	shl 8) or FILL_CHAR
		call		MakeBox

		mov		si,		offset StrNum
		mov		cx,		StrNumLen
		call		ReadDec
		mov		bx,		ax

		mov		di,		SCRWIDTH*2
		mov		ax,		((BOX_X+1)	shl 8) or BOX_Y
		.get_offset
		mov		ah,		FILL_COLOR
		call		PrintDec
		.exit_program 0


include box.asm
include stdio.asm

StrNum		db 	'5418'
StrNumLen	equ 	$ - StrNum

end Start