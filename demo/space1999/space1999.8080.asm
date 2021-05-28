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

.code
	.org	PROGSTART

.macro zx0Copy(srcAddr, dstAddr = VRAM_END)
	lxi	H, srcAddr
	lxi	B, dstAddr
	dzx0_back()
.endmacro

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

.macro separate(addr, mode=1)
	lxi	H, addr
	.if mode==1
	inr	M
	.endif
	.if mode==-1
	dcr	M
	.endif
	wait(1)
.endmacro


Main	App_Init()
	Text_Home()
	DAI_mode(6*2)
	ClockInterrupt_Init()

	; Blank Screen
	zxCopy(Blank_E - 1)

Intro
	zxCopy(Frame01E - 1, $6323 + 14444)
	wait(15)
	zxCopy(Frame02E - 1, $6323 + 17588)
	wait(15)
	zxCopy(Frame03E - 1, $6323 + 17588)
	wait(15)
	zxCopy(Frame04E - 1, $6323 + 23646)
	wait(50)

Separazione
	; Blank Screen
	zxCopy(Blank_E - 1)
	zxCopy(FrameSepE - 1)
	mvi	C, $0F
	;Separazione...
@Loop
	separate (RowDec00, -1)
	mvi	B, 5
	lxi	D, CWList1
	DecNextRows()
	separate (RowDec01, -1)
	mvi	B, 5
	DecNextRows()
	separate (RowDec02, -1)
	mvi	B, 5
	DecNextRows()
	dcr	C
	jnz	@Loop

Closing
	; Blank Screen
	zxCopy(Blank_E - 1)
	zxCopy(FrameFinE - 1)

EndDemo	ClockInterrupt_Done()
	Text_GetC()
	Text_Init()
	Text_Home()
	App_Exit(0)

.function DecNextRows()
@Loop	ldax	D
	mov	L, A
	inx	D
	ldax	D
	mov	H, A
	inx	D
	inr	M
	wait(2)
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

;Set a Hires Screen filled with DE
.function ClearVRAM()
	lxi	B, 264
	lxi	H, VRAM_END
@Loop	mvi	A, 44
	; Control word
	mvi	M, $A0	; 16col 352x1 rows
	dcx	H
	mvi	M, $40	;
	dcx	H
	; Graphic Data
@RowLoop	mov	M, D	; all Background
	dcx	H
	mov	M, E	; Color
	dcx	H
	;
	dcr	A
	jnz	@RowLoop
	dcx	B
	mov	A, B
	ora	C
	jnz	@Loop
	; Footer
	mvi	A, 4
@Footer	mvi	M, $AF	; 16col 352x16 rows
	dcx	H
	mvi	M, $00	; fill
	dcx	H
	mov	M, D	; all Background
	dcx	H
	mov	M, E	; Color
	dcx	H
	dcr	A
	jnz	@Footer
.endfunction

.data
OldClkInt .word	0	; Old Clock Interrupt handler
ClockTick	.word	0
ClockInt	.byte	0

.data
RowDec00	.equ	$BFFF
RowDec01	.equ	$BFFB
RowDec02	.equ	$BFF7

CWList1
	.word $B2F1
	.word $B2ED
	.word $B2E9
	.word $B2E5
	.word $B2E1
	.word $B2DD
	.word $B2D9
	.word $B2D5
	.word $B2D1
	.word $B2CD
	.word $B2C9
	.word $B2C5
	.word $B2C1
	.word $B2BD
	.word $B2B9
	.word $B2B5
	.word $B2B1
	.word $B2AD
	.word $B2A9
	.word $B2A5
	.word $B2A1
	.word $B29D
	.word $B299
	.word $B295
	.word $B291
	.word $B28D
	.word $B289
	.word $B285
	.word $B281
	.word $B27D
	.word $B279
	.word $B275
	.word $B271
	.word $B26D
	.word $B269
	.word $B265
	.word $B261
	.word $B25D
	.word $B259
	.word $B255
	.word $B251
	.word $B24D
	.word $B249
	.word $B245
	.word $B241
	.word $B23D
	.word $B239
	.word $B235
	.word $B231
	.word $B22D
	.word $B229
	.word $B225
	.word $B221

Blank_S	.incbin "res/frame.000.bin.zx1"
Blank_E

Frame01S	.incbin "res/frame.001.bin.zx1"
Frame01E
Frame02S	.incbin "res/frame.002.bin.zx1"
Frame02E
Frame03S	.incbin "res/frame.003.bin.zx1"
Frame03E
Frame04S	.incbin "res/frame.004.bin.zx1"
Frame04E

FrameSepS	.incbin "res/frame.005.bin.zx1"
FrameSepE

FrameFinS	.incbin "res/frame.006.bin.zx1"
FrameFinE

THE_END	.ascii	"The end"
