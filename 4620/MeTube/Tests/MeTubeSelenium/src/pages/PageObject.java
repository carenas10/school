package pages;

import org.openqa.selenium.WebDriver;

public class PageObject {
	protected final WebDriver driver;
	PageObject(WebDriver driver) {
		this.driver = driver;
	}
}
