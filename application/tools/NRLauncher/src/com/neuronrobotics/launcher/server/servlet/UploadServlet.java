package com.neuronrobotics.launcher.server.servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.neuronrobotics.launcher.server.ServerApp;

public class UploadServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	ServerApp manager;
	public UploadServlet(ServerApp m) {
		manager=m;
	}
	
	@Override
	protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException, IOException{
		System.out.println("Upload called");
		
		// Create a factory for disk-based file items
		FileItemFactory factory = new DiskFileItemFactory();

		// Create a new file upload handler
		ServletFileUpload upload = new ServletFileUpload(factory);

		// Parse the request
		try {
			List /* FileItem */ items = upload.parseRequest(req);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
			    FileItem item = (FileItem) iter.next();

			    if (item.isFormField()) {
			    	String name = item.getFieldName();
			        String value = item.getString();
			        System.out.println("Form Field name="+name+" value="+value);
			    } else {
			    	String fieldName = item.getFieldName();
			        String fileName = item.getName();
			        String contentType = item.getContentType();
			        boolean isInMemory = item.isInMemory();
			        long sizeInBytes = item.getSize();
			        System.out.println("File name="+fileName+" size="+sizeInBytes);
			        File uploadedFile = new File(manager.getLaunchDirectory()+"/"+fileName);
			        item.write(uploadedFile);
			    }
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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
