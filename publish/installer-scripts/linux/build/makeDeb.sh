DEPENDS='oracle-java8-set-default,libopencv2.4-java,libopencv2.4-jni,libjpeg62,slic3r'

sudo apt-get install checkinstall dh-make bzr-builddeb

#sudo checkinstall --requires $DEPENDS --conflicts 'modemmanager,nr-rdk-java' --replaces 'modemmanager,nr-rdk-java' --arch all --pkglicense Apache  --maintainer "Customer Support '<info@neuronrobotics.com>'" --install=yes -y

cd .. 

bzr dh-make bowlerstudio 2.7 hello-2.7.tar.gz
rm -f *ex *EX

pbuilder-dist xenial create

bzr whoami "Kevin Harrington <mad.hephaestus@gmail.com>"
bzr launchpad-login mad-hephaestus
