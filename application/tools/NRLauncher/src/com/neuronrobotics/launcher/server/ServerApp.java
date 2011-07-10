package com.neuronrobotics.launcher.server;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.StringTokenizer;

import com.neuronrobotics.launcher.NRLauncher;
import com.neuronrobotics.sdk.common.ByteList;
import com.neuronrobotics.sdk.util.ThreadUtil;


public class ServerApp extends Thread{
	private DataInputStream dis=null;
	private DataOutputStream dos=null;
	
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
							bl.add(dis.read());
						}while(dis.available()>0);
						
						String currentLine = null, filename = null, contentLength = null;
						PrintWriter fout = null;
						BufferedReader inFromClient = new BufferedReader(new InputStreamReader (new ByteArrayInputStream(bl.getBytes())));						
						currentLine = inFromClient.readLine();

						System.out.println(currentLine);
						

						if(currentLine .contains("GET /")) {

						}else if(currentLine .contains("POST /control")){
							System.out.println(currentLine );
						}else if(currentLine.contains("POST /upload")){
							System.out.println("POST request"); 
							boolean haveLen = false;
							boolean haveBound = false;
							boolean haveName = false;
							String boundary="";
							do {
								currentLine = inFromClient.readLine();
								if(currentLine.indexOf("Content-Length:") != -1){
						    		contentLength = currentLine.split(" ")[1];
							  		System.out.println("Content Length = " + contentLength);
							  		haveLen=true;
						    	}
						    	if(currentLine.indexOf("Content-Type: multipart/form-data") != -1){
						    		boundary = currentLine.split("boundary=")[1];
						    		haveBound=true;
						    	}
								if (currentLine.indexOf("--" + boundary) != -1) {
									filename = inFromClient.readLine().split("filename=")[1].replaceAll("\"", ""); 				  			 		
									String [] filelist = filename.split("\\" + System.getProperty("file.separator"));
									filename = filelist[filelist.length - 1];				  		
									System.out.println("File to be uploaded = " + filename);
									break;
								}
							}while((!haveBound && !haveLen & !haveName) && inFromClient.ready());

//							do{
//							    if ((currentLine.indexOf("Content-Type: multipart/form-data") != -1) || (currentLine.indexOf("Content-Length:") != -1))  {
//							    	
//				  			 
//							    	if( !(haveBound && haveLen)){
//							    		break;
//							    	}
//								  
//								  
//									while (true) {
//										currentLine = inFromClient.readLine();
//										if (currentLine.indexOf("--" + boundary) != -1) {
//											filename = inFromClient.readLine().split("filename=")[1].replaceAll("\"", ""); 				  			 		
//											String [] filelist = filename.split("\\" + System.getProperty("file.separator"));
//											filename = filelist[filelist.length - 1];				  		
//											System.out.println("File to be uploaded = " + filename);
//											break;
//										}				  	
//									}
//
//									String fileContentType = inFromClient.readLine().split(" ")[1];
//									System.out.println("File content type = " + fileContentType);
//
//									inFromClient.readLine(); //assert(inFromClient.readLine().equals("")) : "Expected line in POST request is "" ";
//									
//									fout = new PrintWriter(launcher.getWindow().getLaunchDirectory()+"/UPLOADED_"+filename);
//									String prevLine = inFromClient.readLine();
//									currentLine = inFromClient.readLine();			  
//									
//									//Here we upload the actual file contents
//									while (true) {
//										if (currentLine.equals("--" + boundary + "--")) {
//											fout.print(prevLine);
//											break;
//										}
//										else {
//											fout.println(prevLine);
//										}	
//										prevLine = currentLine;			  		
//										currentLine = inFromClient.readLine();
//									}
//									fout.close();				   
//								} else{
//									//System.out.println(currentLine);
//								}
//							}while (inFromClient.ready()); //End of do-while 
							System.out.println("File uploaded!");
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
