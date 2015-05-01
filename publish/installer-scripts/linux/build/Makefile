RDKINSTALL=/usr/local/NeuronRobotics/RDK/

install:
	if (test -d $(RDKINSTALL)); then echo "RDK exists, overwriting.."; else sudo mkdir -p $(RDKINSTALL); fi
	cp rdk.tar $(RDKINSTALL)
	chmod +x nr-*
	cp bowlerstudio /usr/bin/
	
	if(! test -d /usr/share/themes/base/neuronrobotics/icons/)then  mkdir -p /usr/share/themes/base/neuronrobotics/icons/; fi
	cp NeuronRobotics.png /usr/share/themes/base/neuronrobotics/icons/
	cp BowlerStudio.desktop /usr/share/applications/
	cp 80-neuronrobotics.rules /etc/udev/rules.d/
	service udev restart
	udevadm control --reload-rules
