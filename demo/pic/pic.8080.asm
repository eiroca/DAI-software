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
USE_ZX0	.equ	1

	.org	PROGSTART

Main	App_Init()
	Text_Home()
Copy	DAI_mode(6*2)
	.if USE_ZX0==1
	lxi	H, IMG_END - 1
	lxi	B, VRAM_END
	dzx0_back()
	.endif
	.if USE_ZX0==0
	lxi	H, IMG_END - 1
	lxi	D, VRAM_END
	lxi	B, IMG_END - IMG_START
	_LDDR()
	.endif
	Text_GetC()
	Text_Init()
	Text_Home()
	App_Exit(0)

.data
IMG_START
	.if USE_ZX0==1
	.incbin "image.zx0"
	.endif
	.if USE_ZX0==0
	.incbin "image.bin"
	.endif
IMG_END
