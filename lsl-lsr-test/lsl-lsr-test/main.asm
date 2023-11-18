;
; lsl-lsr-test.asm
;
; Created: 10/10/2021 16:15:19
; Author : Tasi Pasin
;


; Replace with your application code
start:
    ldi		R16, 0x61
	push	R16
	rcall	left_right_r16
	nop
	pop		R16
	rcall	left_left_r16
left_right_r16:
	lsr		R16
	lsr		R16
	lsr		R16
	lsr		R16
	ret

left_left_r16:
	lsl		R16
	lsl		R16
	lsl		R16
	lsl		R16
	ret
