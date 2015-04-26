package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class SubscriptionsPage extends PageObject {
	public SubscriptionsPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"subscriptions"));
	}

	//interactive elements
	
	//message elements
	private WebElement noSubscriptionsMsg;
	private WebElement yourSubscriptionsHeader;

	/* inputs action */
	
	/* display checks */
	public boolean isNoSusbscriptionsMsgDisplayed() {
		return noSubscriptionsMsg.isDisplayed();
	}
	public boolean isYourSubscriptionsHeaderDisplayed() {
		return yourSubscriptionsHeader.isDisplayed();
	}

	/* services */
}