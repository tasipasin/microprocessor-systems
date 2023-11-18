.org 0
	rjmp start

.org 0x20
	push	R16
		in		R16,SREG
		push	R16
			ldi		R16,6		; INICIAMOS CONTADOR COM 6
			out		TCNT0,R16
		pop		R16
		out		SREG,R16
	pop		R16
	reti ; retorno da interrupção

start:
	ldi		R16,0x00	; MODO NORMAL
	out		TCCR0A,R16

	ldi		R16,6		; INICIAMOS CONTADOR COM 6
	out		TCNT0,R16

	ldi		R16,0b00000011	; PRESCALER DIVISAO POR 64
	out		TCCR0B,R16

	; Habilitar a interrupção
	ldi		R16, 0x01 ; Habilita time 0 Overflow Interrupt
	sts		TIMSK0, R16

	; Habilita interrupção global
	sei

loop:
	rjmp	loop

