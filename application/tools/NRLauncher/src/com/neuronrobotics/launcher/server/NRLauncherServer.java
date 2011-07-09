package com.neuronrobotics.launcher.server;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.util.Enumeration;

import com.neuronrobotics.launcher.NRLauncher;


public class NRLauncherServer {
	
	private static String address;
	private  int port=8888;
	private ServerSocket tcpSock = null;
	private DataInputStream dis=null;
	private DataOutputStream dos=null;
	private TCPConnectionManager tcp = null;
	private ServerApp serve = null;
	
	public NRLauncherServer(NRLauncher l) throws IOException{
		setTCPSocket(port);
		tcp = new TCPConnectionManager(this);
		tcp.start();
		serve = new  ServerApp (l);
		serve.start();
	}


	public void kill(){
		if(tcp != null){
			tcp.kill();
			tcp=null;
		}
		if(serve != null){
			serve.kill();
			serve = null;
		}
		try{
			if(dos != null){
				dos.flush();
				dos.close();
				dos=null;
			}if(dis != null){
				dis.close();
				dis=null;
			}	
			if(tcpSock != null){
				tcpSock.close();
				tcpSock = null;
			}
		}catch(Exception e){

		}
	}
	private void setTCPSocket(int port) throws IOException{
		if(tcpSock != null){
			if(dos != null){
				dos.flush();
				dos.close();
				dos=null;
			}if(dis != null){
				dis.close();
				dis=null;
			}	
		}
		if(port != this.port){
			this.port = port;
			if(tcpSock != null){
				tcpSock.close();
				tcpSock = null;
			}
		}
		if(tcpSock == null){
			ServerSocket serverSocket = new ServerSocket(this.port);
			while(!serverSocket.isBound());
			tcpSock = serverSocket;
		}

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
	public static void main(String args []){
		System.out.println("Starting Launcher Server");
		try {
			NRLauncher l =new NRLauncher(args[0]);
			new NRLauncherServer(l);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(1);
		}
	}
	public Socket accept() throws IOException {
		if(tcpSock != null)
			return tcpSock.accept();
		return null;
	}
	public void setDataIns(DataInputStream dataInputStream) {
		if(serve!= null)
			serve.setDataIns(dataInputStream);
		dis=dataInputStream;	
	}
	public void setDataOuts(DataOutputStream dataOutputStream) {
		if(serve!= null)
			serve.setDataOuts(dataOutputStream);
		dos = dataOutputStream;
	}
}
