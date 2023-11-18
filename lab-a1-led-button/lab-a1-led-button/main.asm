;
; lab-a1-led-button.asm
;
; Created: 17/08/2021 10:21:07
; Author : Tasi Pasin

start:
	sbi	 DDRD,6  ; Seta o bit 6 da porta D para saída
	sbi	 DDRD,5  ; Seta o bit 5 da porta D para saída
	cbi  DDRD,4 ; Seta o bit 4 da porta D para entrada
	cbi  DDRD,3 ; Seta o bit 3 da porta D para entrada
	cbi  DDRD,2 ; Seta o bit 2 da porta D para entrada
	sbi  PORTD,4 ; Seta o bit 4 da porta D para entrada pullUp
	sbi  PORTD,3 ; Seta o bit 3 da porta D para entrada pullUp
	sbi  PORTD,2 ; Seta o bit 2 da porta D para entrada pullUp
volta:
	sbis PIND,4 ; Pula a próxima instrução se o botão do bit 4D não estiver pressionado
	rjmp but_3d_s ; Verifica se o botao 3D não está pressionado
	rjmp but_3d_c ; Verifica se o botao 3D está pressionado
but_3d_c:
	sbic PIND,3 ; Verifica se o botão do bit 3D está pressionado e pula a próxima instrução
	rjmp apaga_led_1
	rjmp acende_led_1
but_3d_s:
	sbis PIND,3 ; Pula a próxima instrução se o botão do bit 5D não estiver pressionado
	rjmp apaga_led_1
	rjmp acende_led_1
acende_led_1:
	sbi  PORTD,6 ; Acende o LED 1
	rjmp verifica_led_2
apaga_led_1:
	cbi  PORTD,6 ; Apaga o LED 1
	rjmp verifica_led_2
verifica_led_2:
	sbic PIND,4 ; Pula a próxima instrução se o botão do bit 4D estiver pressionado
	sbis PIND,3 ; Pula a próxima instrução se o botão do bit 3D não estiver pressionado
	rjmp verifica_but_2_c
	rjmp verifica_but_2_s
verifica_but_2_c:
	sbic PIND,2 ; Verifica se o botão 2D está pressionado
	rjmp acende_led_2
	rjmp apaga_led_2
verifica_but_2_s:
	sbis PIND,2 ; Verifica se o botão 2D não está pressionado
	rjmp acende_led_2
	rjmp apaga_led_2
acende_led_2:
	sbi  PORTD,5 ; Acende o LED 2
	rjmp volta
apaga_led_2:
	cbi  PORTD,5 ; Apaga o LED 2
	rjmp volta