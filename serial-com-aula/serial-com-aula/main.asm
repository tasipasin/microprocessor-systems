.macro store
	ldi R16, @1 ; Carrega o registrador R16 com o valor 1
	sts @0,R16 ; Tranfere para o Espaço de Dado
.endm

start:
	; Configuração da taxa de comunicação Boudrate 2400bps
	; Registros de Baud Rate - Baixa e Alta
	store	UBRR0L, 0xA0 
	store	UBRR0H, 0x01
	; Configuração USART0
	store	UCSR0A, 0b00100000
	store	UCSR0B, 0b00011000
	store	UCSR0C, 0b00000110

fim: 
	rcall	rx_R16
	rcall	tx_R16
	rjmp	fim

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

; Le informacao
rx_R16:
	lds		R16, UCSR0A	
	sbrs    R16, RXC0	; Aguarda bit RXC0 (bit 7 ser ligado)
	rjmp	rx_R16
	lds		R16, UDR0	; Le o valor de UDR0 e Coloca em R16
	ret

; TODO
; Alterar o baudrate para 9600bps
; Iniciar a execução imprimindo "Olá mundo"