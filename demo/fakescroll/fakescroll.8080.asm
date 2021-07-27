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
;
; compile with RetroAssembler
; Tab Size = 10

.target	"8080"
.format	"prg"
.setting "OmitUnusedFunctions", true

.include "../../lib/libConst.8080.asm"
.include "../../lib/DAI/libDAI.8080.asm"
.include "../../lib/DAI/libDAIext.8080.asm"
.include "../../lib/libApp.8080.asm"
.include "../../lib/libZx.8080.asm"

.code
	.org	PROGSTART

.macro zxCopy(srcAddr, dstAddr = VRAM_END)
	lxi	D, srcAddr
	lxi	B, dstAddr
	dzx1_back()
.endmacro

.macro wait(ticks=1)
.if ticks < 256
	mvi	A, ticks
	Delay()
.endif
.if ticks >= 256
	lxi	H, ticks
	LongDelay()
.endif
.endmacro

Main	App_Init()
	Text_Home()
	DAI_mode(10)
	ClockInterrupt_Init()

	; Blank Screen
	VSync()
	zxCopy(Frame01E-1)
	; Scroll
	mvi	C, 15
@Loop
	mvi	B, 20
	lxi	D, CWList1
	DecNextRows()
	dcr	C
	jnz	@Loop

EndDemo	ClockInterrupt_Done()
	Text_GetC()
	Text_Init()
	Text_Home()
	App_Exit(0)

.function DecNextRows()
@Loop
	VSync()
	ldax	D
	mov	L, A
	inx	D
	ldax	D
	mov	H, A
	inx	D
	dcr	M
	dcr	B
	jnz	@Loop
.endfunction

; Wait HL * 20 ms
; Input: HL ticks
; Output: A = 0
.function LongDelay()
	shld 	ClockTick
@Loop	lhld	ClockTick
	mov	A, L
	ora	H
	jz	@Done
	nop
	nop
	jmp	@Loop
@Done
.endfunction

; Wait A * 20 ms
; Input: A ticks
; Output: A = 0
.function Delay()
	sta 	ClockTick
@Loop	lda	ClockTick
	ora	A
	jz	@Done
	nop
	nop
	jmp	@Loop
@Done
.endfunction

.function VSync()
	xra	A
	sta	ClockInt
@Loop	lda	ClockInt
	ora 	A
	jz	@Loop
.endfunction

; Called every 1/50 of second
; Decrements ClockTick if > 0
ClockInterrupt
	push	PSW
	push	B
	push	D

@Core	mvi	A, $01
	sta	ClockInt
	lhld	ClockTick
	mov	A, L
	ora	H
	jz	@Done
	dcx	H
	shld	ClockTick
@Done
	ei
	pop	D
	pop	B
	pop	PSW
	pop	H
	ret

.function ClockInterrupt_Init()
	lhld	$0070
	shld	OldClkInt
	lxi	H, ClockInterrupt
	shld	$0070
	call	$D9DB	; Enable Clock Interrupt
.endfunction

.function ClockInterrupt_Done()
	lhld	OldClkInt
	shld	$0070
.endfunction


.data
OldClkInt .word	0	; Old Clock Interrupt handler
ClockTick	.word	0
ClockInt	.byte	0

CWList1
	.word $BFFF
	.word $BFFB
	.word $BFF7
	.word $BFF3
	.word $BFEF
	.word $BFEB
	.word $BFE7
	.word $BFE3
	.word $BFDF
	.word $BFDB
	.word $BFD7
	.word $BFD3
	.word $BFCF
	.word $BFCB
	.word $BFC7
	.word $BFC3
	.word $BFBF
	.word $BFBB
	.word $BFB7
	.word $BFB3

Frame01S	.incbin "image.zx1"
Frame01E

THE_END	.ascii	"The end"
