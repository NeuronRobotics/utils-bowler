DEPENDS='openjdk-8-jdk,openjfx,libopencv2.4-java,libopencv2.4-jni,libjpeg62,slic3r'
sudo apt-get install checkinstall
sudo checkinstall --requires $DEPENDS --conflicts 'modemmanager,nr-rdk-java' --replaces 'modemmanager,nr-rdk-java' --arch all --pkglicense Apache  --maintainer "Customer Support '<info@neuronrobotics.com>'" --install=yes -y


