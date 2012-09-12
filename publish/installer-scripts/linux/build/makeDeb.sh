DEPENDS='java-runtime'
sudo apt-get install checkinstall
sudo checkinstall --requires $DEPENDS --arch all --pkglicense Apache  --maintainer "Customer Support '<support@neuronrobotics.com>'" --install=yes -y


