package com.neuronrobotics.sdk.dyio;

import java.util.ArrayList;

import com.neuronrobotics.sdk.common.BowlerAbstractConnection;
import com.neuronrobotics.sdk.common.IConnectionEventListener;
import com.neuronrobotics.sdk.dyio.DyIO;
import com.neuronrobotics.sdk.ui.ConnectionDialog;

public class DyIORegestry {
	private static DyIO dyio = null;
	private static ArrayList<IConnectionEventListener> disconnectListeners = new ArrayList<IConnectionEventListener> ();
	public static boolean setConnection(BowlerAbstractConnection c){
		for(IConnectionEventListener i:disconnectListeners) {
			c.addConnectionEventListener(i);
		}
		try{
			get().disconnect();
			get().setConnection(c);
			get().connect();
			return get().isAvailable();
		}catch(Exception ex){
			ex.printStackTrace();
			return false;
		}
	}
	public static DyIO get(){
		if(dyio == null)
			dyio = new DyIO();
		return dyio;
	}
	public static void promptConnection(IConnectionEventListener l) {
		BowlerAbstractConnection connection = ConnectionDialog.promptConnection();
		if(connection != null) {
			addConnectionEventListener(l);
			setConnection(connection);
		}
	}
	public static void addConnectionEventListener(IConnectionEventListener l ) {
		if(!disconnectListeners.contains(l)) {
			disconnectListeners.add(l);
		}
	}
	public static void removeConnectionEventListener(IConnectionEventListener l ) {
		if(disconnectListeners.contains(l)) {
			disconnectListeners.remove(l);
		}
	}
	public static void disconnect() {
		dyio.disconnect();
		dyio=null;
	}
}