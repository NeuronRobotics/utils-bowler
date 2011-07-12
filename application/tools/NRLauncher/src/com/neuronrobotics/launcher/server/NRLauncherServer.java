package com.neuronrobotics.launcher.server;

import java.io.IOException;
import com.neuronrobotics.launcher.NRLauncher;
import com.neuronrobotics.launcher.server.servlet.BatteryVoltageServlet;
import com.neuronrobotics.launcher.server.servlet.ControlServlet;
import com.neuronrobotics.launcher.server.servlet.GetUiServlet;
import com.neuronrobotics.launcher.server.servlet.UploadServlet;


public class NRLauncherServer {

	private  int port=8081;

	
	public NRLauncherServer(NRLauncher l) throws IOException{
		//http://tjws.sourceforge.net/
		class MyServ extends Acme.Serve.Serve {
			/**
			 * 
			 */
			private static final long serialVersionUID = 1L;
						// Overriding method for public access
                        public void setMappingTable(PathTreeDictionary mappingtable) { 
                              super.setMappingTable(mappingtable);
                        }
                        // add the method below when .war deployment is needed
                        public void addWarDeployer(String deployerFactory, String throttles) {
                              super.addWarDeployer(deployerFactory, throttles);
                        }
         };

		final MyServ srv = new MyServ();
 		// setting aliases, for an optional file servlet
        Acme.Serve.Serve.PathTreeDictionary aliases = new Acme.Serve.Serve.PathTreeDictionary();
        aliases.put("/", new java.io.File("/tmp"));
		//  note cast name will depend on the class name, since it is anonymous class
        srv.setMappingTable(aliases);
		// setting properties for the server, and exchangeable Acceptors
		java.util.Properties properties = new java.util.Properties();
		properties.put("port",port);
		properties.setProperty(Acme.Serve.Serve.ARG_NOHUP, "nohup");
		srv.arguments = properties;
		//srv.addDefaultServlets(null); // optional file servlet
		//srv.addServlet("/myservlet", new MyServlet()); // optional
		ServerApp manager = new ServerApp(l);
		srv.addServlet("/", new GetUiServlet(manager)); // 
		srv.addServlet("/control", new ControlServlet(manager)); // 
		srv.addServlet("/upload", new UploadServlet(manager)); // 
		srv.addServlet("/batt", new BatteryVoltageServlet(manager)); //
		
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			public void run() {
				try {
					srv.notifyStop();
				}catch(java.io.IOException ioe) {
					
				}
				srv.destroyAllServlets();
			}
		}));
		srv.serve();
	}
	

	public static void main(String args []){
		System.out.println("Starting Launcher Server");
		try {
			NRLauncher l =new NRLauncher(args[0]);
			new NRLauncherServer(l);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(1);
		}
	}

}
