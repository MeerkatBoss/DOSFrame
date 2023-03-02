.186
.model tiny
.code

org 80h
ArgLen:
org 81h
ArgStr:

org 100h

extrn	MakeBox:proc
extrn	ReadFormat:proc
extrn	ReadHex:proc

include stdmacro.asm

include vidmacro.asm


BOX_HEIGHT	equ	3d
USER_STYLE	equ	3Fh	; '?'

TEXTLEN		equ	400h
PROMPT		equ	'Enter message you want to display:'
ERRINPMSG	equ	'Input too long.'
NOSTYLEMSG	equ	'Style not provided.'


Start:		mov		bp,		sp			; TODO: Extract smth

		mov		si, offset	ArgStr	
		xor		cx,		cx
		mov		cl, byte ptr	[ArgLen]
		.get_next_byte
		push		ax		; [bp-2] - fill color

		.get_next_byte
		push		ax		; [bp-4] - border color 

		.skip_spaces
		
		lodsb
		cmp		al,		20h
		jne		@@SelectStyle

		.print_str	StrNoStyleMsg
		.exit_program	1

@@SelectStyle:	cmp		al,		USER_STYLE
		jne		@@NoUserStyle

		.skip_spaces
		mov		bx,		si

		jmp		@@ReadStr
		
@@NoUserStyle:	sub		al,		30h		; '0'
		mov		bx,		ax
		shl		ax,		3h
		add		bx,		ax		; ax*8 + ax = 9*ax
		add		bx, offset	Style0

@@ReadStr:	push		bx				; save style offset
		.print_str	StrPrompt

		mov		di, offset	TextBuffer
		mov		ah, byte ptr	[bp-2]
		mov		cx,		TEXTLEN
		call		ReadFormat

		test		ax,		ax
		jge		@@DrawBox

		mov		ah,		09h
		mov		dx, offset	StrErrInpMsg
		int		21h
		.exit_program	1
	
@@DrawBox:	
		pop		si				; restore style offset
		.load_vbuf_es
		push		ax				; save max line length
		push		cx				; save line count

		add		ax,		4h
		mov		bx,		ax		; string length + 4 in bx
		shr		ax,		1h
		neg		ax
		shl		ax,		8h		; -width/2 in ah
		mov		al,		cl
		add		al,		2h		; line count + 1 in al
		shr		al,		1h
		neg		al				; -height/2 in al

		mov		di,		SCRMID*2
		.get_offset

		push		di

		push		bx

		mov		dx,		[bp-2]
		shl		dx,		8h		; fill color in dh
		mov		bx,		[bp-4]
		mov		dl,		bl		; border color in dl

		pop		bx

		shl		bx,		8h		; width in bh
		mov		bl,		cl
		add		bl,		2h		; height in bl


		call		MakeBox

		pop		di
		add		di,		4 + SCRWIDTH*2

		pop		cx		; line count in cx
		mov		si, offset	TextBuffer

		pop		bx

		test		cx,		cx
		jz		@@EndProgram

@@PrintLines:	push		cx
		push		di
		lodsw
		mov		cx,		ax
		mov		dx,		bx
		sub		dx,		cx
		and		dx,		not 1h

		add		di, 		dx
		rep		movsw
	
		pop		di
		add		di,		2*SCRWIDTH
		pop		cx
		loop		@@PrintLines
	

@@EndProgram:	.exit_program 0

StrErrInpMsg	db	ERRINPMSG, 0Ah, 0Dh, '$'
StrNoStyleMsg	db	NOSTYLEMSG, 0Ah, 0Dh, '$'
StrPrompt	db	PROMPT, 0Ah, 0Dh, '$'
TextBuffer	dw	TEXTLEN dup (?)

;		   t.left	top	t.right	left	fill	right	b.left	bott.	b.right  
Style0		db 0C9h,	0CDh,	0BBh,	0BAh,	020h,	0BAh,	0C8h,	0CDh,	0BCh	; double border
Style1		db 0DAh,	0C4h,	0BFh,	0B3h,	020h,	0B3h,	0C0h,	0C4h,	0D9h	; single border
Style2		db 002h,	003h,	002h,	003h,	020h,	003h,	002h,	003h,	002h	; hearts 
Style3		db 024h,	00Bh,	024h,	00Bh,	020h,	00Bh,	024h,	00Bh,	024h	; 300$

end Start