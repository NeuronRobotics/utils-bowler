#!/bin/bash

START=$PWD
VERSION=$1
TARBALL=$START/rdk.tar.gz
RDKINSTALL=/usr/share/bowlerstudio/
#packaging info from http://xmodulo.com/how-to-create-deb-debian-package-for-java-web-application.html

if (! test -z "$VERSION" ) then
	sudo rm -rf rdk
	sudo rm -rf bowlerstudio-$VERSION
	
	mkdir rdk
	unzip -qq bowlerstudio-*.zip -d rdk
	#unzip -qq ~/git/ZipArchive/linux/Slic3r_x64.zip -d rdk/Slic3r_x64/
	#unzip -qq ~/git/ZipArchive/linux/Slic3r_x86.zip -d rdk/Slic3r_x86/

	mv $START/rdk/bowlerstudio-*/* $START/rdk/
	#rm -rf rdk/bowlerstudio-*
	
	sudo rm -rf bowlerstudio
	sudo rm -rf bowlerstudio-$VERSION
	rm -rf bowlerstudio_$VERSION.orig.tar.gz
	rm -rf $TARBALL
	rm -rf *.deb
	if (test -e rdk/bin/BowlerStudio.jar) then
		mkdir -p $START/rdk/usr/share/bowlerstudio/
		mkdir -p $START/rdk/usr/share/doc/bowlerstudio/
		mkdir -p $START/rdk/usr/bin/
		cp $START/build/LICENSE.txt $START/rdk/usr/share/doc/bowlerstudio/copyright
		cp $START/build/81-neuronrobotics.rules $START/rdk/usr/share/bowlerstudio/
		cp $START/build/bowlerstudio $START/rdk/usr/bin/
		cp $START/build/BowlerStudio.desktop $START/rdk/usr/share/bowlerstudio/
		cd $START/rdk/
		rm LICENSE.txt
		rm README.txt
		mv firmware/ usr/share/bowlerstudio/
		mv bin/* usr/share/bowlerstudio/
		
		tar -czf $TARBALL -C $START/rdk/ . --exclude-vcs --exclude=.DS_Store --exclude=__MACOSX
		cd $START
		#sudo apt-get install python-enum34
		#sudo apt-get install checkinstall dh-make bzr-builddeb autoproject git-buildpackage

		#pbuilder-dist xenial create # only needed once
		
		bzr whoami "Kevin Harrington <mad.hephaestus@gmail.com>"
		bzr launchpad-login mad-hephaestus
		
		bzr dh-make bowlerstudio $VERSION $TARBALL
		cd $START/bowlerstudio
		bzr init
		echo "7" > debian/compat
		#mkdir -p debian/source/
		#echo "3.0" > debian/source/format
		#bzr add debian/source/format
		rm -f debian/*.ex
		sed -e s/BOWLERVERSION/$VERSION/g $START/build/control > debian/control
		
		grep -v makefile debian/rules > debian/rules.temp
		mv debian/rules.temp debian/rules
		
		echo usr/share/bowlerstudio/BowlerStudio.jar $RDKINSTALL > debian/install
		echo usr/share/bowlerstudio/NeuronRobotics.ico $RDKINSTALL >> debian/install
		echo usr/share/bowlerstudio/NeuronRobotics.png $RDKINSTALL >> debian/install
		echo usr/share/bowlerstudio/dyio-3.14.6.xml $RDKINSTALL >> debian/install
		echo usr/bin/bowlerstudio /usr/bin/ >> debian/install
		echo usr/share/bowlerstudio/NeuronRobotics.png /usr/share/themes/base/neuronrobotics/icons/ >> debian/install
		echo usr/share/bowlerstudio/BowlerStudio.desktop /usr/share/applications/ >> debian/install
		echo usr/share/bowlerstudio/81-neuronrobotics.rules /etc/udev/rules.d/ >> debian/install
		echo usr/share/doc/bowlerstudio/copyright /usr/share/doc/bowlerstudio/ >> debian/install
		echo usr/share/doc/bowlerstudio/changelog.gz /usr/share/doc/bowlerstudio/ >> debian/install
		#create the change log
		cp $START/build/rules  debian/rules
		cd ~/git/BowlerStudio/
		gbp dch --ignore-branch --snapshot --auto --git-author
		cd $START/bowlerstudio
		#place the change log in the build dir
		cp ~/git/BowlerStudio/debian/changelog $START/bowlerstudio/debian/changelog
		gzip -9 $START/bowlerstudio/debian/changelog
		cp ~/git/BowlerStudio/debian/changelog $START/bowlerstudio/debian/changelog
		cp $START/bowlerstudio/debian/changelog.gz $START/bowlerstudio/usr/share/doc/bowlerstudio/
		
		bzr commit -m "Initial commit of Debian packaging."
		rm -rf bowlerstudio-$VERSION
		rm -rf bin/
		rmdir debian/source/
		find $START/bowlerstudio/ -type d -exec  chmod 755 {} \;
		find $START/bowlerstudio/ -type f -exec  chmod 644 {} \;
		sudo chown -R root:root ./
		sudo chmod +x usr/bin/bowlerstudio
		sudo chmod +x usr/share/bowlerstudio/BowlerStudio.jar
		sudo chmod +x usr/share/bowlerstudio/BowlerStudio.desktop
		
		# build the debian file
		bzr builddeb -S

		lintian bowlerstudio.deb
		echo "Installing built package"
		sudo dpkg --install *.deb
		ls -al /usr/bin/bowlerstudio
		echo "Cleaning up the directory.."
		sudo rm -rf rdk
		
		#rm build/rdk.tar
		#rm *.zip
		
		#rm -rf $BUILDDIR
		
		echo Done!
	
	else
		echo "No jar found"
		exit 1
	fi
fi
