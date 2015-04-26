package help;

public class TestDoc {
	private String title;
	private String description;
	private String keywords;
	private String path;
	
	public TestDoc(String title, String description, String keywords, String path) {
		this.title = title;
		this.description = description;
		this.keywords = keywords;
		this.path = path;
	}
	
	public String getTitle() {
		return title;
	}

	public String getDescription() {
		return description;
	}

	public String getKeywords() {
		return keywords;
	}

	public String getPath() {
		return path;
	}
}
