package com.neuronrobotics;

public class XmlSkeleton {
	public static String getTop(String revision) {
		return "<root>\n"+
		"<revision>"+revision+"</revision>\n";
	}
	public static String getAvr(int index,String hex) {
		return"<core>\n"+
        "<index>"+index+"</index>\n"+
        "<type>avr_atmegaXX4p</type>\n"+
        "<wordSize>2</wordSize>\n"+
        "<hex>"+hex+
       "</hex>\n"+
       "</core>";
	}
	public static String getPic(int index,String hex) {
		return"<core>\n"+
        "<index>"+index+"</index>\n"+
        "<type>pic32mx440f128h</type>\n"+
        "<wordSize>4</wordSize>\n"+
        "<hex>"+hex+
       "</hex>\n"+
       "</core>";
	}
	public static String getBottom() {
		return "\n</root>";
	}
}
