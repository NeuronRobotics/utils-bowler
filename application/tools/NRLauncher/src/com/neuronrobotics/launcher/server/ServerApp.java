package com.neuronrobotics.launcher.server;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import com.neuronrobotics.launcher.NRLauncher;


public class ServerApp extends Thread{
	private DataInputStream dis=null;
	private DataOutputStream dos=null;
	
	private String incoming;
	private byte [] b = new byte[1024];
	boolean run = true;
	NRLauncher launcher;
	private String header = "HTTP/1.0 200 OK\r\n"+
							"Content-Type: text/html; charset=ISO-8859-1\r\n"+
							"Content-Length: ";
	
	public ServerApp(NRLauncher l) {
		launcher = l;
	}

	public void run(){
		//System.out.println("Server starting");
		while(run){
			if(dis != null && dos != null) {
				try {
					if(dis.available()>0) {
						dis.read(b);
						incoming = new String(b);
						System.out.println("Server got:\r\n"+incoming);
						if(incoming.contains("GET /")) {
							//System.out.println("Sending Image:\r\n"+incoming);
							while(dis.available()>0)
								dis.read(b);

						}else {
							System.out.println("Not a refresh:\r\n"+incoming);
						}
						System.out.println("Server sending:\r\n"+getContent());	
						dos.writeBytes(getContent());
						dos.flush();
					}
				} catch (IOException e) {
				}
			}
			try {
				Thread.sleep(50);			
			} catch (InterruptedException e) {
			}
		}
		//System.out.println("Server ending");
	}
	
	public String getContent(){
		String b = getBody();
		return header+b.length()+"\r\n\r\n"+b;
	}
	public String getBody(){
		String s="";
		InputStream is = ServerApp.class.getResourceAsStream( "template.html");
		BufferedReader br = new BufferedReader(new InputStreamReader(is));
		String line;
		try {
			while (null != (line = br.readLine())) {
			     s+=line+"\r\n";
			}
		} catch (IOException e) {
		}

		return	s;
	}

	public void kill(){
		run = false;
	}
	public void setDataIns(DataInputStream dataInputStream) {
		dis=dataInputStream;	
	}
	public void setDataOuts(DataOutputStream dataOutputStream) {
		dos = dataOutputStream;
	}
}
