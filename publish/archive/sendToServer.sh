#!/bin/bash

export VERSION=$1
export GH_TOKEN=$2
export GH_PROJECT=java-bowler

# sudo apt-get install ruby1.9.3
# sudo gem install octokit

if ( test -z "$2" ) then
	echo #####ERROR no Token
	exit 1
fi
if (! test -z "$1" ) then
	#cp ../installer-scripts/windows/nrdk-$VERSION.exe $VERSION/
	ruby ghupload.rb

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
