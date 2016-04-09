#!/bin/bash

START=$PWD

VERSION=$1
STUDIOVER=$2
DYIOVER=$3

if ( test -z "$STUDIOVER" ) then
	echo #####ERROR no BowlerStudio version specified, I.E. 3.7.0
	exit 1
fi
if ( test -z "$VERSION" ) then
	echo #####ERROR no bowler-script-kernel version specified, I.E. 3.7.0
	exit 1
fi

if ( test -z "$DYIOVER" ) then
	echo #####DyIO version not specified
	DYIOVER=$VERSION
fi

if ( test -n "$VERSION" ) then
	#sudo apt-get install ant wine
	
	echo ok $VERSION
	ZIP=bowlerstudio-$STUDIOVER.zip
	BUILDLOCAL=bowlerstudio-$STUDIOVER
	DIST=$START/$STUDIOVER
	TL=$START/../../../
	NRSDK=bowler-script-kernel/
	NRConsole=BowlerStudio/
	#LIB=$TL/$NRSDK/build/libs/nrsdk-$VERSION-jar-with-dependencies.jar
	LIB=$TL/$NRSDK/build/libs/BowlerScriptingKernel-$VERSION.jar
	NRCONSOLE_JAR=$TL/$NRConsole/build/libs/BowlerStudio.jar
	OLDDYIO=false;
	ZIP=$DIST/$ZIP
	BUILD=$DIST/$BUILDLOCAL
	EXEWIN=$DIST/bowlerstudio-$STUDIOVER.exe
	
	WINFINAL64=$DIST/Windows-64-BowlerStudio-$STUDIOVER.exe
	WINFINAL32=$DIST/Windows-32-BowlerStudio-$STUDIOVER.exe
	MACFINAL=$DIST/MacOSX-BowlerStudio-$STUDIOVER.zip
	DEBFINAL=$DIST/Ubuntu-BowlerStudio-$STUDIOVER.deb
	
	
	USE_PROVIDED_FIRMWARE=true;

	if !(test -d $TL/$NRSDK/); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/bowler-script-kernel.git
	fi
	cd $TL/$NRSDK/ 
	git pull origin master
	if (! git checkout tags/$VERSION); then
		git tag -l
		echo "$NRSDK $VERSION Is not taged yet"
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

	if !(test -d $TL/dyio); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/dyio.git
	fi
	cd $TL/dyio/
	git pull origin development
	if (! git checkout tags/$DYIOVER); then
		if (! git checkout tags/v$DYIOVER); then
			git tag -l
			echo "DyIO $DYIOVER Is not taged yet"
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

	XML=$TL/$DyIO/FirmwarePublish/Release/dyio-$DYIOVER.xml
	

	
	cd $START
	
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
		mkdir $BUILD/firmware
		cp $START/*.txt $BUILD
	
	
		#cp $LIB 								$BUILD/bin/
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


	if (test -s "$MACFINAL" ) then
		echo "MAC OSX .zip exists $MACFINAL" 
		ls $MACFINAL
	else
		#Build the OSX bundle
		echo setting up build dirs for OSX builder
		rm -rf $START/../installer-scripts/osx/*.zip
		cp $ZIP $START/../installer-scripts/osx/
		cd $START/../installer-scripts/osx/
		sh prep.sh $STUDIOVER $XML
		mv $START/../installer-scripts/osx/*$STUDIOVER*.zip $MACFINAL
    fi

	if (test -s "$DEBFINAL" ) then
			echo "Ubuntu .deb exists $DEBFINAL" 
			ls -al  $DEBFINAL
	else
		#Build the Debian package
		echo setting up build dirs for debian builder
		rm -rf $START/../installer-scripts/linux/*.zip
		cp $ZIP $START/../installer-scripts/linux/
		cd $START/../installer-scripts/linux/
		sh prep.sh $STUDIOVER
		if ( test -e $DIST/*.deb) then
			rm $DIST/*.deb
		fi
		mv $START/../installer-scripts/linux/*$STUDIOVER*.deb $DEBFINAL
 	fi

	if (test -s "$WINFINAL64" ) then	
		echo "Windows EXE exists $WINFINAL64 "
		ls -al  $WINFINAL64
	else
		#Prepare the windows exe
		echo preparing the windows 64 compile directory
		WINBUILD=$START/../installer-scripts/windows/
		WINDIR=$WINBUILD/$BUILDLOCAL
		
		#64 bit version
		rm -rf $WINDIR
		cp $WINBUILD/TEMPLATEwindows-nrdk.iss $WINBUILD/windows-nrdk.iss
		sed -i s/VER/"$STUDIOVER"/g $WINBUILD/windows-nrdk.iss
		sed -i s/CVARCH/x64/g $WINBUILD/windows-nrdk.iss
		sed -i s/JAVAARCH/HKLM64/g $WINBUILD/windows-nrdk.iss
		echo adding Bowler Studio
		unzip -qq  $BUILD.zip -d $WINBUILD
		echo adding Opencv
		unzip -qq ~/git/ZipArchive/win/OpenCV-Win-2.4.9_64/build.zip -d $WINDIR
		echo adding Slic3r 64
		unzip -qq ~/git/ZipArchive/win/Slic3r_x64.zip -d $WINDIR/Slic3r_x64/
	
		if ( test -e $EXEWIN) then
			echo exe exists $EXEWIN
			rm $EXEWIN
		fi 
		rm -rf $WINDIR/java/docs/
		
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
		
		rm -rf $WINDIR
	
		mv $EXEWIN $WINFINAL64 
	fi
	
	if (test -s "$WINFINAL32" ) then	
		echo "Windows EXE exists $WINFINAL32 "
		ls -al  $WINFINAL32
	else
		#Prepare the windows exe
		echo preparing the windows 32 compile directory
		WINBUILD=$START/../installer-scripts/windows/
		WINDIR=$WINBUILD/$BUILDLOCAL
		
		#32 bit version
		rm -rf $WINDIR
		cp $WINBUILD/TEMPLATEwindows-nrdk.iss $WINBUILD/windows-nrdk_32.iss
		sed -i s/VER/"$STUDIOVER"/g $WINBUILD/windows-nrdk_32.iss
		sed -i s/CVARCH/x32/g $WINBUILD/windows-nrdk_32.iss
		sed -i s/JAVAARCH/HKLM/g $WINBUILD/windows-nrdk_32.iss
		echo adding Bowler Studio
		unzip -qq  $BUILD.zip -d $WINBUILD
		echo adding Opencv
		unzip -qq ~/git/ZipArchive/win/OpenCV-Win-2.4.9_32/build.zip -d $WINDIR
		echo adding Slic3r 32
		unzip -qq ~/git/ZipArchive/win/Slic3r_x86.zip -d $WINDIR/Slic3r_x86/
	
		if ( test -e $EXEWIN) then
			echo exe exists $EXEWIN
			rm $EXEWIN
		fi 
		rm -rf $WINDIR/java/docs/
		
		echo 'Linking build dirs for wine'
		if (! test -e /home/hephaestus/.wine/drive_c/installer-scripts) then
			ln -s $START/../installer-scripts 	$HOME/.wine/drive_c/
			ln -s $START/../archive 			$HOME/.wine/drive_c/
		fi
		
		echo Running wine
		if ( wine "C:\Program Files (x86)\Inno Setup 5\Compil32.exe" /cc "C:\installer-scripts\windows\windows-nrdk_32.iss") then
			echo wine ok
		else
			wine $START/tools/isetup-5.4.3.exe
			exit 1
		fi
		
		rm -rf $WINDIR
	
		mv $EXEWIN $WINFINAL32 
	fi
	
	if !(test -d $TL/$NRSDK/); then  
		cd $TL/;
		git clone https://github.com/NeuronRobotics/java-bowler.git
	fi
	
	cd $START/
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $XML
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $NRCONSOLE_JAR
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $LIB
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $DEBFINAL 
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $MACFINAL 
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $WINFINAL64 
	java -jar GithubPublish.jar BowlerStudio NeuronRobotics $STUDIOVER $WINFINAL32
	
	
	
	cd $START/
	sed -e s/VER/"$STUDIOVER"/g $START/index_template.md >$START/index.md
	cd $TL/NeuronRobotics.github.io/
	git pull
	cp $START/index.md $TL/NeuronRobotics.github.io/content/index.md
	git commit -m"rev bump to $STUDIOVER" $TL/NeuronRobotics.github.io/content/index.md
	git push
	rm $START/index.md
	
	
	
	echo Cleanup $TL/$NRSDK/ 
	cd $TL/$NRSDK/ 
	git checkout master
	echo Cleanup $TL/$NRConsole/
	cd $TL/$NRConsole/
	git checkout development
	echo Cleanup $TL/$NRConsole/java-bowler/
	cd $TL/$NRConsole/java-bowler/
	git pull origin development
	echo Cleanup $TL/dyio/
	cd $TL/dyio/
	git checkout development
	
	

	exit 0
fi
echo #####ERROR no version specified, I.E. 3.7.0
exit 1
