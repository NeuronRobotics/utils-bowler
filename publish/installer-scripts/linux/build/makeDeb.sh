DEPENDS='openjdk-8-jdk,openjfx'
sudo apt-get install checkinstall
sudo checkinstall --requires $DEPENDS --conflicts 'modemmanager' --arch all --pkglicense Apache  --maintainer "Customer Support '<info@neuronrobotics.com>'" --install=yes -y


