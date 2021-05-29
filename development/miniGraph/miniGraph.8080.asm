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

.include "libMiniGraph.8080.asm"

.code
	.org	PROGSTART
Main	App_Init()
	DAI_mode(8)	; Hires 16 col

Run	DoDraw(demo)
	push	PSW
	Text_GetC()
	Text_Init()
	Text_Home()
	pop	PSW
	jnc	@Exit
	DAI_printC('E')
	DAI_printHEXinA()
@Exit	App_Exit(0)

.data
demo
	gc_SetColor($E)
	gc_SetOffset(100, 100)
	gc_call(drawBox)
	gc_SetColor($F)
	gc_call(drawPlus)
	gc_SetOffset(50, 100)
	gc_call(drawPlus)
	gc_MoveOffset(100, 0)
	gc_call(drawPlus)
	gc_SetColor($6)
	gc_SetOffset(100,40)
	gc_call(drawBar)
	gc_SetColor($A)
	gc_MoveOffset(0, 10)
	gc_call(drawShape)
	gc_END()

drawPlus
	gc_DOT(0, 0)
	gc_DOT(1, 0)
	gc_DOT(-1, 0)
	gc_DOT(0, -1)
	gc_DOT(0, 1)
	gc_END()

drawBox
	gc_LINE(-5,-5, 5,-5)
	gc_LINE( 5,-5, 5, 5)
	gc_LINE( 5, 5,-5, 5)
	gc_LINE(-5, 5,-5,-5)
	gc_END()

drawBar
	gc_BOX(-10,-5,10, 5)
	gc_END()

drawShape
	gc_MoveTo(0,0)
	gc_LineTo(0,8)
	gc_LineTo(-4,12)
	gc_LineTo(0,16)
	gc_LineTo(4,12)
	gc_LineTo(0,8)
	gc_END()
