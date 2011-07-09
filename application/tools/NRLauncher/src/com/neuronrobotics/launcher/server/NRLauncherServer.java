package com.neuronrobotics.launcher.server;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.URL;
import java.util.Enumeration;

public class NRLauncherServer {
	
	private static String address;
	private  int port=80;
	public NRLauncherServer(){
		
	}
	public static  URL getURL(){
		
		URL url=null;
		try{
	        @SuppressWarnings("rawtypes")
			Enumeration e = NetworkInterface.getNetworkInterfaces();
	        while(e.hasMoreElements()){
	        	NetworkInterface ni =(NetworkInterface)  e.nextElement();
		        @SuppressWarnings("rawtypes")
				Enumeration e2 = ni.getInetAddresses();
		        while(e2.hasMoreElements()){
		        	InetAddress ip = (InetAddress) e2.nextElement();
		        	if(!(ip.isAnyLocalAddress() || ip.isLinkLocalAddress()||ip.isLoopbackAddress()||ip.isMulticastAddress()))
		        		address="http://"+ip.getHostAddress()+"/"; 
		        }
	        }
	       url = new URL(address);
		}catch(Exception e){}
		return url;
	}
	public static String getURLString(){
		getURL();
		return address;
	}
	public void main(String args []){
		System.out.println("Starting Launcher Server");
		new NRLauncherServer();
	}
}
