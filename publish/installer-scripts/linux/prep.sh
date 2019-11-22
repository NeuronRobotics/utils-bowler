#!/bin/bash

START=$PWD
VERSION=$1
TARBALL=$START/rdk.tar.gz
RDKINSTALL=/usr/share/bowlerstudio/
#packaging info from http://xmodulo.com/how-to-create-deb-debian-package-for-java-web-application.html
BUILDIR=$START/bowlerstudio_$VERSION/
sudo dpkg --add-architecture i386
sudo apt-get install git-buildpackage bzr-builddeb dh-make bzr  unzip
DEBEMAIL="mad.hephaestus@gmail.com"
DEBFULLNAME="Kevin Harrington"
export DEBEMAIL DEBFULLNAME
dh_make -e mad.hephaestus@gmail.com
if (! test -z "$VERSION" ) then
	sudo rm -rf rdk
	sudo rm -rf $START/bowlerstudio/
	sudo rm -rf $BUILDIR
	sudo rm -rf $START/*.dsc
	sudo rm -rf $START/*.changes
	sudo rm -rf $START/*.build	
	sudo rm -rf $START/*.gz
	sudo rm -rf $START/*.xz
	sudo rm -rf $START/debian
	sudo rm -rf $START/usr
	sudo rm -rf $START/.bzr
	sudo rm -rf $TARBALL
	sudo rm -rf *.deb
	cd ~/git/BowlerStudio/
	echo "Building change log"
	gbp dch --ignore-branch  --release --new-version=$VERSION --auto --git-author
	sed -i.bak s/'madhephaestus'/'Kevin Harrington'/g ~/git/BowlerStudio/debian/changelog
	sed -i.bak s/'UNRELEASED'/xenial/g ~/git/BowlerStudio/debian/changelog
	cd  $START/
	mkdir rdk
	echo "Loading Jar"
	unzip -qq $PWD/../../archive/$VERSION/bowlerstudio-$VERSION.zip -d rdk
	#unzip -qq ~/git/ZipArchive/linux/Slic3r_x64.zip -d rdk/Slic3r_x64/
	#unzip -qq ~/git/ZipArchive/linux/Slic3r_x86.zip -d rdk/Slic3r_x86/
	echo "Adjusting up directory"
	mv $START/rdk/bowlerstudio-*/* $START/rdk/
	#rm -rf rdk/bowlerstudio-*
	mkdir -p $START/rdk/usr/share/bowlerstudio/
	mkdir -p $START/rdk/usr/share/doc/bowlerstudio/
	mkdir -p $START/rdk/usr/bin/
	mkdir -p $START/rdk/usr/share/applications/
	mkdir -p $START/rdk/usr/share/themes/base/bowlerstudio/icons/
	mkdir -p $START/rdk/etc/udev/rules.d/
	
	
	cp $START/build/LICENSE.txt $START/rdk/usr/share/doc/bowlerstudio/copyright
	cp $START/build/81-neuronrobotics.rules $START/rdk/etc/udev/rules.d/
	cp $START/build/bowlerstudio $START/rdk/usr/bin/
	cp $START/build/BowlerStudio.desktop $START/rdk/usr/share/applications/
	cp ~/git/BowlerStudio/debian/changelog $START/rdk/usr/share/doc/bowlerstudio/
	gzip -9 $START/rdk/usr/share/doc/bowlerstudio/changelog
	cd $START/rdk/
	rm LICENSE.txt
	rm README.txt

	rm -rf firmware/
	echo "Moving Jar to the jar directory"
	cp bin/BowlerStudio.jar $START/rdk/usr/share/bowlerstudio/
	cp bin/splash.png $START/rdk/usr/share/themes/base/bowlerstudio/icons/
	rm  -rf bowlerstudio-*
	rm  -rf bin

	find $START/rdk/ -type d -exec  chmod 755 {} \;
	find $START/rdk/ -type f -exec  chmod 644 {} \;
	chmod +x usr/bin/bowlerstudio
	#chmod +x usr/share/bowlerstudio/BowlerStudio.jar
	rm usr/share/bowlerstudio/BowlerStudio.jar
	chmod +x usr/share/applications/BowlerStudio.desktop
	tar -czf $TARBALL -C $START/rdk/ . --exclude-vcs --exclude=.DS_Store --exclude=__MACOSX
	cd $START
	#sudo apt-get install python-enum34
	#sudo apt-get install checkinstall dh-make bzr-builddeb autoproject git-buildpackage arduino-ide

	#pbuilder-dist xenial create # only needed once
	alias dh-make=dh_make
	bzr whoami "Kevin Harrington <mad.hephaestus@gmail.com>"
	bzr launchpad-login mad-hephaestus

	bzr dh-make bowlerstudio $VERSION $TARBALL
	mv bowlerstudio $BUILDIR
	if cd $BUILDIR; then
		
		cd $BUILDIR
		#bzr init
		mkdir -p debian/source/
		echo "7" > debian/compat
		echo "2.0\n" > debian/debian-binary
		echo "1.0" > debian/source/format
	
		#mkdir -p debian/source/
		echo "3.0 (native)" > debian/source/format
		#bzr add debian/source/format
		rm -f debian/*.ex
		rm -f debian/*.EX
		rm debian/control
		sed -e s/BOWLERVERSION/$VERSION/g $START/build/control > debian/control
		cp ~/git/BowlerStudio/debian/changelog $BUILDIR/debian/changelog
		gzip -9 $BUILDIR/debian/changelog
		cp ~/git/BowlerStudio/debian/changelog $BUILDIR/debian/changelog
		
		echo "\n" >> $BUILDIR/debian/changelog
	
		#echo usr/share/bowlerstudio/BowlerStudio.jar $RDKINSTALL > debian/install
		echo usr/bin/bowlerstudio /usr/bin/ >> debian/install
		echo usr/share/themes/base/bowlerstudio/icons/splash.png /usr/share/themes/base/bowlerstudio/icons/ >> debian/install
		echo usr/share/applications/BowlerStudio.desktop /usr/share/applications/ >> debian/install
		echo etc/udev/rules.d/81-neuronrobotics.rules /etc/udev/rules.d/ >> debian/install
		echo usr/share/doc/bowlerstudio/copyright /usr/share/doc/bowlerstudio/ >> debian/install
		echo usr/share/doc/bowlerstudio/changelog.gz /usr/share/doc/bowlerstudio/ >> debian/install
		#create the change log
		cp $START/build/rules  debian/rules

		cd $BUILDIR
		#place the change log in the build dir
		
		cp ~/git/BowlerStudio/debian/changelog $BUILDIR/debian/changelog
		#echo 'usr/share/bowlerstudio/BowlerStudio.jar' > debian/source/include-binaries
		echo 'usr/share/themes/base/bowlerstudio/icons/splash.png' >> debian/source/include-binaries
		echo 'usr/share/doc/bowlerstudio/changelog.gz' >> debian/source/include-binaries

		find debian/ -type d -exec  chmod 755 {} \;
		find debian/ -type f -exec  chmod 644 {} \;
		cd $BUILDIR
		echo "\n\nRunning  dpkg-source... "
		if dpkg-source --commit --include-binaries; then
			echo " dpkg-source  --commit success! "
		else
			echo " dpkg-source  --commit  ERROR! $PWD"
			exit 1
		fi
		cd $BUILDIR/../
		if dpkg-source -b $BUILDIR; then
			echo " dpkg-source  -b success! "
		else
			echo " dpkg-source -b  ERROR! "
			exit 1
		fi
		cd $BUILDIR
		bzr commit -m "Initial commit of Debian packaging."
		# build the debian file
#		bzr builddeb -S
		#debchange --newversion $VERSION
		gpg --import ~/.gnupg/secring.gpg 
		gpg --import ~/.gnupg/pubring.gpg
		if debuild -S -kFA7BCDE0; then
			echo "Attepmting to publish"
			cd $BUILDIR/../
			dput ppa:mad-hephaestus/commonwealthrobotics *.changes
			cd $BUILDIR
		## Now build the binary package
			echo "Building binary..."
			mv debian/ DEBIAN/ 
			rm -rf  DEBIAN/source/
			rm -rf  DEBIAN/control
			rm -rf  DEBIAN/README.*		
			
		
			sudo sed -e s/BOWLERVERSION/$VERSION/g $START/build/BINARYcontrol > DEBIAN/control
			#debchange --newversion $VERSION
			sudo chown -R root:root ./
			cd ../

			sudo dpkg --build $BUILDIR
	
			lintian bowlerstudio*.deb
			echo "Installing built package"
			sudo dpkg --install bowlerstudio*.deb
			sudo chown -R 1000:1000 $BUILDIR
			ls -al /usr/bin/bowlerstudio
			mv bowlerstudio_$VERSION.deb Ubuntu-BowlerStudio-$VERSION.deb
			echo "Cleaning up the directory.."
			sudo rm -rf rdk
			sudo rm -rf $START/bowlerstudio*
			sudo rm rdk.tar.gz
			#rm build/rdk.tar
			#rm *.zip
	
			#rm -rf $BUILDDIR
	
			echo Done!
		fi
	fi
	
fi