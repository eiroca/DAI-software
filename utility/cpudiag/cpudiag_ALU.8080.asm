;***********************************************************************
; MICROCOSM ASSOCIATES  8080/8085 CPU DIAGNOSTIC VERSION 1.0  (C) 1980
;***********************************************************************
;
;DONATED TO THE "SIG/M" CP/M USER'S GROUP BY:
;KELLY SMITH, MICROCOSM ASSOCIATES
;3055 WACO AVENUE
;SIMI VALLEY, CALIFORNIA, 93065
;(805) 527-9321 (MODEM, CP/M-NET (TM))
;(805) 527-0518 (VERBAL)
;
.data
TempP	.word	Temp0	;Pointer used to test "LHLD","SHLD", AND "LDAX" instructions
Temp0	.ds	1	;Temporary storage
Temp1	.ds	1	;Temporary storage
Temp2	.ds	1	;Temporary storage
Temp3	.ds	1	;Temporary storage
Temp4	.ds	1	;Temporary storage
TempStck	.ds	2	;Temporary storage

.code
@Start	.equ	*
	XRA	A
	MVI	B,$01
	MVI	C,$03
	MVI	D,$07
	MVI	E,$0F
	MVI	H,$1F
	MVI	L,$3F
	ADD	B
	ADD	C
	ADD	D
	ADD	E
	ADD	H
	ADD	L
	ADD	A
	CPI	$F0
	CNZ	CPUError	;TEST "ADD" B,C,D,E,H,L,A
	SUB	B
	SUB	C
	SUB	D
	SUB	E
	SUB	H
	SUB	L
	CPI	$78
	CNZ	CPUError	;TEST "SUB" B,C,D,E,H,L
	SUB	A
	CNZ	CPUError	;TEST "SUB" A
	MVI	A,$80
	ADD	A
	MVI	B,$01
	MVI	C,$02
	MVI	D,$03
	MVI	E,$04
	MVI	H,$05
	MVI	L,$06
	ADC	B
	MVI	B,$80
	ADD	B
	ADD	B
	ADC	C
	ADD	B
	ADD	B
	ADC	D
	ADD	B
	ADD	B
	ADC	E
	ADD	B
	ADD	B
	ADC	H
	ADD	B
	ADD	B
	ADC	L
	ADD	B
	ADD	B
	ADC	A
	CPI	$37
	CNZ	CPUError	;TEST "ADC" B,C,D,E,H,L,A
	MVI	A,$80
	ADD	A
	MVI	B,$01
	SBB	B
	MVI	B,$FF
	ADD	B
	SBB	C
	ADD	B
	SBB	D
	ADD	B
	SBB	E
	ADD	B
	SBB	H
	ADD	B
	SBB	L
	CPI	$E0
	CNZ	CPUError	;TEST "SBB" B,C,D,E,H,L
	MVI	A,$80
	ADD	A
	SBB	A
	CPI	$FF
	CNZ	CPUError	;TEST "SBB" A
	MVI	A,$FF
	MVI	B,$FE
	MVI	C,$FC
	MVI	D,$EF
	MVI	E,$7F
	MVI	H,$F4
	MVI	L,$BF
	ANA	A
	ANA	C
	ANA	D
	ANA	E
	ANA	H
	ANA	L
	ANA	A
	CPI	$24
	CNZ	CPUError	;TEST "ANA" B,C,D,E,H,L,A
	XRA	A
	MVI	B,$01
	MVI	C,$02
	MVI	D,$04
	MVI	E,$08
	MVI	H,$10
	MVI	L,$20
	ORA	B
	ORA	C
	ORA	D
	ORA	E
	ORA	H
	ORA	L
	ORA	A
	CPI	$3F
	CNZ	CPUError	;TEST "ORA" B,C,D,E,H,L,A
	MVI	A,$00
	MVI	H,$8F
	MVI	L,$4F
	XRA	B
	XRA	C
	XRA	D
	XRA	E
	XRA	H
	XRA	L
	CPI	$CF
	CNZ	CPUError	;TEST "XRA" B,C,D,E,H,L
	XRA	A
	CNZ	CPUError	;TEST "XRA" A
	MVI	B,$44
	MVI	C,$45
	MVI	D,$46
	MVI	E,$47
	MVI	H,>Temp0 	;HIGH BYTE OF TEST MEMORY LOCATION
	MVI	L,<Temp0 	;LOW BYTE OF TEST MEMORY LOCATION
	MOV	M,B
	MVI	B,$00
	MOV	B,M
	MVI	A,$44
	CMP	B
	CNZ	CPUError	;TEST "MOV" M,B AND B,M
	MOV	M,D
	MVI	D,$00
	MOV	D,M
	MVI	A,$46
	CMP	D
	CNZ	CPUError	;TEST "MOV" M,D AND D,M
	MOV	M,E
	MVI	E,$00
	MOV	E,M
	MVI	A,$47
	CMP	E
	CNZ	CPUError	;TEST "MOV" M,E AND E,M
	MOV	M,H
	MVI	H,>Temp0
	MVI	L,<Temp0
	MOV	H,M
	MVI	A,>Temp0
	CMP	H
	CNZ	CPUError	;TEST "MOV" M,H AND H,M
	MOV	M,L
	MVI	H,>Temp0
	MVI	L,<Temp0
	MOV	L,M
	MVI	A,<Temp0
	CMP	L
	CNZ	CPUError	;TEST "MOV" M,L AND L,M
	MVI	H,>Temp0
	MVI	L,<Temp0
	MVI	A,$32
	MOV	M,A
	CMP	M
	CNZ	CPUError	;TEST "MOV" M,A
	ADD	M
	CPI	$64
	CNZ	CPUError	;TEST "ADD" M
	XRA	A
	MOV	A,M
	CPI	$32
	CNZ	CPUError	;TEST "MOV" A,M
	MVI	H,>Temp0
	MVI	L,<Temp0
	MOV	A,M
	SUB	M
	CNZ	CPUError	;TEST "SUB" M
	MVI	A,$80
	ADD	A
	ADC	M
	CPI	$33
	CNZ	CPUError	;TEST "ADC" M
	MVI	A,$80
	ADD	A
	SBB	M
	CPI	$CD
	CNZ	CPUError	;TEST "SBB" M
	ANA	M
	CNZ	CPUError	;TEST "ANA" M
	MVI	A,$25
	ORA	M
	CPI	$37
	CNZ	CPUError	;TEST "ORA" M
	XRA	M
	CPI	$05
	CNZ	CPUError	;TEST "XRA" M
	MVI	M,$55
	INR	M
	DCR	M
	ADD	M
	CPI	$5A
	CNZ	CPUError	;TEST "INR","DCR",AND "MVI" M
	LXI	B,$12FF
	LXI	D,$12FF
	LXI	H,$12FF
	INX	B
	INX	D
	INX	H
	MVI	A,$13
	CMP	B
	CNZ	CPUError	;TEST "LXI" AND "INX" B
	CMP	D
	CNZ	CPUError	;TEST "LXI" AND "INX" D
	CMP	H
	CNZ	CPUError	;TEST "LXI" AND "INX" H
	MVI	A,$00
	CMP	C
	CNZ	CPUError	;TEST "LXI" AND "INX" B
	CMP	E
	CNZ	CPUError	;TEST "LXI" AND "INX" D
	CMP	L
	CNZ	CPUError	;TEST "LXI" AND "INX" H
	DCX	B
	DCX	D
	DCX	H
	MVI	A,$12
	CMP	B
	CNZ	CPUError	;TEST "DCX" B
	CMP	D
	CNZ	CPUError	;TEST "DCX" D
	CMP	H
	CNZ	CPUError	;TEST "DCX" H
	MVI	A,$FF
	CMP	C
	CNZ	CPUError	;TEST "DCX" B
	CMP	E
	CNZ	CPUError	;TEST "DCX" D
	CMP	L
	CNZ	CPUError	;TEST "DCX" H
	STA	Temp0
	XRA	A
	LDA	Temp0
	CPI	$FF
	CNZ	CPUError	;TEST "LDA" AND "STA"
	LHLD	TempP
	SHLD	Temp0
	LDA	TempP
	MOV	B,A
	LDA	Temp0
	CMP	B
	CNZ	CPUError	;TEST "LHLD" AND "SHLD"
	LDA	TempP+1
	MOV	B,A
	LDA	Temp0+1
	CMP	B
	CNZ	CPUError	;TEST "LHLD" AND "SHLD"
	MVI	A,$AA
	STA	Temp0
	MOV	B,H
	MOV	C,L
	XRA	A
	LDAX	B
	CPI	$AA
	CNZ	CPUError	;TEST "LDAX" B
	INR	A
	STAX	B
	LDA	Temp0
	CPI	$AB
	CNZ	CPUError	;TEST "STAX" B
	MVI	A,$77
	STA	Temp0
	LHLD	TempP
	LXI	D,$0000
	XCHG
	XRA	A
	LDAX	D
	CPI	$77
	CNZ	CPUError	;TEST "LDAX" D AND "XCHG"
	XRA	A
	ADD	H
	ADD	L
	CNZ	CPUError	;TEST "XCHG"
	MVI	A,$CC
	STAX	D
	LDA	Temp0
	CPI	$CC
	STAX	D
	LDA	Temp0
	CPI	$CC
	CNZ	CPUError	;TEST "STAX" D
	LXI	H,$7777
	DAD	H
	MVI	A,$EE
	CMP	H
	CNZ	CPUError	;TEST "DAD" H
	CMP	L
	CNZ	CPUError	;TEST "DAD" H
	LXI	H,$5555
	LXI	B,$FFFF
	DAD	B
	MVI	A,$55
	CNC	CPUError	;TEST "DAD" B
	CMP	H
	CNZ	CPUError	;TEST "DAD" B
	MVI	A,$54
	CMP	L
	CNZ	CPUError	;TEST "DAD" B
	LXI	H,$AAAA
	LXI	D,$3333
	DAD	D
	MVI	A,$DD
	CMP	H
	CNZ	CPUError	;TEST "DAD" D
	CMP	L
	CNZ	CPUError	;TEST "DAD" B
	STC
	CNC	CPUError	;TEST "STC"
	CMC
	CC	CPUError	;TEST "CMC
	MVI	A,$AA
	CMA
	CPI	$55
	CNZ	CPUError	;TEST "CMA"
	ORA	A	;RE-SET AUXILIARY CARRY
	DAA
	CPI	$55
	CNZ	CPUError	;TEST "DAA"
	MVI	A,$88
	ADD	A
	DAA
	CPI	$76
	CNZ	CPUError	;TEST "DAA"
	XRA	A
	MVI	A,$AA
	DAA
	CNC	CPUError	;TEST "DAA"
	CPI	$10
	CNZ	CPUError	;TEST "DAA"
	XRA	A
	MVI	A,$9A
	DAA
	CNC	CPUError	;TEST "DAA"
	CNZ	CPUError	;TEST "DAA"
	STC
	MVI	A,$42
	RLC
	CC	CPUError	;TEST "RLC" FOR RE-SET CARRY
	RLC
	CNC	CPUError	;TEST "RLC" FOR SET CARRY
	CPI	$09
	CNZ	CPUError	;TEST "RLC" FOR ROTATION
	RRC
	CNC	CPUError	;TEST "RRC" FOR SET CARRY
	RRC
	CPI	$42
	CNZ	CPUError	;TEST "RRC" FOR ROTATION
	RAL
	RAL
	CNC	CPUError	;TEST "RAL" FOR SET CARRY
	CPI	$08
	CNZ	CPUError	;TEST "RAL" FOR ROTATION
	RAR
	RAR
	CC	CPUError	;TEST "RAR" FOR RE-SET CARRY
	CPI	$02
	CNZ	CPUError	;TEST "RAR" FOR ROTATION
	LXI	B,$1234
	LXI	D,$AAAA
	LXI	H,$5555
	XRA	A
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	LXI	B,$0000
	LXI	D,$0000
	LXI	H,$0000
	MVI	A,$C0
	ADI	$F0
	POP	PSW
	POP	H
	POP	D
	POP	B
	CC	CPUError	;TEST "PUSH PSW" AND "POP PSW"
	CNZ	CPUError	;TEST "PUSH PSW" AND "POP PSW"
	CPO	CPUError	;TEST "PUSH PSW" AND "POP PSW"
	CM	CPUError	;TEST "PUSH PSW" AND "POP PSW"
	MVI	A,$12
	CMP	B
	CNZ	CPUError	;TEST "PUSH B" AND "POP B"
	MVI	A,$34
	CMP	C
	CNZ	CPUError	;TEST "PUSH B" AND "POP B"
	MVI	A,$AA
	CMP	D
	CNZ	CPUError	;TEST "PUSH D" AND "POP D"
	CMP	E
	CNZ	CPUError	;TEST "PUSH D" AND "POP D"
	MVI	A,$55
	CMP	H
	CNZ	CPUError	;TEST "PUSH H" AND "POP H"
	CMP	L
	CNZ	CPUError	;TEST "PUSH H" AND "POP H"
	LXI	H,$0000
	DAD	SP
	SHLD	TempStck	;SAVE THE "OLD" STACK-POINTER!
	LXI	SP,Temp4
	DCX	SP
	DCX	SP
	INX	SP
	DCX	SP
	MVI	A,$55
	STA	Temp2
	CMA
	STA	Temp3
	POP	B
	CMP	B
	CNZ	CPUError	;TEST "LXI","DAD","INX",AND "DCX" SP
	CMA
	CMP	C
	CNZ	CPUError	;TEST "LXI","DAD","INX", AND "DCX" SP
	LXI	H,Temp4
	SPHL
	LXI	H,$7733
	DCX	SP
	DCX	SP
	XTHL
	LDA	Temp3
	CPI	$77
	CNZ	CPUError	;TEST "SPHL" AND "XTHL"
	LDA	Temp2
	CPI	$33
	CNZ	CPUError	;TEST "SPHL" AND "XTHL"
	MVI	A,$55
	CMP	L
	CNZ	CPUError	;TEST "SPHL" AND "XTHL"
	CMA
	CMP	H
	CNZ	CPUError	;TEST "SPHL" AND "XTHL"
	LHLD	TempStck	;RESTORE THE "OLD" STACK-POINTER
	SPHL
	LXI	H,@End
	PCHL		;TEST "PCHL"
@End	.equ	*
