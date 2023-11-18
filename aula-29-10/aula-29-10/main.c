/*
* aula-29-10.c
*
* Created: 29/10/2021 09:44:58
* Author : Tasi Pasin
*/

#define F_CPU 16000000 // 16Mhz - Clock
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#define ZERA_BIT(port, n)	port &= ~(1<<n)
// ZERA_BIT(PORTB,5)  ZERA O BIT 5

int cont = 0;

//https://www.nongnu.org/avr-libc/user-manual/group__avr__interrupts.html
ISR(TIMER0_OVF_vect){
	TCNT0 = 6;
	cont++;
	if(cont == 100){
		cont = 0;
		// Acende LED e apaga LED
		PORTB ^= (1<<5);
	}
}

void config_timer(){
	TCNT0 = 6;
	TCCR0A = 0x00; // Modo Normal
	TCCR0B = (1 << CS01) | (1 << CS00); // Liga o clock do time 0
	TIMSK0 = (1 << TOIE0);	// Habilita interrupção
}

void config_ios(){
	// LED como saída
	DDRB = (1<<5); //| (1 << 2)// 0b00100000;
}

int main(void)
{
	config_timer();
	config_ios();
	sei();
	
	while (1)
	{
	}
}

// OR binario |		=> PORTB |= (1<<5) liga o bit 5 da porta b
// AND binário &	=> PORTB &= ~(1<<5) desliga bit 5 da porta b
// XOR binário ^
// NOT binário ~
// 1 << 5 | 1 << 4 = (0b00100000) | (0b00010000) = 0b00110000