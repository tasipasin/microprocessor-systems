/*
 * ProgDemoArduinoUno.c
 *
 * Created: 19/08/2020 10:34:38
 * Author : Afonso Miguel
 */ 

#define F_CPU	16000000
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRB = 0b00111111;
	DDRD = 0b11111100;
    while (1){
		PORTB = 0b00111111;
		PORTD = 0b11111100;
		_delay_ms(500);
		PORTB = 0;
		PORTD = 0;
		_delay_ms(500);
    }
}