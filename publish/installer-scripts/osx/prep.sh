#!/bin/bash

START=$PWD
VERSION=$1
DIR=bowlerstudio-$VERSION
if (! test -z "$VERSION" ) then
	rm -rf $DIR
	
	mkdir $DIR
	cp -r BowlerStudio.app $DIR/
	unzip -qq bowlerstudio-*.zip -d $DIR/BowlerStudio.app/Contents/MacOS/
	mv $DIR/BowlerStudio.app/Contents/MacOS/$DIR/* $DIR/BowlerStudio.app/Contents/MacOS/

	unzip -qq ~/git/ZipArchive/mac/opencv249build.zip -d $DIR/BowlerStudio.app/Contents/MacOS/
	unzip -qq ~/git/ZipArchive/mac/Slic3r.app.zip -d $DIR/
	chmod +x $DIR/BowlerStudio.app/Contents/MacOS/BowlerStudio
	rm *.zip
	cp $2 $DIR/
	
	zip  -qq -r mac-$VERSION.zip $DIR
	rm -rf $DIR/

fi
