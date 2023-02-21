;====================================================================================================
; string.asm
;====================================================================================================
.186
.model tiny
.code
public	GetNextByte, ReadFormat

extrn ReadHex:proc

BUFLEN		equ 80d
MAXLINE		equ 70d

;----------------------------------------------------------------------------------------------------
; Get first hex integer encountered in string
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- string start address
;		CX	- string length
; Exit:		ES:DI	- first not converted character
;		CX	- remaining string length
;		AL	- converted number
; Destroys:	AH, BX, DX
;----------------------------------------------------------------------------------------------------
GetNextByte	proc

		xor		ax,		ax

		mov		al,		20h	; ' '
		repz		scasb
		dec		di
		test		cx,		cx
		jz		@@GNBEnd
		
		mov		bx,		cx
		inc		bx

		mov		cx,		2h
		repnz		scasb			; until space or 2 chars

		sub		cx,		2h
		neg		cx			; -(cx - 2) = 2 - cx (safe negation of small values)
		sub		bx,		cx	; remaining length in bx
		sub		di,		cx

		call		ReadHex

		mov		cx,		bx	; remaining length

@@GNBEnd:	ret
		endp
;----------------------------------------------------------------------------------------------------

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

		push		bp
		mov		bp,		sp
		
		push		ax		; [bp-2] - screen attrubute
		push		cx		; [bp-4] - buffer length
		push		0		; [bp-6] - maximum line length
		push		0		; [bp-8] - number of lines read

@@ReadLoop:	mov		ah,		3Fh
		xor		bx,		bx
		mov		cx,		BUFLEN
		mov		dx, offset	TextBuffer
		int		21h


		cmp		ax,		MAXLINE + 2	; exlude 0A 0D
		ja		@@ReadLong	; Line too long

		sub		ax,		2
		jle		@@ReadOk	; Empty line, stop input

		mov		cx,		[bp-4]
		cmp		ax,		cx
		jae		@@ReadLong	; Can't move to buffer

@@ReadStore:	stosw				; store line length in buffer

		mov		cx,		ax
		mov		ax, word ptr	[bp-2]
		mov		si, offset	TextBuffer
		call		StoreLine

		mov		bx,		cx
		shl		bx,		1h
		add		bx,		2h
		sub		di,		bx
		mov		es:[di],	cx
		add		di,		bx

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

@@ReadLong:	mov		ax,		-1d
		jmp		@@ReadEnd

@@ReadOk:	mov		ax, word ptr	[bp-6]
		mov		cx, word ptr	[bp-8]

@@ReadEnd:	mov		sp,		bp
		pop		bp

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Store line
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
StoreLine	proc

		test		cx,		cx
		jz		@@StoreEnd

@@StoreLoop:	mov		al, byte ptr	ds:[si]
		inc		si

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
		xchg		di,		si
		dec		cx

		call		GetNextByte
		
		xchg		di,		si

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
		xchg		di,		si
		dec		cx

		call		GetNextByte
		
		xchg		di,		si

		pop		bx

		shl		ax,		8h

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
