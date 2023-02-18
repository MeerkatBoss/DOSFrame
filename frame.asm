.186
.model tiny
.code

org 100h

include stdmacro.asm

include vidmacro.asm

extrn	MakeBox:proc
extrn	ReadDec:proc
extrn	PrintDec:proc
extrn	PrintHex:proc
extrn	PrintBin:proc

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

@@Compute:	push		ax		; save number

		.load_vbuf_es

		xor		di,		di
		.load_xy	3d,		2d
		.get_offset

		push		di

		mov		si,		offset Style2
		mov		bx,		(BOX_WIDTH 	shl 8) or BOX_HEIGHT
		mov		dx,		(FILL_COLOR	shl 8) or BORDER_COLOR
		call		MakeBox

		pop		di
		.load_xy	BOX_WIDTH,	0
		.get_offset

		pop		bx
		pop		ax

		add		bx,		ax
		.print_three

		.exit_program 0

StrNum		db 	'5418'
StrNumLen	equ 	$ - StrNum
StrErrInpMsg	db	ERRINPMSG, 0Ah, 0Dh, '$'
TextBuffer	db	BUFLEN dup (0)

;		   t.left	top	t.right	left	fill	right	b.left	bott.	b.right  
Style0		db 0C9h,	0CDh,	0BBh,	0BAh,	020h,	0BAh,	0C8h,	0CDh,	0BCh	; double border
Style1		db 0DAh,	0C4h,	0BFh,	0B3h,	020h,	0B3h,	0C0h,	0C4h,	0D9h	; single border
Style2		db 002h,	003h,	002h,	003h,	020h,	003h,	002h,	003h,	002h	; hearts 

end Start