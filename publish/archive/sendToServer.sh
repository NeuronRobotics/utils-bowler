#!/bin/bash

export VERSION=$1
export GH_PROJECT=java-bowler

# sudo apt-get install ruby1.9.3
# sudo gem install octokit

if ( test -z "$GH_TOKEN" ) then
	echo #####ERROR no Token
	exit 1
fi
if (! test -z "$1" ) then
	echo Sending to Github
	ruby ghupload.rb

else
	echo #####ERROR no version specified, I.E. 3.7.0
	exit 1
fi
