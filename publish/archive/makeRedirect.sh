#!/bin/bash

VERSION=$1

if (! test -z "$VERSION" ) then
	
	echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
	<HTML>
	<HEAD>
	<title>Neuron Robotics Documentation</title>
	<meta http-equiv="REFRESH" content="0;url=http://downloads.bowler.io/nrdk/'$VERSION'/java/docs/api/index.html">
	</HEAD>
	</HTML>' > current2.html
	cat current2.html
	cp index.html $VERSION/java/docs/api
fi

