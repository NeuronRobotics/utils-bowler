#!/bin/bash

START=$PWD
VERSION=$1
DIR=bowlerstudio-$VERSION
JVMIMG="zulu8.38.0.13-ca-fx-jdk8.0.212-macosx_x64.tar.gz"
JVMDIR="${JVMIMG%%.*}"
echo "Dir = $JVMDIR"
if (! test -z "$VERSION" ) then
	rm -rf $DIR
	
	#cp -r BowlerStudio.app $DIR/
	unzip -qq $PWD/../../archive/$VERSION/bowlerstudio-$VERSION.zip -d .
	if [ -f "$JVMIMG" ]; then
    	echo "$JVMIMG exist"
    else
    	wget https://cdn.azul.com/zulu/bin/$JVMIMG
	fi
	if [ -f jvm.zip ]; then
    	echo "$JVMIMG exist"
    else
    	tar xzf $JVMIMG && zip jvm.zip $(tar tf $JVMIMG)
    	rm -rf $JVMDIR*
	fi
	
	java -jar packr.jar \
     --platform mac \
     --jdk jvm.zip \
     --executable BowlerStudio \
     --classpath $DIR/bin/BowlerStudio.jar \
     --mainclass com.neuronrobotics.bowlerstudio.BowlerStudio \
     --vmargs Xmx8G \
     --icon $DIR/bin/NeuronRobotics.ico \
     --output $DIR/BowlerStudio.app
	#mv $DIR/BowlerStudio.app/Contents/MacOS/$DIR/* $DIR/BowlerStudio.app/Contents/MacOS/

	#chmod +x $DIR/BowlerStudio.app/Contents/MacOS/BowlerStudio
	#rm *.zip
	
	zip  -qq -r mac-$VERSION.zip $DIR/BowlerStudio.app/
	rm -rf $DIR/

fi
