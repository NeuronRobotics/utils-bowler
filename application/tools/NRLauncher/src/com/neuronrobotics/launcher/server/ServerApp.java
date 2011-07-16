package com.neuronrobotics.launcher.server;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.StringTokenizer;

import com.neuronrobotics.launcher.NRLauncher;
import com.neuronrobotics.sdk.common.ByteList;
import com.neuronrobotics.sdk.serial.SerialConnection;
import com.neuronrobotics.sdk.util.ThreadUtil;


public class ServerApp{
	boolean run = true;
	private double volts = 0.0;
	private NRLauncher launcher;

	
	public ServerApp(NRLauncher l) {
		launcher = l;
	}
	public String getLaunchDirectory(){
		return launcher.getWindow().getLaunchDirectory();
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
		
		try{
			String html = "<html>\n"+
"	<head>\n"+
"		<title>Neuron Robotics Launcher</title>\n"+
"	</head>\n"+
"	<body>\n"+
		
"		<h1>Neuron Robotics Launcher</h1>\n"+

"		<link rel=\"shortcut icon\" HREF=\"http://media.neuronrobotics.com/favicon.ico\">\n"+
"		<form action=\"upload\"enctype=\"multipart/form-data\" method=\"post\">\n"+
"			<p>Upload a new .JAR file:<br>\n"+
"				<input type=\"file\" name=\"datafile\" size=\"40\">\n"+
"				<input type=\"submit\" value=\"Send\">\n"+
"			</p>\n"+
"		</form>\n";
			html+="		<form class=\"link\" action=\"batt\" method=\"post\">\n"+
			"			<p><input type=\"submit\" name=\"Get Battery\" value=\"Get Battery\" /> Current Voltage = "+volts+" volts</p>\n"+
			"		</form>\n";
			html+=getJarForm();
			html+=getOutputBox(launcher.getWindow().getJarOutput());
			html+="\n</body></html>";
			s=html;
		}catch(Exception e){
			e.printStackTrace();
		}

		return	s;
	
	}
	
	private String getJarForm(){
		String s="<form class=\"link\" action=\"control\" method=\"post\">\n"+
"		      <div>\n"+
"		    	<p>\n";
		for(String j:launcher.getWindow().getShortJarNames()){
			s+=getJarRadio(j);
		}
		s+="</p>\n";
		s+="<p>"+getSerialSelect()+getRunStop()+"</p>";
		s+="\n</div>\n</form>\n";
		return s;
	}
	
	private String getSerialSelect() {
		String s="Select a serial port:<select name=\"portSel\">";
		String ports="";
		try{
			for(String ser: SerialConnection.getAvailableSerialPorts()){
				String []p = ser.split("/");
				String port = p[p.length-1];
				port=ser;
				ports="\n<option value=\""+port+"\">"+port+"</option>"+ports;
			}
		}catch (Exception ex){
			ex.printStackTrace();
		}
		s+=ports;
		s+="</select>";
		return s;
	}
	private String getJarRadio(String name){
		return "\n<p><input type=\"radio\" name=\"JarSel\" value=\""+name+"\" >"+name+"</input></p>";
	}
	private String getRunStop(){
		if(isRunning()){
			return "<input type=\"submit\" name=\"Stop\" value=\"Stop\" />";
		}else
			return "<input type=\"submit\" name=\"Run\" value=\"Run\" />";
	}
	private String getOutputBox(String content){
		return "<p>\n"+
"					<textarea name=\"output\" rows=\"10\" cols=\"50\">"+content+"</textarea>\n"+
"					<form class=\"link\" action=\"/\" method=\"post\">\n"+
"						<div>\n"+
"							<input type=\"submit\" name=\"Refresh\" value=\"Refresh\" />\n"+
"						</div>\n"+
"					</form>\n"+
"				</p>";
	}
	public void refresh() {
		launcher.getWindow().refreshJars();
	}
	public boolean isRunning(){
		return launcher.getWindow().isRunning();
	}
	public void stop() {
		launcher.getWindow().stop();
	}
	public void runFile(String fileName){
		launcher.getWindow().runFile(fileName);
	}
	public void writeConfigFile(String string) {
		String content="<?xml version=\"1.0\"?>\n"+
"<config>\n"+
"	<connections>\n"+
"		<connection>\n"+
"			<type>serial</type>\n"+
"			<name>Default Serial Connection</name>\n"+
"			<baud>115200</baud>\n"+
"			<port>"+string+"</port>\n"+
"		</connection>\n"+
"	</connections>\n"+
"</config>";
		File config = new File(launcher.getWindow().getLaunchDirectory()+"/config.xml");
		System.err.println("New config file:\n"+content);
		try {
			FileOutputStream fos = new FileOutputStream(config);
			fos.write(content.getBytes());
			fos.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public void setVoltage(double batteryVoltage) {
		volts=batteryVoltage;
	}
}
