package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;

public class EditAccountPage extends PageObject {
	public EditAccountPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"editAccount"));
	}
	//interactive elements
	private WebElement saveChangesToAccount;
	private WebElement cancelChangesToAccount;
	private WebElement username;
	private WebElement email;
	private WebElement password;

	//message elements
	private WebElement updateSuccessfulMsg;
	private WebElement usernameTooLongMsg;
	private WebElement usernameEmptyMsg;
	private WebElement usernameContainsAtSymbolMsg;
	private WebElement usernameTakenMsg;
	private WebElement emailTooLongMsg;
	private WebElement emailInvalidMsg;
	private WebElement emailTakenMsg;

	/* input actions */
	public EditAccountPage typeUsername(String _username) {
		username.clear();
		username.sendKeys(_username);
		return this;
	}
	public EditAccountPage typeEmail(String _email) {
		email.clear();
		email.sendKeys(_email);
		return this;
	}
	public EditAccountPage typePassword(String _password) {
		password.clear();
		password.sendKeys(_password);
		return this;
	}
	public EditAccountPage submitSaveChanges() {
		saveChangesToAccount.click();
		return this;
	}
	public MyAccountPage submitCancelChanges() {
		cancelChangesToAccount.click();
		return PageFactory.initElements(driver, MyAccountPage.class);
	}

	/* display checks */
	public String getUsernameText() {
		return username.getAttribute("value");
	}
	public String getEmailText() {
		return email.getAttribute("value");
	}
	public String getPasswordText() {
		return password.getAttribute("value");
	}
	public boolean isUpdateSuccessfulMsgDisplayed() {
		return updateSuccessfulMsg.isDisplayed();
	}
	public boolean isUsernameEmptyMsgDisplayed() {
		return usernameEmptyMsg.isDisplayed();
	}
	public boolean isUsernameTooLongMsgDisplayed() {
		return usernameTooLongMsg.isDisplayed();
	}
	public boolean isUsernameContainsAtSymbolMsgDisplayed() {
		return usernameContainsAtSymbolMsg.isDisplayed();
	}
	public boolean isUsernameTakenMsgDisplayed() {
		return usernameTakenMsg.isDisplayed();
	}
	public boolean isEmailTooLongMsgDisplayed() {
		return emailTooLongMsg.isDisplayed();
	}
	public boolean isEmailInvalidMsgDisplayed() {
		return emailInvalidMsg.isDisplayed();
	}
	public boolean isEmailTakenMsgDisplayed() {
		return emailTakenMsg.isDisplayed();
	}
}
