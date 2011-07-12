package com.neuronrobotics.launcher.server.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.neuronrobotics.launcher.server.ServerApp;
import com.neuronrobotics.sdk.dyio.DyIO;
import com.neuronrobotics.sdk.ui.ConnectionDialog;
import com.neuronrobotics.sdk.util.ThreadUtil;

public class BatteryVoltageServlet extends HttpServlet {
	private static final long serialVersionUID = -9038751269579917468L;

	
	ServerApp manager;
	public BatteryVoltageServlet(ServerApp m) {
		manager=m;
	}
	@Override
	protected void doPost(HttpServletRequest request,HttpServletResponse resp)throws ServletException, IOException{
		System.out.println("Voltage request");
		
	    Enumeration paramNames = request.getParameterNames();

	    while(paramNames.hasMoreElements()) {
	      String paramName = (String)paramNames.nextElement();
	      System.out.print("\nParam=" + paramName );   
	      String[] paramValues = request.getParameterValues(paramName);
	      for(int i=0; i<paramValues.length; i++) {
	    	  System.out.print(" value=" + paramValues[i]+"\n");
	      }
	      if(paramName.toLowerCase().contains("get battery") ){
	    	  DyIO d = new DyIO(ConnectionDialog.getHeadlessConnection(manager.getLaunchDirectory()+"/config.xml"));
	    	  d.enableDebug();
	    	  d.connect();
	    	  manager.setVoltage(d.getBatteryVoltage(true));
	    	  d.disconnect();
	      }

	    }
		doGet(request, resp);
	}

	@Override
	protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException, IOException{
		PrintWriter out = resp.getWriter();
		out.print(manager.getBody());
	}
}
