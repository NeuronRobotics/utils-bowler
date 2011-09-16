package com.neuronrobotics.pidsim;

class LinearPhysicsEngine extends Thread {
	/**
	 *
	 */
	private double torque=0;// Newton meters
	private double w = 0;// Radians/second
	private double angle = 0;//radians
	private double mass;// in kg
	private double linkLen;// inmeters
	private double muStatic;// Newton meters
	private double muDynamic;// Newton meters
	private PIDSim pid;
	private double step = .01;//in seconds
	private double maxTorque = 20;// Newton meters
	private long time = 0l;// Seconds
	double acceleration;
	private boolean run = true;
	
	public LinearPhysicsEngine(PIDSim pidSim,double maxTorque) {
		pid = pidSim;
		setMass(pid.getMass());
		setLinkLen(pid.getLength());
		setMuStatic(pid.getStaticFriction());
		setMuDynamic(pid.getDynamicFriction());
		setTime(System.currentTimeMillis());
		this.maxTorque=maxTorque;
	}
	
	public void run() {
		System.out.println("Starting physics engine.");
		while (run) {
			
			long localStep = (long) (step*1000);
			try {Thread.sleep(localStep);} catch (InterruptedException e) {}
			setTime(getTime() + localStep);
			pid.setTime(getTime());
			
			double tGravity = getLinkLen() * (getMass() * (Math.cos(angle) * -9.8)); // the torque due to gravity
			double tTotal = torque + tGravity;
			acceleration=0;
			if(tTotal != 0) {
				// update angular velocity
				double mu = Math.abs((w ==0)?getMuStatic():getMuDynamic()*w);
				double muTorque = (tTotal>0)? (mu*-1):mu;
				
				//if(Math.abs(tTotal)>Math.abs(muTorque)) {
					tTotal+=muTorque;
//				} else {
//					tTotal=0;
//				}
				//System.out.println("Set Torque is: "+torque+" gravity: "+tGravity+" friction: "+ muTorque+" Total: "+tTotal);
				double I = getMass() * getLinkLen() * getLinkLen() ;

				// T/I= alpha
				acceleration = tTotal/I;
				
				w+=acceleration*step*step;
			}
			if(w != 0) {
				angle+=w*step;
			}
			
			if(Math.toDegrees(angle) >181){
				angle = Math.PI;
				w=0;
			}
			
			if(Math.toDegrees(angle) < -1){
				angle = 0;
				w=0;
			}
			
			//System.out.println("Control torque: "+torque+" Tg: "+tGravity+" Aceleration: "+acceleration+" Angular velocity: "+w+" Angle: "+Math.toDegrees(angle));
			pid.setPosition(Math.toDegrees(angle));
		}
	}
	
	public void setEnabled(boolean isEnabled) {
		run = isEnabled;
	}
	
	public void setTorque(double torque) {
		if(Math.abs(torque)<=Math.abs(getMaxTorque())){
			this.torque = torque;
			return;
		}
		if(torque>0)
			this.torque = getMaxTorque();
		else
			this.torque = getMaxTorque()*-1;
		throw new RuntimeException("Max Torque exceded, actuator saturates at: "+maxTorque+" N*M, tried to set to value: "+ torque);
	}
	
	public void setMass(double mass) {
		this.mass = mass;
	}
	
	public double getMass() {
		return mass;
	}
	
	public void setLinkLen(double linkLen) {
		this.linkLen = linkLen;
	}
	
	public double getLinkLen() {
		return linkLen;
	}
	
	public void setMuStatic(double muStatic) {
		this.muStatic = muStatic;
	}
	
	public double getMuStatic() {
		return muStatic;
	}
	
	public void setMuDynamic(double muDynamic) {
		this.muDynamic = muDynamic;
	}
	
	public double getMuDynamic() {
		return muDynamic;
	}

	public void setMaxTorque(double maxTorque) {
		this.maxTorque = maxTorque;
	}

	public double getMaxTorque() {
		return maxTorque;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public long getTime() {
		return time;
	}
}
