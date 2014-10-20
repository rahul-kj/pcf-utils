package com.pivotal;

public enum CloudEnv {
	VSPHERE("vsphere"), VCLOUD("vcloud");

	private String value;

	private CloudEnv(String environment) {
		this.value = environment;
	}

	public String getValue() {
		return value;
	}

}
