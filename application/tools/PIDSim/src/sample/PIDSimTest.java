package sample;

import com.neuronrobotics.pidsim.PIDConstantsDialog;
import com.neuronrobotics.pidsim.PIDSim;

public class PIDSimTest {
	public static void main(String[] args) throws InterruptedException {
		PIDSim pid = new PIDSim( .01, // mass
								 .5,  //link length
								 5,  //torque from static friction
								 4.5,//torque from dynamic friction
								 20);//maximum torque that can be exerted by motor
    	pid.initialize();
    	pid.setSetPoint(45);
    	PIDConstantsDialog constants = new PIDConstantsDialog(	.1,//kp
												    			0,//ki
												    			0);//kd
    	//Simple Proportional controller
    	while(true) {
    		Thread.sleep(10); //Wait 10 ms to make a 100 hz control loop
    		double set = pid.getSetPoint();
    		double now = pid.getPosition();
    		
    		double torque = 0;
    		
    		double error = now - set;

    		torque = (constants.getKp())*(error);
    		try{
    			pid.setTorque((torque*-1));
    		}catch (Exception ex){
    			ex.printStackTrace();
    		}
    	}
	}

}
