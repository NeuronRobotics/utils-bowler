#!/bin/bash

START=$PWD
VERSION=$1
if (! test -z "$VERSION" ) then
	rm -rf rdk
	rm -rf nr_rdk_java-$VERSION
	
	mkdir rdk
	unzip -qq nrdk-*.zip -d rdk
	unzip -qq ~/git/ZipArchive/mac/opencv249build.zip -d rdk/
	unzip -qq ~/git/ZipArchive/linux/Slic3r.app.zip -d rdk/
	chmod +x BowlerStudio
	cp BowlerStudio rdk/

	mv rdk/nrdk-*/* rdk/
	rm -rf rdk/nrdk-*
	rm nrdk-*.zip
	
	zip -r mac-$VERSION.zip rdk

fi
