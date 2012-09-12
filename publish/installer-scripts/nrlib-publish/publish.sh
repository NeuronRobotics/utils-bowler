#!/bin/bash

if (test -d public) then
	echo "public Already there"
else
	mkdir public
fi


cd public/

if (test -d nrlib) then
	rm -rf nrlib
fi
svn checkout --username kharrington https://dev.neuronrobotics.com/svn/public/nrlib
if (test -d nrlib) then
	echo "nrlib ok"
else
	echo "REPO is currupt!"
	exit 1
fi
cd nrlib

if (test -d NRLIB) then
	svn delete *
	svn commit -m "cleaning out old nrlib"
fi

svn update

svn export https://dev.neuronrobotics.com/svn/development/trunk/firmware/nrlib/NRLIB 
svn export https://dev.neuronrobotics.com/svn/development/trunk/firmware/nrlib/PIC32USB

svn add *

svn commit -m "Publishing NRLIB dirs"

svn add NRLIB/lib/*/*/*.a

svn commit -m "Publishing NRLIB .a's"

echo "Cleanup..$PWD"
cd ../..
rm -rf public


