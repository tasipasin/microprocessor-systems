/*
* lab-a4-voltimetro.c
*
* Created: 05/11/2021 10:25:07
* Author : Tasi Pasin
*/

#define F_CPU 16000000 // 16Mhz - Clock
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdint.h>

//   .gfedcba
// 0b00000000
// Definição dos segmentos
uint8_t segmentos[10] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67};
// Contador de display
uint8_t display = 0;
uint16_t adcValue = 1234;

void write_display(uint8_t display, uint8_t valor){
	// Zera os quatro últimos bits da porta B. Apaga displays
	PORTB &= ~(0x0F);
	// Recupera o valor para acender os segmentos do valor
	uint8_t segValue = segmentos[valor];
	// Verifica se é o display 3
	if(display == 3){
		// Liga ponto
		segValue |= (1 << 7);
		}else{
		// Desliga ponto
		segValue &= ~(1 << 7);
	}
	// Multiplexa o display
	PORTB |= (1 << display);
	PORTD = 0;
	// Mostra o valor no display
	PORTD = segValue;
}

ISR(TIMER0_OVF_vect){
	TCNT0 = 6;
	// Inicializa variável para inserir o valor no display
	uint8_t valueToDisplay = 0;
	// Verifica qual o dígito deve ser recuperado o valor para mostrar no display
	switch(display){
		case 0:
		valueToDisplay = adcValue % 10;
		break;
		case 1:
		valueToDisplay = (adcValue / 10) % 10;
		break;
		case 2:
		valueToDisplay = (adcValue / 100) % 10;
		break;
		default:
		valueToDisplay = (adcValue / 1000) % 10;
		break;
	}
	// Escreve o display com o valor
	write_display(display, valueToDisplay);
	display++;
	if(display == 4){
		display = 0;
	}
}

void config_timer(){
	TCNT0 = 6;
	TCCR0A = 0x00; // Modo Normal
	// Prescaler divisão por 64
	TCCR0B = (1 << CS01) | (1 << CS00); // Liga o clock do time 0
	TIMSK0 = (1 << TOIE0);	// Habilita interrupção
}

void config_adc(){
	// ADC
	ADMUX = 0x40;
	ADCSRA = 0x87;
}

void config_ios(){
	DDRD = 0xFF;
	DDRB = 0x0F;
	PORTB = 0x00;
}

void config(){
	config_ios();
	config_adc();
	config_timer();
}

void getValue(){
	// Dispara conversão
	ADCSRA |= 1 << 6;
	// Ler as informações em ADCH e ADCL
	uint16_t tempAdcValue = ((uint16_t) ADCH << 8) | ADCL;
	// adcValue convertido para uint32 para ter mais bits
	// Valor divido por 1024 para gastar menos esforço
	adcValue = ((((uint32_t) tempAdcValue) * 5000)/ 1024);
	ADCSRA &= ~(1 << 6);
}

int main(void)
{
	config();
	sei();
	while (1)
	{
		//getValue();
	}
}