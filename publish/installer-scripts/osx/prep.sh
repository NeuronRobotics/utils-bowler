#!/bin/bash

START=$PWD
VERSION=$1
DIR=bowlerstudio-$VERSION
JVMIMG="zulu8.38.0.13-ca-fx-jdk8.0.212-macosx_x64.tar.gz"
JVMDIR="${JVMIMG%%.*}"
PACKER=$JAVA_HOME/../bin/javapackager
$PACKER    -version
JVM_CONTENT="jvmcontents"
echo "Dir = $JVMDIR packaged by: $PACKER"
if (! test -z "$VERSION" ) then
	rm -rf $DIR
	
	#cp -r BowlerStudio.app $DIR/
	unzip -qq $PWD/../../archive/$VERSION/bowlerstudio-$VERSION.zip -d .

	if [ -f jvm.zip ]; then
    	echo "$JVMIMG exist"
    else
    	if [ -f "$JVMIMG" ]; then
	    	echo "$JVMIMG exist"
	    else
	    	echo Downloading from https://www.azul.com/downloads/zulu/zulufx/ 
	    	wget https://cdn.azul.com/zulu/bin/$JVMIMG
		fi
    	tar xzf $JVMIMG -C $JVM_CONTENT
		zip jvm.zip $JVM_CONTENT
	fi
	
	if [ ! -d "$JVM_CONTENT" ]; then
	 unzip -qq jvm.zip -d $JVM_CONTENT
	fi
	
	$PACKER    -deploy \
			   -Bruntime=$JVM_CONTENT \
			   -native image \
			   -name BowlerStudio \
			   -BappVersion=$VERSION \
			   -Bicon=icons.icns \
			   -srcdir . \
			   -srcfiles $DIR/bin/BowlerStudio.jar \
			   -appclass com.neuronrobotics.bowlerstudio.BowlerStudio \
			   -outdir $DIR/installer/ \
			   -v \
			   -outfile BowlerStudio-$VERSION-Mac-Installer
			   
	java -jar packr.jar \
     --platform mac \
     --jdk jvm.zip \
     --executable BowlerStudio \
     --classpath $DIR/bin/BowlerStudio.jar \
     --mainclass com.neuronrobotics.bowlerstudio.BowlerStudio \
     --vmargs Xmx8G \
     --icon $DIR/bin/NeuronRobotics.ico \
     --output $DIR/BowlerStudio.app\
     --verbose
    echo "Zipping ..."
    rm -rf mac-installer-$VERSION.zip
	zip  -qq -r mac-installer-$VERSION.zip $DIR/installer/
	rm -rf mac-$VERSION.zip
	zip  -qq -r mac-$VERSION.zip $DIR/BowlerStudio.app/
	echo "Zipping Done!"
fi
