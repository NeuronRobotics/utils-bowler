package com.neuronrobotics.launcher.server;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import com.neuronrobotics.launcher.NRLauncher;
import com.neuronrobotics.sdk.common.ByteList;


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
						ByteList bl = new ByteList();
						do{
							int read = dis.read(b);
							for(int i=0;i<read;i++){
								bl.add(b[i]);
							}
						}while(dis.available()>0);
						incoming = new String(bl.getBytes());
						
						//System.out.println("Server got:\r\n"+incoming);
						if(incoming.contains("GET /")) {

						}else if(incoming.contains("POST /control")){
							System.out.println(incoming);
						}else if(incoming.contains("POST /upload")){
							int headIndex = incoming.indexOf("\r\n\r\n")+4;

							int bodyIndex = incoming.substring(headIndex).indexOf("\r\n\r\n")+2+headIndex;
							byte [] jar = bl.getBytes(bodyIndex);
							String head = incoming.substring(0,bodyIndex);
							System.out.println("Jar length: "+jar.length);
							System.out.println("##Upload is coming: \n"+head);
							int startOfFileName = head.indexOf("filename=\"")+"filename=\"".length();
							int endOfFilename  = head.indexOf("filename=\"");
							String fileName = head.substring(startOfFileName,endOfFilename);
							FileOutputStream fos = new FileOutputStream(launcher.getWindow().getLaunchDirectory()+"/uploaded.jar");
							fos.write(jar);
							fos.flush();
							fos.close(); 
							
						}else{
							System.out.println(incoming);
						}
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
		
		try {
			InputStream is = ServerApp.class.getResourceAsStream( "template.html");
			BufferedReader br = new BufferedReader(new InputStreamReader(is));
			String line;
			while (null != (line = br.readLine())) {
			     s+=line+"\r\n";
			}
		} catch (Exception e) {
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
