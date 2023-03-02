;====================================================================================================
; stdmacro.asm
;====================================================================================================

;----------------------------------------------------------------------------------------------------
; Does NOP or does nothing (for debug purposes)
;----------------------------------------------------------------------------------------------------
; Entry:	None
; Exit:		None
; Destr:	None	; TODO: .ENTER?? .DEBUG_NOP .DEBUG_MARKER
;----------------------------------------------------------------------------------------------------
.do_nop		macro
		nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Exits program to DOS
;----------------------------------------------------------------------------------------------------
; Entry: AL or <code> - exit code
; Exit:  N/A
; Destr: Everything
;----------------------------------------------------------------------------------------------------
.exit_program  	macro code
		.do_nop

	ifnb <code>
		mov		ax,		4C00h or code
	else
		mov		ah,		4C
	endif
	
		int		21h

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Prints string to console
;----------------------------------------------------------------------------------------------------
; Entry:	`string` - variable name 
; Exit:		None
; Destroys:	AX
;----------------------------------------------------------------------------------------------------
.print_str	macro string
		.do_nop

		mov		ah,		09h	
		mov		dx,		offset string
		int		21h

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Read string from stdin to specified buffer
;----------------------------------------------------------------------------------------------------
; Entry:	buffer	- buffer name
;		buflen	- buffer length
; Exit:		AX	- number of characters read
;		BX	- 0
;		CX	- buffer length
;		DX	- buffer offset
; Destroys:	None
;----------------------------------------------------------------------------------------------------
.scan_str	macro buffer, buflen
		.do_nop

		mov		ah,		3Fh
		xor		bx,		bx
		mov		cx,		buflen
		mov		dx, offset	buffer
		int		21h

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Skips all spaces (20h) in string
;----------------------------------------------------------------------------------------------------
; Entry:	ES:SI	- string offset
;		CX	- maximum number of characters to skip
; Exit:		ES:SI	- offset of first non-whitespace character
;		AL	- 20h
;		CX	- remaining characters in string
; Destroys:	AL
;----------------------------------------------------------------------------------------------------
.skip_spaces	macro
		local @@End

		.do_nop

		xchg		si,		di

		mov		al,		20h	; ' '
		repz		scasb

;		test		cx,		cx
;		jz		@@End
		dec		di
		inc		cx

		
@@End:		xchg		si,		di

		.do_nop
		endm
;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
; Get first byte (1 or 2 hex digits) from string, skipping whitespaces
;----------------------------------------------------------------------------------------------------
; Entry:	ES:SI	- string start address
;		CX	- string length
; Exit:		ES:SI	- first not converted character
;		CX	- remaining string length
;		AL	- converted number
; Destroys:	AH, BX, DX
;----------------------------------------------------------------------------------------------------
.get_next_byte	macro
		local @@End

		.do_nop

		xor		ax,		ax	

		.skip_spaces

		test		cx,		cx
		jz		@@End
		
		mov		bx,		cx

		mov		cx,		2h
		xchg		si,		di
		repnz		scasb			; until two symbols or space
		xchg		si,		di

		sub		cx,		2h
		neg		cx			; -(cx - 2) = 2 - cx (safe negation of small values)
		sub		bx,		cx	; remaining length in bx
		sub		si,		cx

		call		ReadHex

		mov		cx,		bx	; remaining length

@@End:		.do_nop

		endm
;----------------------------------------------------------------------------------------------------



