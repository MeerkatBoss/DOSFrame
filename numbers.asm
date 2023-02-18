;====================================================================================================
; stdio.asm
;====================================================================================================
.186
.model tiny
.code
include stdmacro.asm

public PrintHex, PrintBin, PrintDec, ReadDec, ReadHex

;----------------------------------------------------------------------------------------------------
; Prints number in hex
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video segment address to print to
;		AH	- symbol attribute
;		BX	- number to print
; Exit:		None
; Destr:	AL, BX, SI, DI
;----------------------------------------------------------------------------------------------------
PrintHex	proc

		add		di,		06h
		std

@@PrintH:	mov		si,		bx	
		and		si,		0Fh
		mov		al,    byte ptr	[HexDigits+si]

		stosw
		
		shr		bx,		4h
		jnz		@@PrintH
		
		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Prints number in binary
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video segment address to print to
;		AH	- symbol attribute
;		BX	- number to print
; Exit:		None
; Destr:	AL, BX, DX, DI
;----------------------------------------------------------------------------------------------------
PrintBin	proc

		add		di,		1Eh
		std

@@PrintB:	mov		dx,		bx	
		and		dx,		01h
		add		dx,		30h	; '0'
		mov		al,		dl

		stosw
		
		shr		bx,		1h
		jnz		@@PrintB
		
		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Prints number in decimal
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video segment address to print to
;		AH	- symbol attribute
;		BX	- number to print
; Exit:		None
; Destroys:	AX, BX, CX, DX, DI
;----------------------------------------------------------------------------------------------------
PrintDec	proc

		xchg		ax,		bx

		add		di,		08h

		mov		cx,		0Ah

@@PrintD:	xor		dx,		dx
	
		div 		cx
		add		dl,		30h	; '0'
		mov		bl,		dl

		mov		es:[di],	bx
		sub		di,		02h

		test		ax,		not 0
		jnz		@@PrintD

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Converts string of given length to number, interpreting it as written in decimal
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- string address
;		CX	- string length
; Exit:		AX	- converted number
; Destroys:	CX, DX, DI
;----------------------------------------------------------------------------------------------------
ReadDec		proc

		xor		ax,		ax

		test		cx,		not 0
		jnz		@@ReadD
		ret

@@ReadD:	mov		dx,		ax
		shl		ax,		02h
		add		ax,		dx
		shl		ax,		01h		; 10*ax = (4*ax+ax)*2

		xor		dx,		dx
		mov		dl, byte ptr	es:[di]
		inc		di
		sub		dl,		30h		; '0'
		add		ax,		dx
		loop		@@ReadD
		
		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Converts string of given length to number, interpreting it as written in hex.
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- string address
;		CX	- string length
; Exit:		AX	- converted number
;		ES:DI	- char after number end
;		CX	- 0
; Destroys:	DX
;----------------------------------------------------------------------------------------------------
ReadHex		proc
		xor		ax,		ax
		xor		dx,		dx

		test		cx,		not 0
		jnz		@@ReadH
		ret

@@ReadH:	shl		dx,		4h

		mov		al, byte ptr	es:[di]
		inc		di

		sub		ax,		61h	; 'a'
		jl		@@UpperCase

		add		ax,		0Ah
		jmp		@@LoopEndH

@@UpperCase:	add		ax,		20h	; 'A' - 'a'
		jl		@@Number

		add		ax,		0Ah
		jmp		@@LoopEndH

@@Number:	add		ax,		11h	; 'A' - '0'
@@LoopEndH:	add		dx,		ax

		loop		@@ReadH

		mov		ax,		dx
		ret
		endp
;----------------------------------------------------------------------------------------------------


.data

HexDigits	db 	'0123456789ABCDEF'

end