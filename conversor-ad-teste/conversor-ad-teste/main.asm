rjmp	start

.include "minha_lib.inc"

; Replace with your application code
start:
	; Configura a porta D
	ldi		R16,0xFF ; <- Porta D inteira como saída
	out		DDRD,R16

	rcall	adc_config

repete:
	; Seleciona o canal
	;ldi		R16,0b01100000
	;sts		ADMUX,R16
	rcall	adc_conv

	out		PORTD,R16
	rjmp	repete

adc_config:
	; Configura ADC
	ldi		R16,0b01100000
	sts		ADMUX,R16
	ldi		R16,0b10000111
	sts		ADCSRA,R16
	ret

adc_conv:
	;Pausa 10us
	pause_i_us	10
	; Dispara ADC
	ldi		R16,0b11000111
	sts		ADCSRA,R16

	; Aguarda fim da conversao
adc_aguarda:
	lds		R16, ADCSRA
	sbrc	R16, 6
	rjmp	adc_aguarda
	; Le o valor da ADC
	lds		R16,ADCH
	ret