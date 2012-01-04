package com.neuronrobotics.tools.publish;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Timestamp;

public class Publish {
	private Publish(String[] args){
		String output = "<root>\n";
		File xml = null;
		for(int i=0;i<args.length;i++){
			String str = args[i];
			String [] s = str.split("\\=");
			if(s[0].contains("-output")){
				if(s[1].contains(".xml")){
					xml = new File(s[1]);
				}else{
					xml = new File(s[1]+"_"+getDate()+".xml");
				}
			}
			if(s[0].contains("-revision")){
				output+="\t<revision>"+s[1]+"</revision>\n";
			}
			if(s[0].contains("-core")){
				String [] core =  s[1].split("\\,");
				output+="\t<core>\n";
				output+="\t\t<index>"+core[0]+"</index>\n";
				output+="\t\t<type>"+core[1]+"</type>\n";
				output+="\t\t<wordSize>"+core[2]+"</wordSize>\n";
				output+="\t\t<hex>";
				try{
					  // Open the file that is the first 
					  // command line parameter
					  FileInputStream fstream = new FileInputStream(core[3]);
					  // Get the object of DataInputStream
					  DataInputStream in = new DataInputStream(fstream);
					  BufferedReader br = new BufferedReader(new InputStreamReader(in));
					  String strLine;
					  //Read File Line By Line
					  while ((strLine = br.readLine()) != null)   {
						  output+=strLine+"\n";
					  }
					  //Close the input stream
					  in.close();
				 }catch (Exception e){//Catch exception if any
					  System.err.println("Hex file read error: " + e.getMessage());
				 }
				output+="</hex>\n";
				output+="\t</core>\n";
			}
		}
		output +="\n<root>\n";
		if(xml == null){
			xml = new File("output_"+getDate()+".xml");
			System.err.println("No file defined with -output=\nUsing:"+xml);
		}
		System.out.println("Using output file: "+xml);
		try {
			FileWriter fstream = new FileWriter(xml);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(output);
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
	}

	private String getDate(){
		Timestamp t = new Timestamp(System.currentTimeMillis());
		return t.toString().split("\\ ")[0];
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		for(int i=0;i<args.length;i++){
			System.out.println(args[i]);
		}
		new Publish(args);
	}

}
