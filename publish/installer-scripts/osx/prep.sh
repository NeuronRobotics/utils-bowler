#!/bin/bash

START=$PWD
VERSION=$1
DIR=bowlerstudio-$VERSION
#https://cdn.azul.com/zulu/bin/zulu8.46.0.19-ca-fx-jdk8.0.252-macosx_x64.tar.gz
JVMDIR=zulu8.46.0.19-ca-fx-jdk8.0.252-macosx_x64
JVMIMG=$JVMDIR.tar.gz

PACKER=$JAVA_HOME/../bin/javapackager
$PACKER    -version
JVM_CONTENT="jvmcontents"
echo "Dir = $JVMDIR packaged by: $PACKER"
if (! test -z "$VERSION" ) then
	
	
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
		rm -rf $JVM_CONTENT
		mkdir $JVM_CONTENT
		echo "Untaring $JVMIMG"
    	tar -xzf $JVMIMG 
    	mv $JVMDIR/* $JVM_CONTENT
    	rm -rf $JVMDIR/
		zip -r jvm.zip $JVM_CONTENT/*
	fi
	
	if [ ! -d "$JVM_CONTENT" ]; then
	 unzip -qq jvm.zip -d $JVM_CONTENT
	else
	 echo "Existing jvm : $JVM_CONTENT"
	fi
#	$PACKER    -deploy -Bruntime=$JVM_CONTENT \
#			   -native image \
#			   -name BowlerStudio \
#			   -BappVersion=$VERSION \
#			   -Bicon=icons.icns \
#			   -Bmac.CFBundleVersion=1.0 \
#			   -Bmac.CFBundleIdentifier=com.neuronrobotics.bowlerstudio.BowlerStudio \
#			   -Bmac.category=Education \
#			   -BjvmOptions=-Xms8g \
#			   -BjvmOptions=-XX:+UseConcMarkSweepGC \
#			   -BjvmOptions=-Dapple.laf.useScreenMenuBar=true \
#			   -BjvmOptions=-Dcom.apple.smallTabs=true \
#			   -srcdir $DIR/ \
#			   -srcfiles $DIR/bin/BowlerStudio.jar \
#			   -appclass com.neuronrobotics.bowlerstudio.BowlerStudio \
#			   -outdir $DIR/installer/ \
#			   -v \
#			   -nosign \
#			   -outfile BowlerStudio.app
	echo "Second packer"
	rm -rf BowlerStudio.app/
	cp -R BowlerStudio-example.app/ BowlerStudio.app/
	echo runing packr from https://github.com/libgdx/packr/
	$JAVA_HOME/bin/java -jar packr.jar \
     --platform mac \
     --jdk jvm.zip \
     --executable BowlerStudio \
      --classpath $DIR/bin/LatestFromGithubLaunch.jar \
     --mainclass LatestFromGithubLaunch.Main \
     --vmargs Xmx8G \
     --icon splash.icns \
     --output BowlerStudio.app\
     --verbose
    rm  BowlerStudio.app/Contents/MacOS/BowlerStudio
    cp  BowlerStudio BowlerStudio.app/Contents/MacOS/
    chmod  +x BowlerStudio.app/Contents/MacOS/BowlerStudio
    mkdir BowlerStudio.app/Contents/MacOS/Resources/
    cp $DIR/bin/LatestFromGithubLaunch.jar BowlerStudio.app/Contents/MacOS/Resources/
    chmod +x BowlerStudio.app/Contents/MacOS/Resources/LatestFromGithubLaunch.jar
    chmod +x BowlerStudio.app/Contents/Resources/jre/lib/jspawnhelper
    
    echo "Zipping ..."
#    rm -rf mac-installer-$VERSION.zip
#	zip  -qq -r mac-installer-$VERSION.zip $DIR/installer/
	rm -rf mac-$VERSION.zip
	zip  -qq -r mac-$VERSION.zip BowlerStudio.app/
	echo "Zipping Done!"
	rm -rf $DIR
fi
