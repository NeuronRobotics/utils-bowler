package com.neuronrobotics.launcher.server.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.neuronrobotics.launcher.NRLauncher;
import com.neuronrobotics.launcher.server.ServerApp;

public class GetUiServlet extends HttpServlet{

	/**
	 * 
	 */
	private static final long serialVersionUID = -292827055777011528L;
	ServerApp manager;
	public GetUiServlet(ServerApp m) {
		manager=m;
	}

	@Override
	protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException, IOException{
		PrintWriter out = resp.getWriter();
		out.print(manager.getBody());
	}

}
