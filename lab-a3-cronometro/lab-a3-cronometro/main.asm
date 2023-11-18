.org 0
	rjmp start

.org 0x20
	push	R16
		in		R16,SREG
		push	R16
			ldi		R16, 6	; Reconfigura o timer
			out		TCNT0, R16
			rcall		incrementaR20
		pop		R16
		out		SREG,R16
	pop		R16
	reti

; Definições de macros
.macro storeSts
	ldi R16, @1 ; Carrega o registrador R16 com o valor 1
	sts @0,R16 ; Tranfere para o Espaço de Dado
.endm
.macro storeOut
	ldi R16, @1 ; Carrega o registrador R16 com o valor 1
	out @0,R16 ; Tranfere para o Espaço de Dado
.endm

; Inclui a biblioteca
.include "minha_lib.inc"

; Replace with your application code
start:
	; Configura as portas
	storeOut	DDRD, 0xFF
	storeOut	DDRB, 0x0F
	storeOut	PORTB, 0x30
	; Inicializar os registradores de contagem
	ldi			R20, 0
	ldi			R21, 0
	ldi			R22, 0
	ldi			R23, 0
	ldi			R24, 0
	; Configura o timer
	storeOut	TCCR0A, 0X00 ; Modo Normal
	storeOut	TCNT0,	6	 ; Inicia contador com 6
	storeOut	TCCR0B,	0x03 ; PRESCALER DIVISAO POR 64
	storeSts	TIMSK0, 0x01 ; Habilita Timer 0 Overflow Interrupt
	sei		; Habilita a chave geral de interrupções

wait:
	storeOut	TCCR0B,	0x03 ; Inicia o contador
	rjmp		loop

loop:
	; S2 para o cronometro
	sbis	PINB, 5 ; Pula a próxima instrução se o botão do bit 4B não estiver pressionado
	rjmp	wait
	rcall	set_displays
	rjmp	loop


incrementaR20:
	inc		R20			; Incrementa R20
	je		R20, 0x64, zeraR20
	ret
zeraR20:
	ldi		R20, 0
	rcall	incrementaR21
	ret

incrementaR21:
	inc		R21			; Incrementa R21
	je		R21, 0x0A, zeraR21
	ret
zeraR21:
	ldi		R21, 0
	rcall	incrementaR22
	ret

incrementaR22:
	inc		R22			; Incrementa R22
	je		R22, 0x0A, zeraR22 ; Verifica se é igual a 10
	ret
zeraR22:
	ldi		R22, 0
	rcall	incrementaR23
	ret

incrementaR23:
	inc		R23			; Incrementa R23
	je		R23, 0x06, zeraR23 ; Verifica se R23 é 6
	ret
zeraR23:
	ldi		R23, 0
	rcall	incrementaR24
	ret

incrementaR24:
	inc		R24			; Incrementa R24
	je		R24, 0x0A, zeraR24 ; Verifica se R24 é 10
	ret
zeraR24:
	ldi		R24, 0
	ret

set_displays:
	ldi		R17, 0x1	; Reinicia o contador de display
	; Exibe o display 1
	mov		R16, R21
	rcall	set_display
	; Exibe o display 2
	ldi		R17, 0x2
	mov		R16, R22
	rcall	set_display
	; Exibe o display 3
	ldi		R17, 0x4
	mov		R16, R23
	rcall	set_display
	; Exibe o display 4
	ldi		R17, 0x8
	mov		R16, R24
	rcall	set_display
	ret

set_display:
	ldi			R18, 0x30	; Carrega R18 com o valor padrão de saída do PORTB
	out			PORTB, R18 ; Apaga o display. Joga zero em PB0123
	; R16 Possui o valor a ser exibido (0-9)
	rcall		segmentos_R16 ; Recupera o valor hexadecimal para ligar os segmentos
	out			PORTD, R16
	; R17 Possui o valor de qual display deve ser acendido
	push		R17
		add			R17, R18	; Soma no valor padrão de saída do PORTB o valor do display que deve ser acendido 
		out			PORTB, R17
	pop			R17
	; Pequena pausa 1/120Hz -> <8ms
	pause_i_ms	8
	ret

; Insere em R16 o valor do numero para acender os segmentos
segmentos_R16:
	ldi		ZL,LOW(segmentos*2)
	ldi		ZH,HIGH(segmentos*2)

	add		ZL,R16
	ldi		R16,0
	adc		ZH,R16

	lpm		R16,Z
	ret
segmentos:
	.db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67
