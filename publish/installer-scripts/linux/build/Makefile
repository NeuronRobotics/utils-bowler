RDKINSTALL=/usr/local/NeuronRobotics/RDK/
all:
	echo "OK"
install:
	if (test -d $(RDKINSTALL)/bin/); then echo "RDK exists, overwriting.."; else sudo mkdir -p $(RDKINSTALL)/bin/; fi
	cp ./bin/* $(RDKINSTALL)/bin/
	if (test -d $(RDKINSTALL)/firmware/); then echo "RDK exists, overwriting.."; else sudo mkdir -p $(RDKINSTALL)/firmware/; fi
	cp -rf ./firmware/* $(RDKINSTALL)/firmware/
	chmod +x ./bowlerstudio
	chmod +x ./BowlerStudio.desktop
	cp ./bowlerstudio /usr/bin/
	if(! test -d /usr/share/themes/base/neuronrobotics/icons/)then  mkdir -p /usr/share/themes/base/neuronrobotics/icons/; fi
	cp ./NeuronRobotics.png /usr/share/themes/base/neuronrobotics/icons/
	cp ./BowlerStudio.desktop /usr/share/applications/
	cp ./81-neuronrobotics.rules /etc/udev/rules.d/
	
