;====================================================================================================
; box.asm
;====================================================================================================
.186
.model tiny
.code

include stdmacro.asm

include vidmacro.asm

public MakeBox, PrintRow

;----------------------------------------------------------------------------------------------------
; Prints box using top-left corner offset and dimensions.
; Border is printed OUTSIDE of given rectangle, so caller must ensure it will not be outside of
; video buffer.
;
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- top-left corner address in memory
;		DS:SI	- start of string style description
;		BH	- box width
;		BL	- box height
;		DH	- fill screen attribute
;		DL	- border attribute
; Exit:		None
; Destroys:	AX, CX, DX, DI, DF
;----------------------------------------------------------------------------------------------------
MakeBox		proc
		push		di				; save di before destroying function

		push		dx
		mov		ax,		0FFFFh		; (-1, -1)
		.get_offset					; offset di a bit
		pop		dx

		mov		ah,		dl
		mov		al, byte ptr	[si]		; corner character
		stosw

		mov		al, byte ptr	[si+1]		; top character
		xor		cx,		cx
		mov		cl,		bh
		call		PrintRow

		mov		al, byte ptr	[si+2]		; corner character
		stosw

		pop		di

		test		bl,		not 0
		jz		@@BottomBorder			; nothing to print inside

		mov		cl,		bl		; no need to xor cx, as it's 0 after PrintRow

@@PrintInside:	push		cx	; save cx		;<--------------------------------------\
		push		di	; save di		;					|
								;					|
		mov		al, byte ptr	[si+3]		; border char				|
		mov		es:[di-2],	ax		; 					|
								;					|
		mov		al, byte ptr	[si+4]		; fill char				|
		mov		ah,		dh		; fill color				|
		xor		cx,		cx		;					|
		mov		cl,		bh		;					|
		call		PrintRow			; fill box				|
		mov		al, byte ptr	[si+5]		; border char				|
		mov		ah,		dl		; border color				|
		mov		es:[di],	ax		;					|
								;					|
		pop		di				;					|
		add		di,		2*SCRWIDTH	; next row				|
								;					|
		pop		cx				;					|
		loop		@@PrintInside			;<--------------------------------------/


@@BottomBorder: mov		al, byte ptr	[si+6]		; corner char
		mov		es:[di-2],	ax

		mov		al, byte ptr	[si+7]		; bottom char
		mov		cl,		bh		; cx alrady 0 after loop
		call		PrintRow

		mov		al, byte ptr	[si+8]		; corner char
		stosw

		ret
		endp
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Prints row of characters of given length
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- destination address
;		AH	- screen attribute
;		AL	- character
;		CX	- character count
; Exit:		DI = DI + 2*CX, CX = 0
; Destroys:	DF
;----------------------------------------------------------------------------------------------------
PrintRow	proc
		cld

		test		cx,		cx
		jz		@@SkipPrint                ; TODO:!

		rep		stosw

@@SkipPrint:	ret
		endp
;----------------------------------------------------------------------------------------------------
end