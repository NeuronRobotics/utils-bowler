#!/bin/bash

START=$PWD

VERSION=$1

if (! test -z "$VERSION" ) then
	sudo apt-get install ant wine
	
	echo ok $VERSION
	ZIP=nrdk-$VERSION.zip
	BUILDLOCAL=nrdk-$VERSION
	DIST=$PWD/$VERSION
	TL=$START/../../
	if (test -d $TL/NRSDK/); then 
		cd $TL/NRSDK/;
		svn update;
	else 
		cd $TL/;
		svn checkout http://nr-sdk.googlecode.com/svn/trunk/NRDK NRSDK;
	fi
	if (test -d $TL/NRConsole/); then 
		cd $TL/NRConsole/;
		svn update;
	else 
		cd $TL/;
		svn checkout http://nr-sdk.googlecode.com/svn/trunk/application/nrconsole NRConsole;
	fi

	if (test -d $TL/DyIO/); then 
		cd $TL/DyIO/;
		svn update;
	else 
		cd $TL/;
		svn checkout https://nr-sdk.googlecode.com/svn/trunk/firmware/device/DyIO/development  DyIO;
	fi

	if (test -d $TL/NR-Clib/); then 
		cd $TL/NR-Clib/;
		svn update;
	else 
		cd $TL/;
		svn checkout https://nr-sdk.googlecode.com/svn/trunk/firmware/library/NR-Clib/development NR-Clib;
	fi


	cd $START
	LIB=$START/../../NRSDK/target/nrsdk-$VERSION-jar-with-dependencies.jar
	XML=$START/../../DyIO/FirmwarePublish/Release/dyio-$VERSION.xml
	NRCONSOLE=$START/../../NRConsole/target/nr-console.jar
	
	
	#Build all depandancies
	cd $TL/NRSDK/;ant
	if (! test -e $LIB) then
		echo ERROR!! expected lib file: $LIB 
		echo but none was found
		exit 1
	fi
	rm $TL/NRConsole/lib/nrsdk-*.jar
	cp $LIB/ $TL/NRConsole/lib/
	cd $TL/NRConsole/;ant
	if(!test -e $NRCONSOLE) then
		echo ERROR!! expected lib file: $NRCONSOLE 
		exit 1
	fi
	
	cd $TL/NR-Clib/;make all
	cd $TL/DyIO/;make update
	cd $TL/DyIO/;make all
	
	#Copy over data
	
	if (! test -e $XML) then
		echo ERROR!! expected firmware file: $XML 
		echo but none was found
		exit 1
	fi
	if(test -e $DIST) then
		echo previous build exists
		rm -rf $DIST/java
	else
		mkdir $DIST
	fi
	mkdir $DIST/java
	cd $DIST
	ZIP=$DIST/$ZIP
	
	BUILD=$DIST/$BUILDLOCAL
	echo entering:  $DIST 
	echo zip file:  $ZIP
	echo build dir: $BUILD
	if(test -e $ZIP) then
		echo zip exists
		rm $ZIP
	fi
	if(test -e $BUILD) then
		echo build dir exists
	else
		mkdir $BUILD
		mkdir $BUILD/bin
		mkdir $BUILD/java
		mkdir $BUILD/firmware
		cp $START/*.txt $BUILD
	fi
	


	cp $LIB 																$BUILD/java/
	cp $START/../../NRConsole/target/nr-console.jar 						$BUILD/bin/
	cp $START/NeuronRobotics.* 												$BUILD/bin/
	cp -r $START/../../DyIO/FirmwarePublish/Release/*						$BUILD/firmware/
	rsync -avtP --exclude=.svn* $START/../../NRSDK/target/docs 				$BUILD/java/
	cp $START/index.html 													$BUILD/java/docs/api/

	cd $START/../../NRDK_Test;svn update;
	rm -rf $START/../../NRDK_Test/bin/
	rsync -avtP --exclude=.svn* $START/../../NRDK_Test		 				$BUILD/java/
	rsync -avtP --exclude=.svn* $START/../../NRSDK/target/docs				$DIST/java
	echo Copy OK
	
	cd $DIST
	zip -r $ZIP $BUILDLOCAL
	
	#Prepare the windows exe
	echo preparing the windows compile directory
	WINBUILD=$START/../installer-scripts/windows/
	WINDIR=$WINBUILD/$BUILDLOCAL
	
	rm -rf $WINBUILD/nrdk-*
	cp $WINBUILD/TEMPLATEwindows-nrdk.iss $WINBUILD/windows-nrdk.iss
	sed -i s/VER/"$VERSION"/g $WINBUILD/windows-nrdk.iss
	
	
	cp -r $BUILD $START/../installer-scripts/windows
	if ( test -e $DIST/nrdk-$VERSION.exe) then
		echo exe exists $DIST/nrdk-$VERSION.exe
		rm $DIST/nrdk-$VERSION.exe
	fi 
	rm -rf $START/../installer-scripts/windows/nrdk-$VERSION/java/docs/
	
	echo 'Linking build dirs for wine'
	if (! test -e /home/hephaestus/.wine/drive_c/installer-scripts) then
		ln -s $START/../installer-scripts 	$HOME/.wine/drive_c/
		ln -s $START/../archive 			$HOME/.wine/drive_c/
	fi
	
	echo Running wine
	if ( wine "C:\Program Files\Inno Setup 5\Compil32.exe" /cc "C:\installer-scripts\windows\windows-nrdk.iss") then 
		echo windows installer compiled
	else

		if ( wine "C:\Program Files (x86)\Inno Setup 5\Compil32.exe" /cc "C:\installer-scripts\windows\windows-nrdk.iss") then
			echo wine ok
		else
			wine tools/isetup-5.4.3.exe
			exit 1
		fi
	fi
	
	echo setting up build dirs for debian builder
	#Build the Debian package
	rm $START/../installer-scripts/linux/*.zip
	cp $ZIP $START/../installer-scripts/linux/
	cd $START/../installer-scripts/linux/
	sh prep.sh $VERSION
	if ( test -e $DIST/*.deb) then
		rm $DIST/*.deb
	fi
	cp $START/../installer-scripts/linux/*$VERSION*.deb $DIST
	
	echo cleanup
	rm -rf 	$BUILD
	
	#sh $START/sendToServer.sh $VERSION
else
	echo #####ERROR no version specified, I.E. 3.7.0
	exit 1
fi
