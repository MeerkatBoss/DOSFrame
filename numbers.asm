;====================================================================================================
; stdio.asm
;====================================================================================================
.186
.model tiny
.code
include stdmacro.asm

locals @@

public PrintHex, PrintBin, PrintDec, ReadDec, ReadHex

;----------------------------------------------------------------------------------------------------
; Prints number in hex
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- video segment address to print to
;		AH	- symbol attribute
;		BX	- number to print
; Exit:		None
; Destr:	AL, BX, SI, DI, DF
;----------------------------------------------------------------------------------------------------
PrintHex	proc

		add		di,		06h
		std

@@PrintLoop:	mov		si,		bx	
		and		si,		0Fh
		mov		al,    byte ptr	[HexDigits+si]

		stosw
		
		shr		bx,		4h
		jnz		@@PrintLoop
		
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
; Destr:	AL, BX, DX, DI, DF
;----------------------------------------------------------------------------------------------------
PrintBin	proc

		add		di,		1Eh
		std

@@PrintLoop:	mov		dx,		bx	
		and		dx,		01h
		add		dx,		30h	; '0'
		mov		al,		dl

		stosw
		
		shr		bx,		1h
		jnz		@@PrintLoop
		
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

		xchg		ax,		bx ; TODO: Consider allowing user to make this decision himself 

		add		di,		08h

		mov		cx,		0Ah

@@PrintLoop:	xor		dx,		dx
	
		div 		cx
		add		dl,		30h	; '0'
		mov		bl,		dl

		mov		es:[di],	bx
		sub		di,		02h

		test		ax,		not 0
		jnz		@@PrintLoop

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
		jnz		@@ReadLoop
		ret

@@ReadLoop:	mov		dx,		ax
		shl		ax,		02h
		add		ax,		dx
		shl		ax,		01h		; 10*ax = (4*ax+ax)*2

		xor		dx,		dx
		mov		dl, byte ptr	es:[di]
		inc		di
		sub		dl,		30h		; '0'
		add		ax,		dx
		loop		@@ReadLoop
		
		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Converts string of given length to number, interpreting it as written in hex.
;----------------------------------------------------------------------------------------------------
; Entry:	ES:SI	- string address
;		CX	- string length
; Exit:		AX	- converted number
;		ES:SI	- char after number end
;		CX	- 0
; Destroys:	DX
;----------------------------------------------------------------------------------------------------
ReadHex		proc
		xor		ax,		ax
		xor		dx,		dx

		test		cx,		cx
		jz		@@ProcEnd

@@ReadLoop:	shl		dx,		4h	; * 16

		lodsb
;		mov		al, byte ptr	es:[si]
;		inc		di

; @@LowerCase:
		sub		ax,		61h	; 'a'
		jl		@@UpperCase

		add		ax,		0Ah
		jmp		@@LoopEnd

@@UpperCase:	add		ax,		20h	; 'A' - 'a'
		jl		@@Number

		add		ax,		0Ah
		jmp		@@LoopEnd

@@Number:	add		ax,		11h	; 'A' - '0'

@@LoopEnd:	add		dx,		ax
		loop		@@ReadLoop

		mov		ax,		dx
@@ProcEnd:		ret
		endp
;----------------------------------------------------------------------------------------------------


.data

HexDigits	db 	'0123456789ABCDEF'

end