package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class RegisterPage extends PageObject {
	public RegisterPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"register"));
	}

	//interactive elements
	private WebElement username;
	private WebElement email;
	private WebElement password;
	private WebElement confirmPassword;
	private WebElement registerUser;
	
	//message elements
	private WebElement registrationSuccessfulMsg;
	private WebElement usernameTooLongMsg;
	private WebElement usernameEmptyMsg;
	private WebElement usernameContainsAtSymbolMsg;
	private WebElement usernameTakenMsg;
	private WebElement emailTooLongMsg;
	private WebElement emailInvalidMsg;
	private WebElement emailTakenMsg;
	private WebElement passwordEmptyMsg;
	private WebElement passwordsDoNotMatchMsg;

	/* input actions */
	public RegisterPage typeUsername(String _username) {
		username.clear();
		username.sendKeys(_username);
		return this;
	}
	public RegisterPage typeEmail(String _email) {
		email.clear();
		email.sendKeys(_email);
		return this;
	}
	public RegisterPage typePassword(String _password) {
		password.clear();
		password.sendKeys(_password);
		return this;
	}
	public RegisterPage typeConfirmPassword(String _password) {
		confirmPassword.clear();
		confirmPassword.sendKeys(_password);
		return this;
	}
	public RegisterPage submitRegistration() {
		registerUser.click();
		return this;
	}
	
	/* display checks */
	public boolean isRegistrationSuccessfulMsgDisplayed() {
		return registrationSuccessfulMsg.isDisplayed();
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
	public boolean isPasswordEmptyMsgDisplayed() {
		return passwordEmptyMsg.isDisplayed();
	}
	public boolean isPasswordsDoNotMatchMsgDisplayed() {
		return passwordsDoNotMatchMsg.isDisplayed();
	}

	/* services */
	public RegisterPage register(String username, String email, String password) {
		typeUsername(username);
		typeEmail(email);
		typePassword(password);
		typeConfirmPassword(password);
		submitRegistration();
		return this;
	}
}