#!/bin/bash

START=$PWD

VERSION=$1
STUDIOVER=$2
NOINST=$3

echo "bash publish.sh <Kernel version > <Studio Version> <NOINSTALL>"

if( test -z "$STUDIOVER" ) then
	echo #####ERROR no BowlerStudio version specified, I.E. 3.7.0
	exit 1
fi
if( test -z "$VERSION" ) then
	echo #####ERROR no bowler-script-kernel version specified, I.E. 3.7.0
	exit 1
fi

sudo apt install wine-stable libgphoto2-6:i386 libgd3:i386   libjpeg8:i386   wine1.6-i386
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
	BOWLERSTUDIO_LOCATION=$TL/$NRConsole/build/libs/
	NRCONSOLE_JAR=$BOWLERSTUDIO_LOCATION/BowlerStudio.jar
	NRCONSOLE_JAR_FAT=$BOWLERSTUDIO_LOCATION/BowlerStudio-$STUDIOVER-fat.jar
	ZIP=$DIST/$ZIP
	BUILD=$DIST/$BUILDLOCAL
	EXEWIN=$DIST/bowlerstudio-$STUDIOVER.exe
	
	WINFINAL64=$DIST/Windows-64-BowlerStudio-$STUDIOVER.exe
	WINFINAL32=$DIST/Windows-32-BowlerStudio-$STUDIOVER.exe
	MACFINAL=$DIST/MacOSX-BowlerStudio-$STUDIOVER.zip
	DEBFINAL=$DIST/Ubuntu-BowlerStudio-$STUDIOVER.deb
	
    rm -rf $TL/$NRSDK/
	if(! test -d $TL/$NRSDK/); then  
		cd $TL/;
		git clone git@github.com:CommonWealthRobotics/bowler-script-kernel.git
		cd $TL/bowler-script-kernel/
		git submodule update --init --recursive
		git submodule update  --recursive
		
		gedit build.gradle
		git update-index --assume-unchanged build.gradle
		ln -s ~/gradle.properties .
		
		cd $TL/bowler-script-kernel/JCSG/
		gedit build.gradle
		git update-index --assume-unchanged build.gradle
		git update-index --assume-unchanged gradle.properties
		rm gradle.properties
		ln -s ~/gradle.properties .
		
		cd $TL/bowler-script-kernel/java-bowler/
		gedit build.gradle
		git update-index --assume-unchanged build.gradle
		ln -s ~/gradle.properties .
		
		cd $TL/bowler-script-kernel/
		env JAVA_HOME=/home/hephaestus/bin/java8/jre/ ./gradlew  --offline  shadowJar
		env JAVA_HOME=/home/hephaestus/bin/java8/jre/ ./gradlew uploadArchives
		
	fi
	cd $TL/$NRSDK/ 
	git pull --tags

	echo "   Checking out master"
	git stash -m"build"
	git checkout master
	echo "   Pull development"
	git pull origin development
	git push origin master
	git submodule update --init --recursive
	git submodule update  --recursive
	
	if(! test -d $TL/$NRConsole/); then  
		cd $TL/;
		git clone git@github.com:CommonWealthRobotics/BowlerStudio.git
		cd $TL/$NRConsole/
		git submodule update --init --recursive
		git submodule update  --recursive
	fi
	cd $TL/$NRConsole/
	git pull origin development
	if(! git checkout $STUDIOVER); then
		git tag -l
		echo "BowlerStudio $STUDIOVER Is not taged yet"
		exit 1;
	fi
	git submodule update --init --recursive
	git submodule update  --recursive
	
	cd $TL/$NRConsole/libraries/bowler-script-kernel/
	#env JAVA_HOME=/home/hephaestus/bin/java8/jre/ ./gradlew uploadArchives
	
	cd $TL/$NRSDK/;
	if(! test -e $LIB) then
		echo No kernel $LIB, building...

		env JAVA_HOME=/home/hephaestus/bin/java8/jre/ ./gradlew  --offline  shadowJar
	fi
	#exit 0
	if(! test -e $LIB) then
		echo ERROR!! expected lib file: $LIB 
		echo but none was found
		exit 1
	fi
	cd $TL/$NRConsole/;
	if( ! test -e $NRCONSOLE_JAR_FAT) then
		echo No application $NRCONSOLE_JAR_FAT, building...
		rm -rf $BOWLERSTUDIO_LOCATION/*.jar
		env JAVA_HOME=/home/hephaestus/bin/java8/jre/ ./gradlew  --offline  shadowJar
	fi
	if( ! test -e $NRCONSOLE_JAR_FAT) then
		echo ERROR!! expected lib file: $NRCONSOLE_JAR_FAT
		exit 1
	fi
	cd $START

	if(test -e $DIST) then
		echo build dir exists
	else
	
		#Build all depandancies

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
		cp $START/splash.* 						$BUILD/bin/
		#rsync -avtP --exclude=.svn* $TL/$NRSDK/target/docs 		$BUILD/java/
		#cp $START/index.html 							$BUILD/java/docs/api/
		#rsync -avtP --exclude=.svn* $TL/$NRSDK/target/docs				$DIST/java
		echo Copy OK
	
		cd $DIST
		zip -qq -r $ZIP $BUILDLOCAL
	fi
	echo "Begin uploading JAR" 
	cd $START/
	echo "Begin uploading binaries" 
	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $NRCONSOLE_JAR
	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $LIB
		
	if( test -z "$NOINST" ) then
		exit 0
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
		if ( test -e $DIST/*.deb) then
			rm $DIST/*.deb
		fi
		sh prep.sh $STUDIOVER
		mv $START/../installer-scripts/linux/*$STUDIOVER*.deb $DEBFINAL
 	fi

	if (test -s "$WINFINAL64" ) then	
		echo "Windows EXE exists $WINFINAL64 "
		ls -al  $WINFINAL64
	else

		echo Running wine
		cd $START/../installer-scripts/windows/
		bash prep.sh $STUDIOVER

	fi
	
	
	cd $START/
	echo "Begin uploading binaries" 
	#$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $NRCONSOLE_JAR

	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $DEBFINAL 
	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $MACFINAL 
	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $WINFINAL64 
	$JAVA_HOME/bin/java -jar GithubPublish.jar BowlerStudio CommonWealthRobotics $STUDIOVER $START/../installer-scripts/linux/build/bowlerstudio
	
	cd $START/
	bash updateVersion.sh $STUDIOVER $VERSION

	
	echo Cleanup $TL/$NRSDK/ 
	cd $TL/$NRSDK/ 
	git checkout development
	cd $TL/$NRConsole/
	git checkout development
	git commit -m"changelog" debian/changelog
	git push

	exit 0	
	
}

if ( test -n "$VERSION" ) then
	run $VERSION $STUDIOVER
fi
echo #####ERROR no version specified, I.E. 3.7.0
exit 1
