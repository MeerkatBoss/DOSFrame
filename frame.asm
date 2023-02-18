.186
.model tiny
.code

org 80h
ArgLen:
org 81h
ArgStr:

org 100h

include stdmacro.asm

include vidmacro.asm

extrn	MakeBox:proc
extrn	GetNextByte:proc

BOX_HEIGHT	equ	3d
; BORDER_COLOR	equ	03Dh
; FILL_COLOR	equ	30h
USER_STYLE	equ	3Fh	; '?'

BUFLEN		equ	50h
MAXMSGLEN	equ	60d
PROMPT		equ	'Enter message you want to display:'
ERRINPMSG	equ	'Input too long.'
NOSTYLEMSG	equ	'Style not provided.'


Start:		mov		bp,		sp

		mov		di, offset	ArgStr	
		xor		cx,		cx
		mov		cl, byte ptr	[ArgLen]
		call		GetNextByte
		push		ax				; save fill color

		call		GetNextByte
		push		ax				; save border color

		xor		ax,		ax		
		mov		al,		20h
		repz		scasb				; skip spaces
		
		jnz		@@SelectStyle
		test		cx,		cx
		jnz		@@SelectStyle

		mov		ah,		09h
		mov		dx, offset	StrNoStyleMsg
		int		21h
		.exit_program	1
		

@@SelectStyle:	mov		al, byte ptr	[di-1]
		cmp		al,		USER_STYLE
		jne		@@NoUserStyle

		mov		al,		20h
		repz		scasb				; skip spaces
		dec		di
		mov		si,		di

		jmp		@@ReadStr
		
@@NoUserStyle:	sub		al,		30h		; '0'
		mov		si,		ax
		shl		ax,		3h
		add		si,		ax		; ax*8 + ax = 9*ax
		add		si, offset	Style0

@@ReadStr:	mov		ah,		09h	
		mov		dx, offset	StrPrompt
		int		21h

		mov		ah,		3Fh
		xor		bx,		bx
		mov		cx,		BUFLEN
		mov		dx, offset	TextBuffer
		int		21h
		cmp		ax,		2h
		ja		@@CheckLength

		.exit_program	0

@@CheckLength:	cmp		ax,		MAXMSGLEN + 2	; exclude 0D 0A
		jbe		@@DrawBox

		mov		ah,		09h
		mov		dx, offset	StrErrInpMsg
		int		21h
		.exit_program	1
	
@@DrawBox:	.load_vbuf_es
		push		ax				; save string length + 2

		add		ax,		2h
		mov		bx,		ax		; string length + 2 in bx
		shr		ax,		1h
		neg		ax
		shl		ax,		8h		; -width/2 in ah
		mov		al,		BOX_HEIGHT
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
		mov		bl,		BOX_HEIGHT	; height in bl

		call		MakeBox

		pop		di
		add		di,		4 + SCRWIDTH*2

		pop		cx
		sub		cx,		2		; string length in cx
		mov		si, offset	TextBuffer
		mov		ah,		[bp-2]

@@PrintStr:	lodsb
		stosw
		loop		@@PrintStr

	

		.exit_program 0

StrErrInpMsg	db	ERRINPMSG, 0Ah, 0Dh, '$'
StrNoStyleMsg	db	NOSTYLEMSG, 0Ah, 0Dh, '$'
StrPrompt	db	PROMPT, 0Ah, 0Dh, '$'
TextBuffer	db	BUFLEN dup (?)

;		   t.left	top	t.right	left	fill	right	b.left	bott.	b.right  
Style0		db 0C9h,	0CDh,	0BBh,	0BAh,	020h,	0BAh,	0C8h,	0CDh,	0BCh	; double border
Style1		db 0DAh,	0C4h,	0BFh,	0B3h,	020h,	0B3h,	0C0h,	0C4h,	0D9h	; single border
Style2		db 002h,	003h,	002h,	003h,	020h,	003h,	002h,	003h,	002h	; hearts 
Style3		db 024h,	00Bh,	024h,	00Bh,	020h,	00Bh,	024h,	00Bh,	024h	; 300$

end Start