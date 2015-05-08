RDKINSTALL=/usr/local/NeuronRobotics/RDK/

install:
	if (test -d $(RDKINSTALL)); then echo "RDK exists, overwriting.."; else sudo mkdir -p $(RDKINSTALL); fi
	cp rdk.tar $(RDKINSTALL)
	chmod +x bowlerstudio
	chmod +x BowlerStudio.desktop
	chmod +x slic3r
	cp bowlerstudio /usr/bin/
	cp slic3r /usr/bin/
	
	if(! test -d /usr/share/themes/base/neuronrobotics/icons/)then  mkdir -p /usr/share/themes/base/neuronrobotics/icons/; fi
	cp NeuronRobotics.png /usr/share/themes/base/neuronrobotics/icons/
	cp BowlerStudio.desktop /usr/share/applications/
	cp 80-neuronrobotics.rules /etc/udev/rules.d/
	service udev restart
	udevadm control --reload-rules
	chmod 666 $(RDKINSTALL)/firmware/*.xml
