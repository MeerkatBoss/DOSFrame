;====================================================================================================
; string.asm
;====================================================================================================
.186
.model tiny
.code
public	GetNextByte

extrn ReadHex:proc

;----------------------------------------------------------------------------------------------------
; Get first hex integer encountered in string
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- string start address
;		CX	- string length
; Exit:		ES:DI	- first not converted character
;		CX	- remaining string length
;		AL	- converted number
; Destroys:	DX
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

end
