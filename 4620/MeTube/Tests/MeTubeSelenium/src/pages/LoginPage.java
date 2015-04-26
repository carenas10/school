package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;

public class LoginPage extends PageObject {
	public LoginPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"login"));
	}

	//interactive elements
	private WebElement email;
	private WebElement password;
	private WebElement login;
	private WebElement logout;
	
	//message elements
	private WebElement incorrectCredentialsMsg;
	private WebElement emailUsernameTooLongMsg;

	/* inputs action */
	public LoginPage typeEmailUsername(String emailOrUsername) {
		email.clear();
		email.sendKeys(emailOrUsername);
		return this;
	}
	public LoginPage typePassword(String _password) {
		password.clear();
		password.sendKeys(_password);
		return this;
	}
	public LoginPage submitLogin() {
		login.click();
		return this;
	}
	public LoginPage submitLogout() {
		logout.click();
		return this;
	}
	
	/* display checks */
	public boolean isEmailUsernameTooLongMsgDisplayed() {
		return emailUsernameTooLongMsg.isDisplayed();
	}
	public boolean isIncorrectCredentialsMsgDisplayed() {
		return incorrectCredentialsMsg.isDisplayed();
	}
	public boolean isLoginButtonDisplayed() {
		return login.isDisplayed();
	}
	public boolean isLogoutButtonDisplayed() {
		return logout.isDisplayed();
	}

	/* services */
	public LoginPage login(String emailOrUsername, String password) {
		typeEmailUsername(emailOrUsername);
		typePassword(password);
		submitLogin();
		return this;
	}
	public InboxPage loginAndRedirectToInbox(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, InboxPage.class); 
	}
	public ThreadPage loginAndRedirectToThread(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, ThreadPage.class); 
	}
	public NewMessagePage loginAndRedirectToNewMessage(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, NewMessagePage.class); 
	}
	public UploadPage loginAndRedirectToUpload(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, UploadPage.class); 
	}
	public SubscriptionsPage loginAndRedirectToSubscriptions(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, SubscriptionsPage.class); 
	}
	public MyAccountPage loginAndRedirectToMyAccount(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, MyAccountPage.class); 
	}
	public PlaylistsPage loginAndRedirectToPlaylists(String emailOrUsername, String password) {
		login(emailOrUsername, password);
		return PageFactory.initElements(driver, PlaylistsPage.class); 
	}
}