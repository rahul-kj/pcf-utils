package com.pivotal;

import static org.junit.Assert.*;

import java.io.FileNotFoundException;
import java.io.InputStream;

import org.junit.Test;

public class JsonParserTest {
	@Test
	public void validateMicroBoshDetailsForVSphere() {
		String fileName = "/installation-vsphere.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.MICROBOSH, "director", "director");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("director", values[0]);
			assertEquals("e69ccfd771d763717600", values[1]);
			assertEquals("192.168.0.101", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateCcDBDetailsForVSphere() {
		String fileName = "/installation-vsphere.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.CCDB, "admin");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("admin", values[0]);
			assertEquals("f7624b132f3259e9d0c4", values[1]);
			assertEquals("192.168.0.106", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateUaaDBDetailsForVSphere() {
		String fileName = "/installation-vsphere.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.UAADB, "vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("320ffa7f896f77b9", values[1]);
			assertEquals("192.168.0.111", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateConsoleDBDetailsForVSphere() {
		String fileName = "/installation-vsphere.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.CONSOLE_DB,
					"vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("9369b486cb12020d", values[1]);
			assertEquals("192.168.0.114", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateNFSServerDetailsForVSphere() {
		String fileName = "/installation-vsphere.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.NFS_SERVER,
					"vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("9adc8b822f1e29e0", values[1]);
			assertEquals("192.168.0.105", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateMicroBoshDetailsForVCloud() {
		String fileName = "/installation-vcloud.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.MICROBOSH, "director", "director");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("director", values[0]);
			assertEquals("5332a800d541e8d9fed5", values[1]);
			assertEquals("10.17.1.128", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateCcDBDetailsForVCloud() {
		String fileName = "/installation-vcloud.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.CCDB, "admin");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("admin", values[0]);
			assertEquals("518e83f5c8a616143ac0", values[1]);
			assertEquals("10.17.1.136", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateUaaDBDetailsForVCloud() {
		String fileName = "/installation-vcloud.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.UAADB, "vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("359a4b68e562fa85", values[1]);
			assertEquals("10.17.1.141", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateConsoleDBDetailsForVCloud() {
		String fileName = "/installation-vcloud.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.CONSOLE_DB,
					"vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("4c412fa6ec0731fa", values[1]);
			assertEquals("10.17.1.144", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

	@Test
	public void validateNFSServerDetailsForVCloud() {
		String fileName = "/installation-vcloud.yml";
		try {
			JsonParser jsonParser = new JsonParser() {

				@Override
				InputStream getFileStream(String fileName) throws FileNotFoundException {
					InputStream is = this.getClass().getResourceAsStream(fileName);
					return is;
				}

			};

			String response = jsonParser.getValue(fileName, ApplicationConstant.CF, ApplicationConstant.NFS_SERVER,
					"vcap");
			String[] values = response.split("\\|");
			assertTrue(values.length == 3);
			assertEquals("vcap", values[0]);
			assertEquals("1bdf00ab7fd342f0", values[1]);
			assertEquals("10.17.1.135", values[2]);

		} catch (Exception e) {
			fail("This is unexpected: \n" + e);
		}
	}

}
