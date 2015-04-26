package tests;

import static org.junit.Assert.assertTrue;
import help.Helper;
import help.TestAccount;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.LoginPage;
import pages.MyAccountPage;
import pages.RegisterPage;

public class LoginTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();
	}

	@Test
	public void testLoginLogout() {
		TestAccount account = Helper.account(1);
		//create account
		driver.get(Helper.baseURL()+"register.php");
		RegisterPage regPage = PageFactory.initElements(driver, RegisterPage.class);
		regPage.register(account.getUsername(), account.getEmail(), account.getPass());

		//log out
		driver.get(Helper.baseURL()+"login.php");
		LoginPage page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLogoutButtonDisplayed());
		page.submitLogout();
		
		//failed login with email
		assertTrue(page.isLoginButtonDisplayed());
		page = page.login(account.getEmail(), "wrongPassword");
		assertTrue(page.isIncorrectCredentialsMsgDisplayed());
		
		//failed login with username
		assertTrue(page.isLoginButtonDisplayed());
		page = page.login(account.getUsername(), "wrongPassword");
		assertTrue(page.isIncorrectCredentialsMsgDisplayed());
		
		//too long email/username
		assertTrue(page.isLoginButtonDisplayed());
		page = page.login(Helper.getStringOfLength(256), account.getPass());
		assertTrue(page.isEmailUsernameTooLongMsgDisplayed());
		
		//successful login with email
		assertTrue(page.isLoginButtonDisplayed());
		page = page.login(account.getEmail(), account.getPass());
		assertTrue(page.isLogoutButtonDisplayed());
		
		//logout
		page.submitLogout();
		
		//successful login with username
		assertTrue(page.isLoginButtonDisplayed());
		page = page.login(account.getUsername(), account.getPass());
		assertTrue(page.isLogoutButtonDisplayed());
		
		//delete account
		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		accPage.deleteYourAccount();
	}

	@AfterClass
	public static void closeBrowser() {
		driver.quit();
	}
}