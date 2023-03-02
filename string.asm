;====================================================================================================
; string.asm
;====================================================================================================
.186
.model tiny
.code
public	ReadFormat

include stdmacro.asm

extrn ReadHex:proc

BUFLEN		equ 80d
MAXLINE		equ 70d

;----------------------------------------------------------------------------------------------------
; Read multiline formatted string and store it in buffer
; ^xx, where xx is a hex number is interpreted as screen attrubute change
; \xx, where xx is a hex number is interpreted as ASCII code of symbol
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI		- buffer address
;		AH		- default screen attribute
;		CX		- buffer size (in words)
; Exit:		AX		- maximum line length (negative upon input error)
;		CX		- number of lines read
;		ES:[DI]		- line length (in words) and line characters with attributes
; Destroys:	BX, DX, DI, SI
;----------------------------------------------------------------------------------------------------
ReadFormat	proc

		push		bp		; TODO: enter (not neccessery)?
		mov		bp,		sp
		
		push		ax		; [bp-2] - screen attrubute
		push		cx		; [bp-4] - buffer length
		push		0		; [bp-6] - maximum line length
		push		0		; [bp-8] - number of lines read

@@ReadLoop:	.scan_str	TextBuffer,	BUFLEN
;		mov		ah,		3Fh
;		xor		bx,		bx
;		mov		cx,		BUFLEN
;		mov		dx, offset	TextBuffer
;		int		21h


		cmp		ax,		MAXLINE + 2	; exlude 0D 0A
		ja		@@ErrTooLong			; Line too long

		sub		ax,		2		; ignore 0D 0A at end
		jle		@@Success			; Empty line, stop input

		mov		cx,		[bp-4]
		cmp		ax,		cx
		jae		@@ErrTooLong			; Can't move to buffer

		; MOST IMPORTANT THING IN THIS PROGRAM, DO NOT TOUCH
@@ReadStore:	;stosw				; store line length in buffer
		add		di,		2

		mov		cx,		ax
		mov		ax, word ptr	[bp-2]
		mov		si, offset	TextBuffer
		call		FormatLine

		mov		bx,		cx
		shl		bx,		1h
		add		bx,		2h	; bx = 2*cx + 2
		sub		di,		bx	; di -= 2*cx + 2 (offset di by length+1 words)
		mov		es:[di],	cx	; store line length before string
		add		di,		bx	; di += 2*cx + 2 (restore di)

		mov		bx, word ptr	[bp-4]
		sub		bx,		cx
		dec		bx
		mov word ptr	[bp-4],		bx	; update buffer length

		mov		bx, word ptr	[bp-6]
		cmp		bx,		cx
		jae		@@ReadUpdAttr
		mov word ptr	[bp-6],		cx

@@ReadUpdAttr:	mov word ptr	[bp-2],		ax	; update screen attrubute

		mov		bx, word ptr	[bp-8]
		inc		bx
		mov word ptr	[bp-8],		bx	; update line count

		
		jmp		@@ReadLoop

@@ErrTooLong:	mov		ax,		-1d
		jmp		@@End

@@Success:	mov		ax, word ptr	[bp-6]
		mov		cx, word ptr	[bp-8]

@@End:		mov		sp,		bp	; TODO: leave?
		pop		bp

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Interpret all escaped characters in line and store all symbols in buffer alongside their attributes
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- result buffer
;		DS:SI	- source buffer
;		AH	- screen attribute
;		CX	- line length
; Exit:		ES:DI	- next free buffer word
;		AH	- new screen attribute
;		CX	- stored line length
; Destroys:	BX, DX, SI
;----------------------------------------------------------------------------------------------------
FormatLine	proc

		test		cx,		cx
		jnz		@@StoreLoop
		ret				; this is not very efficient but I don't want to use long jump

@@StoreLoop:	lodsb
;		mov		al, byte ptr	ds:[si]
;		inc		si

		cmp		al,		5Ch	; backslash
		je		@@CodeChar
		cmp		al,		5Eh	; caret
		je		@@CodeAttr

		stosw
		inc		bx
		loop		@@StoreLoop
		jmp		@@StoreStop

@@CodeChar:	push		ax
		push		bx
;		xchg		di,		si
		dec		cx

		.get_next_byte
		
;		xchg		di,		si

		pop		bx

		pop		dx
		and		dx,		0FF00h
		or		ax,		dx
		stosw
		inc		bx

		test		cx,		cx
		jz		@@StoreStop
		jmp		@@StoreLoop

@@CodeAttr:	push		bx
;		xchg		di,		si
		dec		cx

		.get_next_byte
		
;		xchg		di,		si

		pop		bx

		shl		ax,		8h	; Move attribute to AH

		test		cx,		cx
		jz		@@StoreStop
		jmp		@@StoreLoop

@@StoreStop:	mov		cx,		bx

@@StoreEnd:	ret
		endp
;----------------------------------------------------------------------------------------------------


.data

TextBuffer:	db BUFLEN dup (?)

end
