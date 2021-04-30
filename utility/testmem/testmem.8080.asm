;******************************************************************************
;
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
;******************************************************************************
;
; Improved version of http://bruno.vivien.pagesperso-orange.fr/DAI/reparation/testmem.htm
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
Main	App_Init()
	Text_Home()
	Text_Print(WelcmMsg1)
	Text_Print(WelcmMsg2)
	lhld	VRAMPTR
	shld	MemEnd
	call	TestMem
	App_Exit(0)

TestMem	di
	Text_Print(StartMsg)
	mvi	B, $00
; Check memory value in B
@Check	lhld 	MemEnd
	xchg
	lhld	MemStart
@loop	mov	A, B
	; Write 1x Read 3x  Check a^a^a^a=0
	mov	M, A
	xra	M
	xra	M
	xra	M
	jz	@Next
	; Memory Error
	push	H
	Text_NL()
	Text_Print(ErrorMsg)
	pop	H
	Text_PrintHex4()
	Text_NL()
	jmp	@End
@Next	cmp_DH()
	inx	H
	jnz	@loop
	mov	A, B
	ani	$0F
	cpi	$00
	jnz 	@SkipDot
	Text_PrintChar('.')
@SkipDot	inr	B
	jnz	@Check
	; End of Test (OK)
	Text_NL()
	Text_Print(TestOKMsg)
@End	ei
	ret

.data
WelcmMsg1	Text_MSG("DAI memory checker (2021)")
WelcmMsg2	Text_MSG("This program is free software under AGPL v3")
StartMsg	Text_STR("Checking: ")
ErrorMsg	Text_STR("Memory Error @#")
TestOKMsg	Text_MSG("Memory is OK!")

MemStart	.word	EndOfProg
MemEnd	.word	0

EndOfProg	NOP
