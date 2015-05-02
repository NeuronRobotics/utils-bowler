#!/bin/bash

START=$PWD
VERSION=$1
if (! test -z "$VERSION" ) then
	rm -rf rdk
	rm -rf nr_rdk_java-$VERSION
	
	mkdir rdk
	unzip -qq nrdk-*.zip -d rdk
	unzip -qq ~/git/ZipArchive/linux/Slic3r_x64.zip -d rdk/Slic3r_x64/
	unzip -qq ~/git/ZipArchive/linux/Slic3r_x86.zip -d rdk/Slic3r_x86/

	mv rdk/nrdk-*/* rdk/
	rm -rf rdk/nrdk-*
	
	tar cf build/rdk.tar rdk/ --exclude-vcs --exclude=.DS_Store --exclude=__MACOSX
	
	if (test -e rdk/java/nrsdk-$VERSION-jar-with-dependencies.jar) then
		BUILD=nr_rdk_java-$VERSION
		echo Build = $BUILD
		BUILDDIR=$PWD/$BUILD/
		if (test -d $BUILDDIR) then 
			echo "$BUILDDIR exists";
			exit 1
		else
			echo "Making $BUILDDIR"
			mkdir $BUILDDIR
		fi
		rm -rf $BUILDDIR*
		cp -r build/* $BUILDDIR/
		chmod +x $BUILDDIR/*-pak
		rm -rf $BUILDDIR/doc-pak/.svn/
		
		sudo rm  /usr/lib/libbluetooth.so
		
		cd $BUILDDIR/;sudo sh makeDeb.sh;cd ..
		
		cp $BUILDDIR/*.deb $BUILDDIR/../
		
		echo "Cleaning up the directory.."
		rm -rf rdk
		
		rm build/rdk.tar
		
		rm -rf $BUILDDIR
		
		echo Done!
	
	else
		echo "No jar found"
		exit 1
	fi
fi
