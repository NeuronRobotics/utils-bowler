package com.neuronrobotics.pidsim;

import javax.swing.JFrame;

public class PIDSim {
	
	private JFrame frame = new JFrame("Neuron Robotics PIDSim");
	private GraphingPanel graphingPanel;
	private LinearPhysicsEngine phy;
	
	private double sp;
    private double position;
    private double mass = .01;
    private double length = 1;
    private double stFriction = .5;
    private double dyFriction = .3;
    private long time = 0;
	private double maxTorque = 20;// Newton meters
    
    public PIDSim() { }
    
    public PIDSim(double mass, double linkLegnth,double muStatic, double muDynamic, double maxTorque) {
    	this.mass=mass;
    	this.length=linkLegnth;
    	stFriction=muStatic;
    	dyFriction=muDynamic;
    	this.maxTorque=maxTorque;
    }
    
    public void initialize() {
    	graphingPanel = new GraphingPanel(this, "Neuron Robotics PIDSim");
    	graphingPanel.setVisible(true);
    	frame.add(graphingPanel);
    	frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    	frame.pack();
    	frame.setLocationRelativeTo(null);
    	frame.setVisible(true);
    	
    	
    	phy = new LinearPhysicsEngine(this,maxTorque);
    	phy.start();
    }
    
    public double getSetPoint() {
    	
    	return sp;
    }
    
    public void setSetPoint(double value) {
    	sp = value;
    	graphingPanel.setSetPoint(sp);
    }
    /**
     * setting a torque in kg/m
     * @param value
     */
    public void setTorque(double value) {
    	phy.setTorque(value);
    }
    
    public long getTime() {
    	return time;
    }
    
    protected void setTime(long t) {
    	time = t;
    }
    
    protected void setPosition(double value) {
    	position = value;
    	graphingPanel.setPosition(position);
    }
    
    public double getPosition() {
    	return position;
    }
    
	public double getMass() {
		return mass;
	}

	public void setMass(double value) {
		phy.setMass(mass);
		mass = value;
	}
	
	public double getLength() {
		return length;
	}

	public void setLength(double value) {
		phy.setLinkLen(value);
		length = value;
	}
	
	public double getStaticFriction() {
		return stFriction;
	}
	
	public void setStaticFriction(double value) {
		phy.setMuStatic(value);
		stFriction = value;
	}
	
	public double getDynamicFriction() {
		return dyFriction;
	}

	public void setDynamicFriction(double value) {
		phy.setMuDynamic(value);
		dyFriction = value;
	}
}
