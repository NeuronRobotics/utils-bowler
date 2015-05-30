#!/bin/bash

START=$PWD
VERSION=$1
if (! test -z "$VERSION" ) then
	rm -rf rdk
	rm -rf bowlerstudio-$VERSION
	
	mkdir rdk
	unzip -qq bowlerstudio-*.zip -d rdk
	unzip -qq ~/git/ZipArchive/mac/opencv249build.zip -d rdk/
	unzip -qq ~/git/ZipArchive/mac/Slic3r.app.zip -d rdk/
	chmod +x BowlerStudio
	cp BowlerStudio rdk/

	mv rdk/bowlerstudio-*/* rdk/
	rm -rf rdk/bowlerstudio-*
	rm *.zip
	
	zip  -qq -r mac-$VERSION.zip rdk

fi
