package com.neuronrobotics.launcher.server.servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.neuronrobotics.launcher.server.ServerApp;

public class ControlServlet extends HttpServlet {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -9038751269579917469L;

	
	ServerApp manager;
	public ControlServlet(ServerApp m) {
		manager=m;
	}
	@Override
	protected void doPost(HttpServletRequest request,HttpServletResponse resp)throws ServletException, IOException{
		System.out.println("Control called");
		
	    Enumeration paramNames = request.getParameterNames();
	    boolean hasRun = false;
	    boolean hasJar = false;
	    String jar = "";
	    while(paramNames.hasMoreElements()) {
	      String paramName = (String)paramNames.nextElement();
	      System.out.println("Param=" + paramName );   
	      String[] paramValues = request.getParameterValues(paramName);
	      for(int i=0; i<paramValues.length; i++) {
	    	  System.out.println("value=" + paramValues[i]);
	      }
	      if(paramName.contains("Run") ||paramName.contains("Stop")){
	    	  hasRun=true;  
	      }
	      if(paramName.contains("JarSel")){
	    	  hasJar=true;
	    	  jar = paramValues[0];
	      }
	      
	    }
	    
	    if( hasRun && hasJar){
	    	if(manager.isRunning()){
	    		manager.stop();
	    	}else{
	    		manager.runFile(jar);
	    	}
	    }
		
		manager.refresh();
		PrintWriter out = resp.getWriter();
		out.print(manager.getBody());
	}
	@Override
	protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException, IOException{
		PrintWriter out = resp.getWriter();
		out.print(manager.getBody());
	}

}
