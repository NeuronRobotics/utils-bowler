package com.neuronrobotics;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class MakeBowlerFirmware {
	private static String readFile(String filename) throws IOException{
		String contents="";
		/*	Sets up a file reader to read the file passed on the command
		line one character at a time */
		FileReader input = new FileReader(filename);
	    
		/* Filter FileReader through a Buffered read to read a line at a
		   time */
		BufferedReader bufRead = new BufferedReader(input);
		
	    String line; 	// String that holds current file line
	    
	    // Read first line
	    line = bufRead.readLine();

		// Read through file one line at time. Print line # and line
	    while (line != null){
	        contents+=line+"\n";
	        line = bufRead.readLine();
	    }
	    
	    bufRead.close();
		return contents;
	}
	private static void writeFile(String filename, String contents) throws IOException{
		  System.out.println("Writing file: "+filename);
		  FileWriter fstream = new FileWriter(filename);
		  BufferedWriter out = new BufferedWriter(fstream);
		  out.write(contents);
		  //Close the output stream
		  out.close();		
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Making Bowler Firmware");
		try{
			String revision = "1.0.0";
			String oFilename = "BowlerFirmware";
			ArrayList<String> cores = new ArrayList<String>();
			for(int i=0;i<args.length;i++){
				if(args[i].toLowerCase().contains("--pic")){
					String filename = args[i+1].substring(0,args[i+1].indexOf("."));
					String hexContents =  readFile(filename+".hex");
					cores.add( XmlSkeleton.getPic(0, hexContents));
				}
				if(args[i].toLowerCase().contains("--avr")){
					String filename = args[i+1].substring(0,args[i+1].indexOf("."));
					String hexContents =  readFile(filename+".hex");
					cores.add(XmlSkeleton.getAvr(1, hexContents));						
				}
				if(args[i].toLowerCase().contains("--output")){
					oFilename = args[i+1].substring(0,args[i+1].indexOf("."));
				}
				if(args[i].toLowerCase().contains("--rev")){
					revision = args[i+1];
				}
			}
			String xmlContents = XmlSkeleton.getTop(revision);
			for(String c:cores){
				xmlContents+=c;
			}
			xmlContents += XmlSkeleton.getBottom();
			writeFile(oFilename+".xml", xmlContents);
		}catch(Exception e){
			System.err.println("Usage: \n {-pic firmware.hex} {-avr firmware2.hex}");
		}
	}

}
