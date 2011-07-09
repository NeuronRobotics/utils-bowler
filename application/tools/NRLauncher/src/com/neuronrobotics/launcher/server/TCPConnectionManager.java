package com.neuronrobotics.launcher.server;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class TCPConnectionManager extends Thread {
	private Socket connectionSocket=null;
	boolean run = true;
	NRLauncherServer application;		
	public TCPConnectionManager(NRLauncherServer app){
		application=app;
	}
	
	public void run(){
		//System.out.println("Connection listener starting");
		while(run){
			try {
				connectionSocket = application.accept();
				application.setDataIns(new DataInputStream(connectionSocket.getInputStream()));
				application.setDataOuts(new DataOutputStream(connectionSocket.getOutputStream()));
			} catch (Exception e1) {

			}
		}
		try {
			connectionSocket.close();
		} catch (IOException e) {
		}
		//System.out.println("Connection listener ending");
	}
	public void kill(){
		run = false;
	}
}
