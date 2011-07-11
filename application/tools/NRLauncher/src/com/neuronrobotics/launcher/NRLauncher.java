package com.neuronrobotics.launcher;

import java.awt.Dimension;
import java.awt.Frame;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

public class NRLauncher {
	private LauncherWindow window;
	public NRLauncher(String args) throws InterruptedException{
		File f = new File(args);
		if(!f.exists() || !f.isDirectory()){
			throw new RuntimeException("Directory does not exist!"+f.getAbsolutePath());
		}
		System.out.println("Starting with jar directory: "+f.getAbsolutePath());
		 setWindow(new LauncherWindow(args));
		//window.setSize(new Dimension(300,200));
		//window.setExtendedState(Frame.MAXIMIZED_BOTH);
		getWindow().pack();
		reSize(getWindow());
		//window.setUndecorated(true); 
		getWindow().setVisible(true);
		getWindow().repaint();
		getWindow().refresh();
		getWindow().setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		File config = new File(f.getAbsolutePath()+"/config.xml");
		InputStream in = NRLauncher.class.getResourceAsStream("config.xml");
		try {
			copyResource(in, config);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	private void copyResource(InputStream io, File file) throws IOException {
		FileOutputStream fos = new FileOutputStream(file);
		
		
		byte[] buf = new byte[256];
		int read = 0;
		while ((read = io.read(buf)) > 0) {
			fos.write(buf, 0, read);
		}
		fos.close();
		io.close();
	}
	private void reSize(JFrame f){
		//f.setExtendedState(Frame.MAXIMIZED_BOTH);
		//f.setSize(new Dimension(600,400));
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		try{
			if(args.length ==1)
				new NRLauncher(args[0]);
			else
				throw new RuntimeException("Need the path to the jar directory!");
		}catch (Exception ex){
			ex.printStackTrace();
			System.exit(0);
		}

	}
	private void setWindow(LauncherWindow window) {
		this.window = window;
	}
	public LauncherWindow getWindow() {
		return window;
	}

}
