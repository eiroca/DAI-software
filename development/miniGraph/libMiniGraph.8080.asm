; Copyright (C) 2020-2021 Enrico Croce - AGPL >= 3.0
;
; This program is free software: you can redistribute it and/or modify it under the terms of the
; GNU Affero General Public License as published by the Free Software Foundation, either version 3
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
; even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
; Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License along with this program.
; If not, see <http://www.gnu.org/licenses/>.
;
;-------------------------------------------------------------------------------
; This utility provides a fast drawing facility applicable for each mode except
; mode 0.
;
;-------------------------------------------------------------------------------
; compile with RetroAssembler
; Tab Size = 10

.target	"8080"

.data
curCol	.byte	0

.lib

.macro DoDraw(addr, saveReg=0)
.if saveReg != 0
	pushRegs()
.endif
	lxi	H, addr
	call	DrawGraphic
.if saveReg != 0
	popRegs()
.endif
.endmacro

GC_STOP	.equ	$FF
GC_CALL	.equ	$00
GC_SETCOL	.equ	$01
GC_SETOFF	.equ	$02
GC_MOVOFF	.equ	$03
GC_MOVETO	.equ	$04
GC_LINETO	.equ	$05
GC_DOT	.equ	$06
GC_LINE	.equ	$07
GC_BOX	.equ	$08

numCmd	.equ	9
cmdTable
	.word	GraphCall
	.word	GraphSetColor
	.word	GraphSetOffset
	.word	GraphMoveOffset
	.word	GraphMoveTo
	.word	GraphLineTo
	.word	GraphDOT
	.word	GraphLine
	.word	GraphBox

.macro gc_END()
	.byte	GC_STOP
.endmacro

.macro gc_call(addr)
	.byte	GC_CALL
	.word	addr
.endmacro

.macro gc_SetColor(col)
	.byte	GC_SETCOL
	.byte	col
.endmacro

.macro gc_SetOffset(xOff, yOff)
	.byte	GC_SETOFF
	.word	xOff
	.byte	yOff
.endmacro

.macro gc_MoveOffset(deltaX, deltaY)
	.byte	GC_MOVOFF
	.word	deltaX
	.byte	deltaY
.endmacro

.macro gc_MoveTo(X, Y)
	.byte	GC_MOVETO
	.word	X
	.byte	Y
.endmacro

.macro gc_LineTo(X, Y)
	.byte	GC_LINETO
	.word	X
	.byte	Y
.endmacro

.macro gc_DOT(X, Y)
	.byte	GC_DOT
	.word	X
	.byte	Y
.endmacro

.macro gc_Line(X1, Y1, X2, Y2)
	.byte	GC_LINE
	.word	X1
	.byte	Y1
	.word	X2
	.byte	Y2
.endmacro

.macro gc_Box(X1, Y1, X2, Y2)
	.byte	GC_BOX
	.word	X1
	.byte	Y1
	.word	X2
	.byte	Y2
.endmacro

; Draw Command pointed by HL
DrawGraphic
@CmdLoop	mov	A, M	; Read Command
	inx	H
	cpi	GC_STOP
	rz
	cpi	numCmd
	jc	@Ok
	mvi	A, $01
	jmp	ErrorExit
@Ok	rlc		; A = A * 2
	lxi	D, cmdTable
	add	E	; A = A+E
          mov	E, A	; E = A+E
          adc	D	; A = A+E+D+carry
          sub	E	; A = D+carry
          mov	D, A	; D = D+carry
	ldax 	D
	sta	@jumpOp+1
	inx	D
	ldax 	D
	sta	@jumpOp+2
@jumpOp	call	$0000
	jmp	@CmdLoop

ErrorPrm	mvi	A, $02
ErrorFnc	pop	H
ErrorExit	stc
	ret

;load / keep current X,Y position (Self changing code)
LoadCurPos
xPosL	mvi	L, $00
xPosH	mvi	H, $00
yPos	mvi	C, $00
	ret

;load / keep current X,Y offset (Self changing code)
LoadOffset
xOffL	mvi	E, $00
xOffH	mvi	D, $00
yOff	mvi	B, $00
	ret

; Recursive Draw.
;  DrawGraphic HL<-(HL)
GraphCall
	mov	E, M
	inx	H
	mov	D, M
	inx	H
	push	H
	mov	H, D
	mov	L, E
	call	DrawGraphic
	pop	H
	rnc		; No Errors -> return
	jmp	ErrorFnc

;Set current color
; curCol <- (HL)
GraphSetColor
	mov	A, M
	inx	H
	cpi	$10
	jnc	ErrorPrm
	sta	curCol
	ret

;Set Offsets
; xOffset <- (HL)
; yOffset <- (HL)
GraphSetOffset
	mov	A, M
	sta	xOffL+1
	inx	H
	mov	A, M
	sta	xOffH+1
	inx	H
	mov	A, M
	sta	yOff+1
	inx	H
	ret

;Move Offsets
; xOffset <- xOffset + (HL)
; yOffset <- yOffset + (HL)
GraphMoveOffset
	call	LoadOffset
	; X
	mov	A, M
	inx	H
	add	E
	sta	xOffL+1
	mov	A, M
	inx	H
	adc	D
	sta	xOffH+1
	; Y
	mov	A, M
	inx	H
	add	B
	sta	yOff+1
	ret

;Move Current Position
; xPos <- xOffset + (HL)
; yPos <- yOffset + (HL)
GraphMoveTo
	call	LoadOffset
	;  xPos <- DE + (HL)
	mov	A, M
	inx	H
	add	E
	sta	xPosL+1
	mov	A, M
	inx	H
	adc	D
	sta	xPosH+1
	; yPos <- B + (HL)
	mov	A, M
	inx	H
	add	B
	sta	yPos+1
	ret
; Draw Line from current position
GraphLineTo
	xchg
	call	LoadCurPos
	push	H
	mov	A, C
	push	PSW
	xchg
	call	GraphMoveTo
	pop	PSW
	mov	B, A
	pop	D
	push	H
	call	LoadCurPos
	lda	curCol
	DAI_ROMCall(5, $21)
	pop	H
	rnc		; No Error
	jmp	ErrorFnc

; Calc Current Position
; DE <- xOffset + (HL)
; B <- yOffset + (HL)
CalcPosition
	call	LoadOffset
	;  DE <- DE + (HL)
	mov	A, M
	inx	H
	add	E
	mov	E, A
	mov	A, M
	inx	H
	adc	D
	mov	D, A
	; yPos <- B + (HL)
	mov	A, M
	inx	H
	add	B
	mov	B, A
	ret

; Plot Line (A=$21) / Box (A=$24)
PlotIT	sta	@Action+1
	call	CalcPosition
	push	D
	mov	A, B
	push	PSW
	call	GraphMoveTo
	pop	PSW
	mov	B, A
	pop	D
	push	H
	call	LoadCurPos
	lda	curCol
@Action	DAI_ROMCall(5, $21)
	pop	H
	rnc		; No Error
	jmp	ErrorFnc


;Plot a DOT
; xPos <- xOffset + (HL)
; yPos <- yOffset + (HL)
GraphDOT
	call	GraphMoveTo
	push	H
	call	LoadCurPos
	lda	curCol
	DAI_ROMCall(5, $1E)
	pop	H
	rnc		; No Error
	jmp	ErrorFnc

;Plot a Line
GraphLine
	mvi	A, $21
	jmp	PlotIT

;Plot a solid rectangle
; xPos <- xOffset + (HL)
; yPos <- yOffset + (HL)
GraphBox
	mvi	A, $24
	jmp	PlotIT
