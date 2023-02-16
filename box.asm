;----------------------------------------------------------------------------------------------------
; Prints box using top-left corner offset and dimensions.
; Border is printed OUTSIDE of given rectangle, so caller must ensure it will not be outside of
; video buffer.
;
;----------------------------------------------------------------------------------------------------
; Entry:	ES:DI	- top-left corner address in memory
;		BH	- box width
;		BL	- box height
;		CH	- border screen attribute
;		CL	- border character
;		DH	- fill screen attribute
;		DL	- fill character
; Exit:		None
; Destroys:	AX, CX, DX, DI, DF
;----------------------------------------------------------------------------------------------------
MakeBox		proc
		push		dx
		push		di				; save di before destroying function

		mov		ax,		0FFFFh		; (-1, -1)
		.get_offset					; offset di a bit

		mov		ax,		cx		; border character
		xor		cx,		cx
		mov		cl,		bh
		add		cx,		2h		; border is a bit longer than box
		call		PrintRow

		pop		di
		pop		dx

		test		bl,		not 0
		jz		@@BottomBorder			; nothing to print inside

		xor		ax,		dx		; exchange ax and dx
		xor		dx,		ax		; dx holds border character and attribute
		xor		ax,		dx		; ax holds fill   character and attribute

		mov		cl,		bl		; no need to xor cx, as it's 0 after PrintRow

@@PrintInside:	push		cx	; save cx		;<--------------------------------------\
		push		di	; save di		;					|
								;					|
		mov		es:[di-2],	dx		; print border char			|
		xor		cx,		cx		;					|
		mov		cl,		bh		;					|
		call		PrintRow; print box fill	;					|
		mov		es:[di],	dx		;					|
								;					|
		pop		di				;					|
		add		di,		2*SCRWIDTH	; next row				|
								;					|
		pop		cx				;					|
		loop		@@PrintInside			;<--------------------------------------/

		mov		ax,		dx		; store border char in ax

@@BottomBorder:	mov		cl,		bh		; cx alrady 0 after loop
		add		cx,		2h		; border loger than box
		sub		di,		2h		; border to the left of the box

		call		PrintRow

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

		test		cx,		not 0h
		jnz		@@Next
		ret

@@Next:		stosw
		loop		@@Next

		ret
		endp
;----------------------------------------------------------------------------------------------------