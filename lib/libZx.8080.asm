; Copyright (C) 2020-2021 Enrico Croce - BSD 3-Clause License
; Based on ZX0 z80 decoder by Einar Saukas - Copyright (c) 2021, Einar Saukas - All rights reserved.
; Based on ZX0 8080 decoder by Ivan Gorodetsky
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice, this
;   list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice,
;   this list of conditions and the following disclaimer in the documentation
;   and/or other materials provided with the distribution.
;
; 3. Neither the name of the copyright holder nor the names of its
;   contributors may be used to endorse or promote products derived from
;   this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.;
;
; -----------------------------------------------------------------------------
;
; compile with RetroAssembler
; Tab Size = 10
;
	.target	"8080"

.lib

.macro  NEXT_HL(backward)
.if backward == 1
	dcx	H
.endif
.if backward != 1
	inx	H
.endif
.endmacro

.macro  NEXT_BC(backward)
.if backward == 1
	dcx	B
.endif
.if backward != 1
	inx	B
.endif
.endmacro

.macro  NEXT_DE(backward)
.if backward == 1
	dcx	D
.endif
.if backward != 1
	inx	D
.endif
.endmacro

.macro dzx0_standard(backward)
.if BACKWARD == 1
 	lxi	D, 1
	push	D
	dcr	E
.endif
.if BACKWARD != 1
	lxi	D, $FFFF
	push	D
	inx	D
.endif
	mvi	A, $80
@literals
	call	@elias
	call	ldir
	add	A
	jc	@new_offset
	call	@elias
@copy
	xthl
	push	H
	dad	B
	call	ldir
	pop	H
	xthl
	add	A
	jnc	@literals
@new_offset
	call	@elias
.if BACKWARD == 1
	inx	SP
	inx	sp
	dcr	D
	rz
	dcr	E
	mov	D, E
.endif
.if BACKWARD != 1
	mov	D, A
	pop	PSW
	xra	A
	sub	E
	rz
	mov	E, D
	mov	D, A
	mov	A, E
.endif
	push	B
	mov	B, A
	mov	A, D
	rar
	mov	D, A
	mov	A, M
	rar
	mov	E, A
	mov	A, B
	pop	B
	NEXT_HL(backward)
.if BACKWARD == 1
	inx	D
.endif
	push	D
	lxi	D, 1
.if BACKWARD == 1
	cc	@elias_backtrack
.endif
.if BACKWARD != 1
	cnc	@elias_backtrack
.endif
	inx	D
	jmp	@copy
@elias
	inr	E
@elias_loop
	add	A
	jnz	@elias_skip
	mov	A, M
	NEXT_HL(backward)
	ral
@elias_skip
.if BACKWARD == 1
	rnc
.endif
.if BACKWARD != 1
	rc
.endif
@elias_backtrack
	xchg
	dad	H
	xchg
	add	A
	jnc	@elias_loop
	inr	E
	jmp	@elias_loop

ldir	push	PSW
@loop	mov	A, M
	stax	B
	NEXT_HL(backward)
	NEXT_BC(backward)
	dcx	D
	mov	A, D
	ora	E
	jnz	@loop
	pop	PSW
.endmacro

.macro dzx1_standard(backward)
.if BACKWARD == 1
	lxi	H, 1
.endif
.if BACKWARD != 1
	lxi H, $FFFF
.endif
	shld	zx1Offset
	mvi	A, $80
@literals
	call	@elias
	push	PSW
	dcx	H
	inr	L
@ldir1
	ldax	D
	stax	B
	NEXT_DE(backward)
	NEXT_BC(backward)
	dcr	L
	jnz	@ldir1
	xra	A
	ora	H
	jz	*+7
	dcr	H
	jmp	@ldir1
	pop	PSW
	add	A
	jc	@new_offset
	call	@elias
@copy
	push	D
	xchg
	lhld	zx1Offset
	dad	B
	push	PSW
	dcx	D
	inr	E
@ldir2
	mov	A, M
	stax	B
	NEXT_HL(backward)
	NEXT_BC(backward)
	dcr	E
	jnz	@ldir2
	xra	A
	ora	D
	jz	*+7
	dcr	D
	jmp	@ldir2
	pop	PSW
	xchg
	pop	D
	add	A
	jnc	@literals
@new_offset
.if BACKWARD == 1
	ora	A
.endif
.if BACKWARD != 1
	dcr	H
.endif
	push	PSW
	ldax	D
	NEXT_DE(backward)
	rar
	mov	L, A
	jnc	@msb_skip
	ldax	D
	NEXT_DE(backward)
