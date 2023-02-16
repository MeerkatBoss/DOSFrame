.186
.model tiny
.code

org 100h

include stdmacro.asm

include vidmacro.asm

NUMBER		equ	5418d
BOX_WIDTH	equ	18d
BOX_HEIGHT	equ	3d
BORDER_CHAR	equ	03h
BORDER_COLOR	equ	03Dh
FILL_CHAR	equ	20h
FILL_COLOR	equ	30h

BUFLEN		equ	10h
ERRINPMSG	equ	'Input too long'

NOINP		equ	08000h
INPLONG		equ	04000h

;----------------------------------------------------------------------------------------------------
; Read number less than 10^5 from stdio
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		AX	- read number or error code:
;				NOINP 	- no input
;				INPLONG	- input too long
; Destroys:	CX, DX, SI
;----------------------------------------------------------------------------------------------------
.read_num	macro
		local		TooShort, TooLong, Exit
		.do_nop

		mov		ah,		03Fh
		xor		bx,		bx
		mov		cx,		BUFLEN
		mov		dx,		offset TextBuffer
		int		21h

		cmp		ax,		06h
		ja		TooLong

		sub		ax,		02h			; do not count 0a 0d
		jbe		TooShort
	
		mov		si,		offset TextBuffer	
		mov		cx,		ax
		call		ReadDec
		jmp		Exit

TooShort:	mov		ax,		NOINP
		jmp		Exit
TooLong:	mov		ax,		INPLONG
Exit:
		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Print number in decimal, hex and binary
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- destination address (end of first line)
;		BX	- printed number
; Exit:		None
; Destroys:	AX, BX, CX, DX, SI, DI
;----------------------------------------------------------------------------------------------------
.print_three	macro
		.do_nop

		push		di
		push		bx

		.load_xy	-6d,		0
		.get_offset

		mov		ah,		FILL_COLOR
		call		PrintDec

		pop		bx		; load number
		pop		di

		push		di
		push		bx

		.load_xy	-5d,		1
		.get_offset

		mov		ah,		FILL_COLOR
		call		PrintHex

		pop		bx		; load number
		pop		di

		.load_xy	-17d,		2
		.get_offset

		mov		ah,		FILL_COLOR
		call		PrintBin

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

Start:		.read_num
		test		ax,		NOINP or INPLONG
		jz		@@NoError
		test		ax,		INPLONG	; Invalid input
		jnz		@@InvalidInput
		.exit_program	0			; Input empty

@@InvalidInput:	.print_str	StrErrInpMsg		; Input error
		.exit_program	0

@@NoError:	push		ax		; save number
		.read_num
		test		ax,		NOINP or INPLONG
		jz		@@Compute
		test		ax,		INPLONG
		jnz		@@InvalidInput
		.exit_program	0

@@Compute:	push		ax

		.load_vbuf_es

		xor		di,		di
		.load_xy	3d,		2d
		.get_offset

		push		di

		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		cx,		(BORDER_COLOR 	shl 8) or BORDER_CHAR
		mov		dx,		(FILL_COLOR	shl 8) or FILL_CHAR
		call		MakeBox

		mov		si,		sp

		mov		di,		[si]
		.load_xy	BOX_WIDTH,	0
		.get_offset

		mov		ax,		[si+2]
		mov		bx,		[si+4]

		add		bx,		ax
		.print_three

		mov		si,		sp
		mov		di,		[si]

		.load_xy	BOX_WIDTH+1,	0
		.get_offset
		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		cx,		(BORDER_COLOR 	shl 8) or BORDER_CHAR
		mov		dx,		(FILL_COLOR	shl 8) or FILL_CHAR
		call		MakeBox

		mov		si,		sp

		mov		di,		[si]
		.load_xy	2*BOX_WIDTH+1,	0
		.get_offset

		mov		ax,		[si+2]
		mov		bx,		[si+4]

		sub		bx,		ax
		.print_three

		mov		si,		sp
		mov		di,		[si]

		.load_xy	0,		BOX_HEIGHT+1
		.get_offset
		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		cx,		(BORDER_COLOR 	shl 8) or BORDER_CHAR
		mov		dx,		(FILL_COLOR	shl 8) or FILL_CHAR
		call		MakeBox

		mov		si,		sp

		mov		di,		[si]
		.load_xy	BOX_WIDTH,	BOX_HEIGHT+1
		.get_offset

		mov		bx,		[si+2]
		mov		ax,		[si+4]

		mul		bx
		mov		bx,		ax
		.print_three

		mov		si,		sp
		mov		di,		[si]

		.load_xy	BOX_WIDTH+1,		BOX_HEIGHT+1
		.get_offset
		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		cx,		(BORDER_COLOR 	shl 8) or BORDER_CHAR
		mov		dx,		(FILL_COLOR	shl 8) or FILL_CHAR
		call		MakeBox

		mov		si,		sp

		mov		di,		[si]
		.load_xy	2*BOX_WIDTH+1,	BOX_HEIGHT+1
		.get_offset

		mov		bx,		[si+2]
		mov		ax,		[si+4]

		xor		dx,		dx
		div		bx
		mov		bx,		ax
		.print_three

		.exit_program 0


include box.asm
include stdio.asm

StrNum		db 	'5418'
StrNumLen	equ 	$ - StrNum
StrErrInpMsg	db	ERRINPMSG, 0Ah, 0Dh, '$'
TextBuffer	db	BUFLEN dup (0)

end Start