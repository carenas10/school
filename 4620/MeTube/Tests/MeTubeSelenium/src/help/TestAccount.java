package help;

public class TestAccount {
	private String username;
	private String email;
	private String pass;
	
	public TestAccount(String username, String email, String pass) {
		this.username = username;
		this.email = email;
		this.pass = pass;
	}

	public String getUsername() {
		return username;
	}

	public String getEmail() {
		return email;
	}

	public String getPass() {
		return pass;
	}
}
