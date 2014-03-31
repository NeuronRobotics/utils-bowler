#!/bin/bash

VERSION=$1
TOKEN=$2

if ( test -z "$TOKEN" ) then
	echo #####ERROR no Token
	exit 1
fi
if (! test -z "$VERSION" ) then
	#cp ../installer-scripts/windows/nrdk-$VERSION.exe $VERSION/

	curl -H "Authorization: token fb69cf95a0a7cd48206b6bef33d997e36730104b" \
	     -H "Content-Type: application/zip" \
	     --data-binary @$VERSION/nrdk-$VERSION.exe \
	     "https://uploads.github.com/repos/NeuronRobotics/java-bowler/releases/$VERSION/assets?name=Windows-nrdk-$VERSION.exe"

	#curl --form "fileupload=@$VERSION/nrdk-$VERSION.exe" https://uploads.github.com/repos/NeuronRobotics/java-bowler/releases/$VERSION/
	
	#Debian linux
	#s3cmd put 				--acl-public --guess-mime-type $VERSION/nr-rdk-java_$VERSION-1_all.deb 	s3://downloads.bowler.io/nrdk/$VERSION/nr-rdk-java_$VERSION-1_all.deb
	
	#windows
	#s3cmd put 				--acl-public --guess-mime-type $VERSION/nrdk-$VERSION.exe 				s3://downloads.bowler.io/nrdk/$VERSION/nrdk-$VERSION.exe
	#s3cmd put 				--acl-public --guess-mime-type dyio-drivers-1.0.1.exe 					s3://downloads.bowler.io/drivers/dyio-drivers-1.0.1.exe
	
	#zip file
	#s3cmd put 				--acl-public --guess-mime-type $VERSION/nrdk-$VERSION.zip 				s3://downloads.bowler.io/nrdk/$VERSION/nrdk-$VERSION.zip
	

else
	echo #####ERROR no version specified, I.E. 3.7.0
	exit 1
fi
