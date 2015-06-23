#!/bin/bash

START=$PWD
VERSION=$1
if (! test -z "$VERSION" ) then
	rm -rf rdk
	rm -rf bowlerstudio-$VERSION
	
	mkdir rdk
	cp -r BowlerStudio.app rdk/
	unzip -qq bowlerstudio-*.zip -d rdk/BowlerStudio.app/Contents/MacOS/
	unzip -qq ~/git/ZipArchive/mac/opencv249build.zip -d rdk/BowlerStudio.app/Contents/MacOS/
	unzip -qq ~/git/ZipArchive/mac/Slic3r.app.zip -d rdk/
	chmod +x BowlerStudio
	cp BowlerStudio rdk/BowlerStudio.app/Contents/MacOS/

	rm -rf rdk/bowlerstudio-*
	rm *.zip
	
	zip  -qq -r mac-$VERSION.zip rdk
	rm -rf rdk/

fi
