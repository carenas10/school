package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class AccountPage extends PageObject {
	public AccountPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"account"));
	}
	//interactive elements
	private WebElement subscribe;
	private WebElement unsubscribe;
	
	//message elements

	/* inputs action */

	/* display checks */
	public boolean isSubscribeButtonDisplayed() {
		return subscribe.isDisplayed();
	}
	public boolean isUnsubscribeButtonDisplayed() {
		return unsubscribe.isDisplayed();
	}

	/* services */
	public AccountPage subscribe() {
		subscribe.click();
		return this;
	}
	public AccountPage unsubscribe() {
		unsubscribe.click();
		return this;
	}
}