.if BACKWARD == 1
	ora	A
	rar
	rar
	adc	A
.endif
.if BACKWARD != 1
	rar
	inr	A
.endif
	jz	@exit
	mov	H, A
.if BACKWARD == 1
	dcr	H
.endif
	mov	A, L
	ral
	mov	L, A
@msb_skip
	pop	PSW
.if BACKWARD == 1
	inr	L
.endif
	shld	zx1Offset
	call	@elias
	inx	H
	jmp	@copy
@elias
	lxi	H, 1
@elias_loop
	add	A
	rnc
	jnz	@elias_skip
	ldax	D
	NEXT_DE(backward)
	ral
	rnc
@elias_skip
	dad	H
	add	A
	jnc	@elias_loop
	inr	L
	jmp	@elias_loop
@exit
	pop	PSW
.endmacro()

.macro dzx2_standard(backward, IGNORE_DEFAULT=0, SKIP_INCREMENT=0, LIMIT_LENGTH=0)
.if BACKWARD == 1
	.if IGNORE_DEFAULT == 1
	mvi	D, 0
	.endif
	.if IGNORE_DEFAULT != 1
	lxi	D, 1
	.endif
.endif
.if BACKWARD != 1
	.if IGNORE_DEFAULT == 1
	mvi	D, $FF
	.endif
	.if IGNORE_DEFAULT != 1
	lxi	D, $FFFF
	.endif
.endif
	push	D
	mvi	A, $80
@literals
	call	@elias
	call	ldir
	add	A
	jc	@new_offset
@reuse
	call	@elias
@copy
	xthl
	push	H
	dad	B
	call	ldir
	pop	H
	xthl
	add	A
	jnc	@literals
@new_offset
	pop	D
	mov	E, M
	inr	E
	rz
	NEXT_HL(backward)
	push	D
.if SKIP_INCREMENT == 1
	jmp	@reuse
.endif
.if SKIP_INCREMENT != 1
	call	@elias
.if LIMIT_LENGTH == 1
	inr	D
.endif
.if LIMIT_LENGTH != 1
	inx	D
.endif
	jmp	@copy
.endif
@elias
.if LIMIT_LENGTH == 1
	mvi	D, 1
.endif
.if LIMIT_LENGTH != 1
	.if BACKWARD == 1
	mvi	E, 1
	.endif
	.if BACKWARD != 1
	lxi	D, 1
	.endif
.endif
@elias_loop
	add	A
	jnz	@elias_skip
	mov	A, M
	NEXT_HL(backward)
	ral
@elias_skip
	rnc
.if LIMIT_LENGTH == 1
	mov	E, A
	xchg
	dad	H
	xchg
	mov	A, E
	jmp	@elias_loop
ldir
	mov	E, A
@loop
	mov	A, M
	stax	B
	NEXT_HL(backward)
	NEXT_BC(backward)
	dcr	D
	jnz	@loop
	mov	A, E
.endif
.if LIMIT_LENGTH != 1
	xchg
	dad	H
	xchg
	add	A
	jnc	@elias_loop
	inr	E
	jmp	@elias_loop
ldir
	push	PSW
@loop
	mov	A, M
	stax	B
	NEXT_HL(backward)
	NEXT_BC(backward)
	dcx	D
	mov	A, E
	ora	D
	jnz	@loop
	pop	PSW
.endif
	ret
.endmacro

; forward decompressing
;  HL: source address (compressed data)
;  BC: destination address (decompressing)
.function dzx0()
	dzx0_standard(0)
.endfunction

; backward decompressing
;  HL: last source address (compressed data)
;  BC: last destination address (decompressing)
.function dzx0_back()
	dzx0_standard(1)
.endfunction

.data
zx1Offset	.word	0

.lib

; Parameters (forward):
;   DE: source address (compressed data)
;   BC: destination address (decompressing)
.function dzx1()
	dzx1_standard(0)
.endfunction

; Parameters (backward):
;   DE: last source address (compressed data)
;   BC: last destination address (decompressing)
.function dzx1_back()
	dzx1_standard(1)
.endfunction

; forward decompressing
;  HL: source address (compressed data)
;  BC: destination address (decompressing)
.function dzx2()
	dzx2_standard(0)
.endfunction

; backward decompressing
;  HL: last source address (compressed data)
;  BC: last destination address (decompressing)
.function dzx2_back()
	dzx2_standard(1)
.endfunction
