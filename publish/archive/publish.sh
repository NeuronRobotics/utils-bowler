#!/bin/bash

START=$PWD

VERSION=$1
STUDIOVER=$2

echo "bash publish.sh <Kernel version > <Studio Version>"

if ( test -z "$STUDIOVER" ) then
	echo #####ERROR no BowlerStudio version specified, I.E. 3.7.0
	exit 1
fi
if ( test -z "$VERSION" ) then
	echo #####ERROR no bowler-script-kernel version specified, I.E. 3.7.0
	exit 1
fi

sudo apt install wine libgphoto2-6:i386 libgd3:i386   libjpeg8:i386   wine1.6-i386
run () {
	VERSION=$1
	STUDIOVER=$2
	echo ok $VERSION
	ZIP=bowlerstudio-$STUDIOVER.zip
	BUILDLOCAL=bowlerstudio-$STUDIOVER
	DIST=$START/$STUDIOVER
	TL=$START/../../../
	NRConsole=BowlerStudio/
	NRSDK=$NRConsole/../bowler-script-kernel/
	
	#LIB=$TL/$NRSDK/build/libs/nrsdk-$VERSION-jar-with-dependencies.jar
	LIB=$TL/$NRSDK/build/libs/BowlerScriptingKernel-$VERSION-fat.jar
	NRCONSOLE_JAR=$TL/$NRConsole/build/libs/BowlerStudio.jar
	NRCONSOLE_JAR_FAT=$TL/$NRConsole/build/libs/BowlerStudio-$STUDIOVER-fat.jar
	ZIP=$DIST/$ZIP
	BUILD=$DIST/$BUILDLOCAL
	EXEWIN=$DIST/bowlerstudio-$STUDIOVER.exe
	
	WINFINAL64=$DIST/Windows-64-BowlerStudio-$STUDIOVER.exe
	WINFINAL32=$DIST/Windows-32-BowlerStudio-$STUDIOVER.exe
	MACFINAL=$DIST/MacOSX-BowlerStudio-$STUDIOVER.zip
	DEBFINAL=$DIST/Ubuntu-BowlerStudio-$STUDIOVER.deb
	

	if !(test -d $TL/$NRSDK/); then  
		cd $TL/;
		git clone https://github.com/CommonWealthRobotics/bowler-script-kernel.git
		git submodule update --init --recursive
		git submodule update  --recursive
	fi
	cd $TL/$NRSDK/ 
	git fetch --tags
	if (! git checkout tags/$VERSION); then
		git tag -l
		echo "$NRSDK $VERSION Is not taged yet"
		exit 1;
	fi
	git checkout master
	git pull origin development
	git push origin master
	git submodule update --init --recursive
	git submodule update  --recursive
	
	if !(test -d $TL/$NRConsole/); then  
		cd $TL/;
		git clone https://github.com/CommonWealthRobotics/BowlerStudio.git
		git submodule update --init --recursive
		git submodule update  --recursive
	fi
	cd $TL/$NRConsole/
	git pull origin development
	if (! git checkout $STUDIOVER); then
		git tag -l
		echo "NRConsole $STUDIOVER Is not taged yet"
		exit 1;
	fi
	git submodule update --init --recursive
	git submodule update  --recursive
	
	cd $TL/$NRConsole/libraries/bowler-script-kernel/
	#./gradlew uploadArchives
	

	cd $START
	
	if(test -e $DIST) then
		echo build dir exists
	else
	
	
	
	
		#Build all depandancies
		cd $TL/$NRSDK/;
		if (! test -e $LIB) then
			echo No kernel $LIB, building...

			./gradlew shadowJar
		fi
		if (! test -e $LIB) then
			echo ERROR!! expected lib file: $LIB 
			echo but none was found
			exit 1
		fi

		cd $TL/$NRConsole/;
		if(  test -e $NRCONSOLE_JAR_FAT) then
			echo No application $NRCONSOLE_JAR_FAT, building...
			./gradlew shadowJar
		fi
		if( ! test -e $NRCONSOLE_JAR_FAT) then
			echo ERROR!! expected lib file: $NRCONSOLE_JAR_FAT
			exit 1
		fi
		rm -rf $NRCONSOLE_JAR
		cp $NRCONSOLE_JAR_FAT $NRCONSOLE_JAR
	
		#Copy over data
	
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
		cp $START/*.txt $BUILD
	
	
		#cp $LIB 								$BUILD/bin/
		cp $NRCONSOLE_JAR						        $BUILD/bin/
		cp $START/NeuronRobotics.* 						$BUILD/bin/
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
		cd $START/../installer-scripts/osx/
		sh prep.sh $STUDIOVER 
		mv $START/../installer-scripts/osx/mac-$STUDIOVER.zip $MACFINAL
		rm $START/../installer-scripts/osx/mac-$STUDIOVER.zip
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
	
	
	cd $START/
	echo "Begin uploading binaries" 
	java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $NRCONSOLE_JAR
	java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $LIB
	java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $DEBFINAL 
	java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $MACFINAL 
	java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $WINFINAL64 
	

	
	cd $START/
	sed -e s/VER/"$STUDIOVER"/g $START/index_template.md >$START/index.md
	cd $TL/CommonWealthRobotics.github.io/
	git pull
	cp $START/index.md $TL/CommonWealthRobotics.github.io/content/index.md
	git commit -m"rev bump to $STUDIOVER" $TL/CommonWealthRobotics.github.io/content/index.md
	git push
	rm $START/index.md

	
	
	echo Cleanup $TL/$NRSDK/ 
	cd $TL/$NRSDK/ 
	git checkout development
	cd $TL/$NRConsole/
	git checkout development
	

	exit 0	
	
}

if ( test -n "$VERSION" ) then
	run $VERSION $STUDIOVER
fi
echo #####ERROR no version specified, I.E. 3.7.0
exit 1
