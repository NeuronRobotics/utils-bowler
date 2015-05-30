#!/bin/bash

START=$PWD

VERSION=$1
STUDIOVER=$2

if ( test -z "$STUDIOVER" ) then
	echo #####ERROR no BowlerStudio version specified, I.E. 3.7.0
	exit 1
fi
if ( test -z "$VERSION" ) then
	echo #####ERROR no java-bowler version specified, I.E. 3.7.0
	exit 1
fi

if ( test -n "$VERSION" ) then
	#sudo apt-get install ant wine
	
	echo ok $VERSION
	ZIP=bowlerstudio-$STUDIOVER.zip
	BUILDLOCAL=bowlerstudio-$STUDIOVER
	DIST=$PWD/$STUDIOVER
	TL=$START/../../../
	NRSDK=java-bowler/
	NRConsole=BowlerStudio/
	LIB=$TL/$NRSDK/build/libs/nrsdk-$VERSION-jar-with-dependencies.jar
	NRCONSOLE_JAR=$TL/$NRConsole/build/libs/BowlerStudio.jar
	OLDDYIO=false;
	ZIP=$DIST/$ZIP
	BUILD=$DIST/$BUILDLOCAL
	EXEWIN=$DIST/bowlerstudio-$STUDIOVER.exe
	
	WINFINAL=$DIST/Windows-BowlerStudio-$STUDIOVER.exe
	MACFINAL=$DIST/MacOSX-BowlerStudio-$STUDIOVER.zip
	DEBFINAL=$DIST/Ubuntu-BowlerStudio-$STUDIOVER.deb
	
	
	USE_PROVIDED_FIRMWARE=true;

	if !(test -d $TL/$NRSDK/); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/java-bowler.git
	fi
	cd $TL/$NRSDK/ 
	git pull origin development
	if (! git checkout tags/$VERSION); then
		git tag -l
		echo "NRSDK $VERSION Is not taged yet"
		exit 1;
	fi


	if !(test -d $TL/$NRConsole/); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/BowlerStudio.git
	fi
	cd $TL/$NRConsole/
	git pull origin development
	if (! git checkout $STUDIOVER); then
		git tag -l
		echo "NRConsole $STUDIOVER Is not taged yet"
		exit 1;
	fi
	cd $TL/$NRConsole/java-bowler/
	git pull origin development
	cd $TL

	if !(test -d $TL/dyio); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/dyio.git
	fi
	cd $TL/dyio/
	git pull origin development
	if (! git checkout tags/$VERSION); then
		if (! git checkout tags/v$VERSION); then
			git tag -l
			echo "DyIO $VERSION Is not taged yet"
			exit 1;
		fi
		#Change the DyIO directory to the old location before the GIT transition
		DyIO=microcontroller-bowler/firmware/device/DyIO/development/
	else
		DyIO=dyio/
	fi
	# make the output dirs for building the DyIO

	mkdir -p $TL/$DyIO/pic/output/release/
	mkdir -p $TL/$DyIO/pic/output/debug/
	mkdir -p $TL/$DyIO/pic/output/bluetooth/

	mkdir -p $TL/$DyIO/avr/output/atmega644p/
	mkdir -p $TL/$DyIO/avr/output/atmega324p/

	mkdir -p $TL/$DyIO/FirmwarePublish/Release/legacy/
	mkdir -p $TL/$DyIO/FirmwarePublish/Dev/

	XML=$TL/$DyIO/FirmwarePublish/Release/dyio-$VERSION.xml
	

	
	if(test -e $DIST) then
		echo build dir exists
	else
		cd $TL/$DyIO/
		make pub
	
	
	
		#Build all depandancies
		cd $TL/$NRSDK/;

		gradle jar
		if (! test -e $LIB) then
			echo ERROR!! expected lib file: $LIB 
			echo but none was found
			exit 1
		fi

		cd $TL/$NRConsole/;
		cd java-bowler/
		git pull origin $VERSION
		cd ..
		gradle jar
		if( ! test -e $NRCONSOLE_JAR) then
			echo ERROR!! expected lib file: $NRCONSOLE_JAR 
			exit 1
		fi
	
	
		#Copy over data
		
		if (! test -e $XML) then
			echo ERROR!! expected firmware file: $XML 
			echo but none was found
			#exit 1
		fi
		if(test -e $DIST) then
			echo previous build exists
			rm -rf $DIST/java
		else
			mkdir $DIST
		fi
		mkdir $DIST/java
		cd $DIST

		echo entering:  $DIST 
		echo zip file:  $ZIP
		echo build dir: $BUILD
		if(test -e $ZIP) then
			echo zip exists
			rm $ZIP
		fi

		mkdir $BUILD
		mkdir $BUILD/bin
		mkdir $BUILD/java
		mkdir $BUILD/firmware
		cp $START/*.txt $BUILD
	
	
		cp $LIB 								$BUILD/java/
		cp $NRCONSOLE_JAR						        $BUILD/bin/
		cp $START/NeuronRobotics.* 						$BUILD/bin/
		cp -r $TL/$DyIO/FirmwarePublish/Release/*			$BUILD/firmware/
		cp -r $TL/$NRConsole/BowlerBoard*.xml					$BUILD/firmware/
		#rsync -avtP --exclude=.svn* $TL/$NRSDK/target/docs 		$BUILD/java/
		#cp $START/index.html 							$BUILD/java/docs/api/
		#rsync -avtP --exclude=.svn* $TL/$NRSDK/target/docs				$DIST/java
		echo Copy OK
	
		cd $DIST
		zip -qq -r $ZIP $BUILDLOCAL
	fi


	if ( ! test -a $MACFINAL ) then
		#Build the OSX bundle
		echo setting up build dirs for OSX builder
		rm -rf $START/../installer-scripts/osx/*.zip
		cp $ZIP $START/../installer-scripts/osx/
		cd $START/../installer-scripts/osx/
		sh prep.sh $STUDIOVER	
		cp $START/../installer-scripts/osx/*$STUDIOVER*.zip $MACFINAL
    fi

	if ( ! test -a $DEBINAL ) then
		#Build the Debian package
		echo setting up build dirs for debian builder
		rm -rf $START/../installer-scripts/linux/*.zip
		cp $ZIP $START/../installer-scripts/linux/
		cd $START/../installer-scripts/linux/
		sh prep.sh $STUDIOVER
		if ( test -e $DIST/*.deb) then
			rm $DIST/*.deb
		fi
		cp $START/../installer-scripts/linux/*$STUDIOVER*.deb $DEBFINAL
 	fi

	if ( ! test -a $WININAL ) then	
		#Prepare the windows exe
		echo preparing the windows compile directory
		WINBUILD=$START/../installer-scripts/windows/
		WINDIR=$WINBUILD/$BUILDLOCAL
		
		rm -rf $WINDIR
		cp $WINBUILD/TEMPLATEwindows-nrdk.iss $WINBUILD/windows-nrdk.iss
		sed -i s/VER/"$STUDIOVER"/g $WINBUILD/windows-nrdk.iss
		echo adding Bowler Studio
		unzip -qq  $BUILD.zip -d $WINBUILD
		echo adding Opencv
		unzip -qq ~/git/ZipArchive/win/OpenCV-Win-2.4.9.zip -d $WINDIR
		echo adding Slic3r 64
		unzip -qq ~/git/ZipArchive/win/Slic3r_x64.zip -d $WINDIR/Slic3r_x64/
		echo adding Slic3r 32
		unzip -qq ~/git/ZipArchive/win/Slic3r_x86.zip -d $WINDIR/Slic3r_x86/
	
		if ( test -e $EXEWIN) then
			echo exe exists $EXEWIN
			rm $EXEWIN
		fi 
		rm -rf $START/../installer-scripts/windows/nrdk-$VERSION/java/docs/
		
		echo 'Linking build dirs for wine'
		if (! test -e /home/hephaestus/.wine/drive_c/installer-scripts) then
			ln -s $START/../installer-scripts 	$HOME/.wine/drive_c/
			ln -s $START/../archive 			$HOME/.wine/drive_c/
		fi
		
		echo Running wine
		if ( wine "C:\Program Files (x86)\Inno Setup 5\Compil32.exe" /cc "C:\installer-scripts\windows\windows-nrdk.iss") then
			echo wine ok
		else
			wine $START/tools/isetup-5.4.3.exe
			exit 1
		fi
	
		mv $WINEXE $WINFINAL 
	fi
	
	echo cleanup
	rm -rf 	$BUILD
	
	exit 0
fi
echo #####ERROR no version specified, I.E. 3.7.0
exit 1
