;
; lab-a2-com-serial.asm
;
; Created: 05/10/2021 08:42:11
; Author : Tasi Pasin
;
.macro store
	ldi R16, @1 ; Carrega o registrador R16 com o valor 1
	sts @0,R16 ; Tranfere para o Espaço de Dado
.endm

rjmp			config

.include		"minha_lib.inc"

; Replace with your application code
config:
    ; Configuração da taxa de comunicação Boudrate 9600bps
	; Registros de Baud Rate - Baixa e Alta
	store		UBRR0L, 0xCF 
	store		UBRR0H, 0x00
	; Configuração USART0
	store		UCSR0A, 0x22
	store		UCSR0B, 0x18
	store		UCSR0C, 0x06
	; Configura ADC
	store		ADMUX,	0x60
	store		ADCSRA, 0x87

repeat:
	rcall	rx_R16 ; Lê informação serial
	jne		R16, 0x2B, repeat ; Verifica se o valor lido é + (0x2B), se nao for, volta para o repeat
	rcall	adc_conv ; Converte o valor analógico e armazena em R16
	push    R16 ; Armazena no stackpoint o valor lido no ADC
	rcall	read_tabela_R16 ; Imprime a tabela
	pop		R16 ; Recupera o valor lido do ADC
	rcall	u4_to_hex
	ldi		R16,0x0A ; Coloca o valor da quebra de linha no R16
	rcall	tx_R16	; Imprime a quebra de linha
	rjmp	repeat

; Le os valores da tabela e transmite ate atingir 0
read_tabela_R16:
	ldi		R16, 0
read_tabela:
	push	R16
	rcall	tabela_R16 ; Lê o próximo valor da tabela
	je		R16, 0, ret_tabela ; Verifica se o valor da tabela é zero, se não for, executa o retorno para o fluxo principal
	rcall	tx_R16 ; Transmite o valor da tabela
	pop		R16 ; Recupera o valor do contador de R16
	inc		R16 ; Incremente R16
	rjmp	read_tabela
ret_tabela:
	pop		R16
	ret

; Insere em R16 o valor da tabela contido na posição informada em R16
tabela_R16:
	ldi		ZL,LOW(tabela*2)
	ldi		ZH,HIGH(tabela*2)
	add		ZL,R16
	ldi		R16,0
	adc		ZH,R16
	lpm		R16,Z
	ret
tabela:
	.db "TASI: ADC = 0x", 0, 0

; Le informacao
rx_R16:
	lds		R16, UCSR0A	
	sbrs    R16, RXC0	; Aguarda bit RXC0 (bit 7 ser ligado)
	rjmp	rx_R16
	lds		R16, UDR0	; Le o valor de UDR0 e Coloca em R16
	ret

; Transmite informação
tx_R16:
	push	R16 ; Insere o valor no stackpointer
tx_R16_loop:
	lds		R16, UCSR0A ; Carrega de um DataSpace
	sbrs	R16, UDRE0 ;UDRE0 = bit5 // Verifica se pode escrever novo valor
	rjmp	tx_R16_loop ; Executa a verificação até poder
	pop		R16 ; Recupera o valor no stackpointer
	sts		UDR0,R16 ; Transmite o dado
	ret

adc_conv:
	;Pausa 10us
	pause_i_us	10
	; Dispara ADC
	store	ADCSRA, 0b11000111

; Aguarda fim da conversao
adc_aguarda:
	lds		R16, ADCSRA
	sbrc	R16, 6
	rjmp	adc_aguarda
	; Le o valor da ADC
	lds		R16,ADCH
	ret

; Converte o valor lido no ADC para HEX em String
u4_to_hex:
	push	R16 ; Armazena o valor de R16 para não perder
	rcall	shift_right_R16 ; Executa deslocamento para a direita
	rcall	tabela_ascii_R16 ; Busca na tabela a String hex correspondente ao valor bin
	rcall	tx_R16 ; Transmite a informação
	pop		R16 ; Recupera o valor armazenado de R16
	rcall	shift_left_R16 ; Executa deslocamento para a esquerda
	rcall	shift_right_R16 ; Executa deslocamento para a direita
	rcall	tabela_ascii_R16 ; Busca na tabela a String hex correspondente ao valor bin 
	rcall	tx_R16 ; Transmite a informação
	ret

; Desloca os bits quatro vezes para a direita
shift_right_R16:
	lsr		R16
	lsr		R16
	lsr		R16
	lsr		R16
	ret

; Desloca os bits quatro vezes para a esquerda
; para limpar os quatro bits mais significativos
shift_left_R16:
	lsl		R16
	lsl		R16
	lsl		R16
	lsl		R16
	ret

; Insere em R16 o valor da tabela ascii contido na posição informada em R16
tabela_ascii_R16:
	ldi		ZL,LOW(tabela_ascii*2)
	ldi		ZH,HIGH(tabela_ascii*2)

	add		ZL,R16
	ldi		R16,0
	adc		ZH,R16

	lpm		R16,Z
	ret
tabela_ascii:
	.db "0","1","2","3","4","5","6","7","8","9", "A", "B", "C", "D", "E", "F"
