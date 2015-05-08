DEPENDS='openjdk-8-jdk,openjfx,libopencv2.4-java,libopencv2.4-jni'
sudo apt-get install checkinstall
sudo checkinstall --requires $DEPENDS --remove 'modemmanager' --arch all --pkglicense Apache  --maintainer "Customer Support '<info@neuronrobotics.com>'" --install=yes -y


