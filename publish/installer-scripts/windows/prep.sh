#!/bin/bash

START=$PWD
VERSION=$1
DIR=bowlerstudio-$VERSION
JVMIMG="zulu8.38.0.13-ca-fx-jdk8.0.212-win_x64.zip"
JVMDIR="${JVMIMG%%.*}"
echo "Dir = $JVMDIR"
if (! test -z "$VERSION" ) then
	rm -rf $DIR
	START=$PWD/../../archive/ 	
	if (! test -e /home/hephaestus/.wine/drive_c/installer-scripts) then
		echo 'Linking build dirs for wine'
		ln -s $START/../installer-scripts 	$HOME/.wine/drive_c/
		ln -s $START/../archive 			$HOME/.wine/drive_c/
	fi
		
	#cp -r BowlerStudio.app $DIR/
	unzip -qq $PWD/../../archive/$VERSION/bowlerstudio-$VERSION.zip -d .

	if [ -f "$JVMIMG" ]; then
    	echo "$JVMIMG exist"
    else
    	echo Downloading from https://www.azul.com/downloads/zulu/zulufx/ 
    	wget https://cdn.azul.com/zulu/bin/$JVMIMG
	fi
	rm windows.iss
	cp TEMPLATEwindows.iss windows.iss
	sed -i s/VER/"$VERSION"/g windows.iss
	sed -i s/CVARCH/x64/g windows.iss
	sed -i s/JAVAARCH/HKLM64/g windows.iss
	echo adding Bowler Studio For Windows
	AUTOUPDATE=$DIR/bin/LatestFromGithubLaunch.jar
	rm $AUTOUPDATE
	if (! test -e $AUTOUPDATE) then
		wget https://github.com/CommonWealthRobotics/LatestFromGithubLaunch/releases/download/0.0.2/LatestFromGithubLaunch.jar -O $AUTOUPDATE
	fi
	
	$JAVA_HOME/bin/java -jar ../osx/packr.jar \
     --platform windows64 \
     --jdk $JVMIMG \
     --executable BowlerStudio \
     --classpath $DIR/bin/LatestFromGithubLaunch.jar \
     --mainclass LatestFromGithubLaunch.Main \
     --vmargs Xmx8G \
     --output BowlerStudioApp\
     --verbose
        cp $DIR/LICENSE.txt .
	cp splash.ico BowlerStudioApp/
    cp BowlerStudio.bat BowlerStudioApp/
	cp BowlerStudio.vbs BowlerStudioApp/
	rm BowlerStudioApp/BowlerStudio.exe
	echo Running wine
	wine "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" /cc "C:\installer-scripts\windows\windows.iss"
	rm -rf $DIR
	#if ( wine "C:\Program Files (x86)\Inno Setup 5\Compil32.exe" /cc "C:\installer-scripts\windows\windows.iss") then
	#	echo wine ok
	#else
	#	wine $START/tools/isetup-5.4.3.exe
	#	exit 1
	#fi

fi
