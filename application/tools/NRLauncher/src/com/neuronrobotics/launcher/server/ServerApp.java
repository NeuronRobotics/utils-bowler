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


public class ServerApp{
	boolean run = true;
	private static NRLauncher launcher;

	
	public ServerApp(NRLauncher l) {
		launcher = l;
	}
	
	public static String getBody(){
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

}
