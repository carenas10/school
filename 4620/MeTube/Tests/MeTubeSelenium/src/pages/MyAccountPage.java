package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.Alert;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;

public class MyAccountPage extends PageObject {
	public MyAccountPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"myAccount"));
	}
	//interactive elements
	private WebElement deleteAccount;
	private WebElement editAccount;
	private WebElement accountDeletedMsg;
	
	//message elements

	/* inputs action */

	/* display checks */
	public boolean isAccountDeletedMsgDisplayed() {
		return accountDeletedMsg.isDisplayed();
	}
	public boolean isEditAccountButtonDisplayed() {
		return editAccount.isDisplayed();
	}
	
	/* services */
	public MyAccountPage deleteYourAccount() {
		deleteAccount.click();
		Alert alert = driver.switchTo().alert();
		//acknowledge the alert (equivalent to clicking "OK")
		alert.accept();
		return this;
	}
	public EditAccountPage goToEditAccount() {
		editAccount.click();
		return PageFactory.initElements(driver, EditAccountPage.class);
	}
}
