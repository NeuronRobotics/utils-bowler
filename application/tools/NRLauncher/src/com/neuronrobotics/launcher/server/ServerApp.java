package com.neuronrobotics.launcher.server;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

public class ServerApp extends Thread{
	private DataInputStream dis=null;
	private DataOutputStream dos=null;
	
	private String incoming;
	private byte [] b = new byte[1024];
	boolean run = true;
	
	private String header = "HTTP/1.0 200 OK\r\n"+
							"Content-Type: text/html; charset=ISO-8859-1\r\n"+
							"Content-Length: ";
	
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
							
							System.out.println("Server sending:\r\n"+getContent());	
							dos.writeBytes(getContent());
							dos.flush();

						}else {
							//System.out.println("Fail:\r\n"+incoming);
						}
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
		return	"<html><head>\r\n"+
				"<title>200 Ok</title>\r\n"+
				"</head><body>\r\n"+
				"<h1>200 ok</h1>\r\n"+
				"<p>Everything is ok<br />\r\n"+
				"</p>\r\n"+
				"<hr>\r\n"+
				"</body></html>\r\n";
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
