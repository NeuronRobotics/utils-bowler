/*
 * Main.c
 *
 *  Created on: Jun 14, 2011
 *      Author: hephaestus
 */

#include "p32xxxx.h"
#include "plib.h"
	#define GetSystemClock()		(80000000ul)      // Hz (80 mhz)
	#define GetInstructionClock()	(GetSystemClock()/1)
	#define GetPeripheralClock()	(GetInstructionClock()/1)	// Set your divider according to your Peripheral Bus Frequency configuration fuse setting
	#define initLed()		LATE = 0xFFF0; TRISE = 0xFFF0;
	#define initButton() 	((_TRISE7)=1)
	#define isPressed()		(_RE7 == 0)
	#define setLed(a,b,c) 	LATEbits.LATE0=!a;LATEbits.LATE1=!b;LATEbits.LATE2=!c


void Delay10us(DWORD dwCount)
{
	volatile DWORD _dcnt;

	_dcnt = dwCount*((DWORD)(0.00002/(3.0/GetInstructionClock())/10));
	while(_dcnt--);
}

void DelayMs(WORD ms)
{
    unsigned char i;
    while(ms--)
    {
        i=4;
        while(i--)
        {
            Delay10us(25);
        }
    }
}


void delayLoop(){
	DelayMs(1000);
}

int main(void){
	initLed();
	initButton();
	while(!isPressed()){
		setLed(1,0,0);
		delayLoop();
		setLed(0,0,0);
		delayLoop();
	}

	SoftReset();
}
