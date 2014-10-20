package com.pivotal;

import java.io.File;
import java.io.FileInputStream;
import java.util.Set;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;

public class JsonParser {

	public static void main(String[] args) throws Exception {
		String fileName = args[0];
		String fieldName = args[1];
		String jobType = args[2];
		String username = args[3];

		String value = new JsonParser().getValue(fileName, fieldName, jobType, username);

		System.out.println(value);
	}

	private String getValue(String fileName, String fieldName, String jobType, String username) throws Exception {
		String details = username;

		File file = new File(fileName);

		FileInputStream fis = new FileInputStream(file);

		JsonReader rdr = Json.createReader(fis);

		JsonObject obj = rdr.readObject();

		String infrastructure_type = obj.getJsonObject("infrastructure").getString("type");

		if (infrastructure_type.equalsIgnoreCase(CloudEnv.VCLOUD.getValue())) {
			details = vCloudEnv(fieldName, jobType, username, details, obj);
		} else if (infrastructure_type.equalsIgnoreCase(CloudEnv.VSPHERE.getValue())) {
			details = vsphereEnv(fieldName, jobType, username, details, obj);
		}

		return details;
	}

	private String vsphereEnv(String fieldName, String jobType, String username, String details, JsonObject obj) {
		JsonArray jsonArray = obj.getJsonArray("products");

		for (JsonObject result : jsonArray.getValuesAs(JsonObject.class)) {
			if (result.getString("type").equalsIgnoreCase(fieldName)) {
				JsonArray jobs = result.getJsonArray("jobs");
				for (JsonObject job : jobs.getValuesAs(JsonObject.class)) {
					if (job.getString("type").equalsIgnoreCase(jobType)) {
						JsonArray properties = job.getJsonArray("properties");
						for (JsonObject property : properties.getValuesAs(JsonObject.class)) {
							if (property.getJsonObject("value").getString("identity").equalsIgnoreCase(username)) {
								details += "|" + property.getJsonObject("value").getString("password");
								break;
							}
						}
					}
				}

				JsonObject ips = result.getJsonObject("ips");
				Set<String> keys = ips.keySet();
				for (String key : keys) {
					if (key.contains(jobType)) {
						if (ips.getJsonArray(key).toArray().length == 1) {
							details += "|" + ips.getJsonArray(key).get(0).toString().replaceAll("\"", "");
							break;
						}
					}
				}
			}
		}
		return details;
	}

	private String vCloudEnv(String fieldName, String jobType, String username, String details, JsonObject obj) {
		JsonArray jsonArray = obj.getJsonArray("components");
		
		if(fieldName.equalsIgnoreCase("microbosh")) {
			fieldName = "microbosh-vcloud";
		}

		for (JsonObject result : jsonArray.getValuesAs(JsonObject.class)) {
			if (result.getString("type").equalsIgnoreCase(fieldName)) {
				JsonArray jobs = result.getJsonArray("jobs");
				for (JsonObject job : jobs.getValuesAs(JsonObject.class)) {
					if (job.getString("type").equalsIgnoreCase(jobType)) {
						JsonArray properties = job.getJsonArray("properties");
						for (JsonObject property : properties.getValuesAs(JsonObject.class)) {
							if (property.getJsonObject("value").getString("identity").equalsIgnoreCase(username)) {
								details += "|" + property.getJsonObject("value").getString("password");
								break;
							}
						}
					}
				}

				JsonObject ips = result.getJsonObject("ips");
				Set<String> keys = ips.keySet();
				for (String key : keys) {
					if (key.contains(jobType)) {
						if (ips.getJsonArray(key).toArray().length == 1) {
							details += "|" + ips.getJsonArray(key).get(0).toString().replaceAll("\"", "");
							break;
						}
					}
				}
			}
		}
		return details;
	}
}
