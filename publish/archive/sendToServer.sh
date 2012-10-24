#!/bin/bash

VERSION=$1

if (! test -z "$VERSION" ) then
	sudo apt-get install s3cmd
	#cp ../installer-scripts/windows/nrdk-$VERSION.exe $VERSION/
	svn commit -m="$VERSION committing"

	sh makeRedirect.sh $VERSION

	s3cmd put 				--acl-public --guess-mime-type current.html 	s3://downloads.bowler.io/nrdk/current.html
	
	
	#Debian linux
	s3cmd put 				--acl-public --guess-mime-type $VERSION/nr-rdk-java_$VERSION-1_all.deb 	s3://downloads.bowler.io/nrdk/$VERSION/nr-rdk-java_$VERSION-1_all.deb
	
	#windows
	s3cmd put 				--acl-public --guess-mime-type $VERSION/nrdk-$VERSION.exe 				s3://downloads.bowler.io/nrdk/$VERSION/nrdk-$VERSION.exe
	s3cmd put 				--acl-public --guess-mime-type dyio-drivers-1.0.1.exe 					s3://downloads.bowler.io/drivers/dyio-drivers-1.0.1.exe
	
	#zip file
	s3cmd put 				--acl-public --guess-mime-type $VERSION/nrdk-$VERSION.zip 				s3://downloads.bowler.io/nrdk/$VERSION/nrdk-$VERSION.zip
	

	#Docs
	s3cmd put --recursive 	--acl-public --guess-mime-type $VERSION/java/ 							s3://downloads.bowler.io/nrdk/$VERSION/java/
else
	echo #####ERROR no version specified, I.E. 3.7.0
	exit 1
fi
