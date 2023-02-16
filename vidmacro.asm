VBUFSEGMENT	equ 0B800h
SCRWIDTH	equ 80d
SCRHEIGHT	equ 25d
VBUFSIZE	equ SCRHEIGHT * SCRWIDTH
SCRMID		equ VBUFSIZE/2

;----------------------------------------------------------------------------------------------------
; Stores VBUFSEGMENT into ES
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		ES = VBUFSEGMENT
; Destr:	BX
;----------------------------------------------------------------------------------------------------
.load_vbuf_es	macro x, y
		.do_nop
		
		mov		bx,		VBUFSEGMENT
		mov		es,		bx
		
		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Store x and y combined in AX register
;----------------------------------------------------------------------------------------------------
; Entry:	x, y
; Exit:		AH	= x
;		AL	= y
; Destroys:	None
;----------------------------------------------------------------------------------------------------
.load_xy	macro
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Offset position in video memory by x horizontally and by y vertically
;----------------------------------------------------------------------------------------------------
; Entry:	AH	- x offset 
;		AL	- y offset
;		DI	- initial offset in video memory
; Exit:		DI	- new offset in video memory
; Destroys:	AX, DX
;----------------------------------------------------------------------------------------------------
.get_offset	macro
		.do_nop

		push		ax

		shl		ax,		8h
		sar		ax,		8h		; fill sign bit

		mov		dx,		ax		; copy to dx

		shl		ax,		2h
		add		ax,		dx
		shl		ax,		5h		; ax*A0h = ax * 160 = (4*ax + ax)*32

		add		di,		ax		; adjust y-coordinate

		pop		ax

		sar		ax,		8h
		shl		ax,		1h
		add		di,		ax		; adjust x-coordinate

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------