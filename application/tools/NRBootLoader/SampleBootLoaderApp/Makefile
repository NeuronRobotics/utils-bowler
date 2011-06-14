INCLUDE="/home/hephaestus/.wine/drive_c/Program Files/Microchip/MPLAB C32/pic32mx/include/"

all: xml
	echo OK

dirs:
	if (test -d build);then rm -rf build;fi;
	mkdir build
	
xml: compile
	java -jar tools/MakeBowlerFirmware.jar --pic build/output.hex --rev 3.0.0 --output sample.xml
	
compile: dirs
	pic32mx-gcc -Os -mprocessor=32MX460F512L -c -I$(INCLUDE) src/Main.c -o build/Main.o
	pic32mx-gcc -Os -mprocessor=32MX460F512L  -Wl,--script="tools/elf32pic32mx.ld"  build/Main.o -o build/output.elf
	pic32mx-bin2hex -v -a  build/output.elf