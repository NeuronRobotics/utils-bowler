package com.neuronrobotics.launcher.server.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
	protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException, IOException{
		System.out.println("Control called");
		PrintWriter out = resp.getWriter();
		out.print(manager.getBody());
	}

}
