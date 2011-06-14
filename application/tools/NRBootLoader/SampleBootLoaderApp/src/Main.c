/*
 * Main.c
 *
 *  Created on: Jun 14, 2011
 *      Author: hephaestus
 */

#include "Compiler.h"
#include "GenericTypeDefs.h"

	#define initLed()		LATE = 0xFFF0; TRISE = 0xFFF0;
	#define initButton() 	((_TRISE7)=1)
	#define isPressed()		(_RE7 == 0)
	#define setLed(a,b,c) 	LATEbits.LATE0=!a;LATEbits.LATE1=!b;LATEbits.LATE2=!c

void delayLoop(){

}

int main(void){
	initLed();
	initButton();
	while(!isPressed()){
		setLed(1,0,0);
	}

	while(isPressed()){
		setLed(1,1,1);
	}
	SoftReset();
}
