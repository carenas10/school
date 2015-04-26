package tests;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.MyAccountPage;
import pages.RegisterPage;

public class RegisterTest {
	private static WebDriver driver;
	private static RegisterPage page;

	@BeforeClass
	public static void createDriver() {
		driver = new FirefoxDriver();
	}

	@Before
	public void reload() {
		driver.get(Helper.baseURL()+"register.php");
		page = PageFactory.initElements(driver, RegisterPage.class);
	}

	@Test
	public void testErrorMessages1() {
		page.typeUsername(Helper.getStringOfLength(36));
		page.typeEmail(Helper.getStringOfLength(256));
		page.submitRegistration();

		assertTrue(page.isUsernameTooLongMsgDisplayed());
		assertTrue(page.isEmailTooLongMsgDisplayed());
		assertTrue(page.isPasswordEmptyMsgDisplayed());
	}

	@Test
	public void testErrorMessages2() {
		page.typeEmail("blah");
		page.submitRegistration();

		assertTrue(page.isEmailInvalidMsgDisplayed());
		assertTrue(page.isUsernameEmptyMsgDisplayed());
	}
	
	@Test
	public void testMismatchedPasswordsMessage() {
		page.typeUsername(Helper.account(1).getUsername());
		page.typeEmail(Helper.account(1).getEmail());
		page.typePassword("password");
		page.typeConfirmPassword("");
		page.submitRegistration();
		
		assertTrue(page.isPasswordsDoNotMatchMsgDisplayed());
		
		page.typeUsername(Helper.account(1).getUsername());
		page.typeEmail(Helper.account(1).getEmail());
		page.typePassword("password");
		page.typeConfirmPassword("joi81981234an1o23n;oia80134");
		page.submitRegistration();
		
		assertTrue(page.isPasswordsDoNotMatchMsgDisplayed());
		
		page.typeUsername(Helper.account(1).getUsername());
		page.typeEmail(Helper.account(1).getEmail());
		page.typePassword("password");
		page.typeConfirmPassword("Password");
		page.submitRegistration();
		
		assertTrue(page.isPasswordsDoNotMatchMsgDisplayed());
	}

	@Test
	public void testInvalidUsername() {
		//username can't contain @ symbol
		page.typeUsername("Bob@hope");
		page.submitRegistration();

		assertTrue(page.isUsernameContainsAtSymbolMsgDisplayed());
	}

	@Test
	public void testValidRegistrationAndDeletion() {
		page = page.register(Helper.account(1).getUsername(), Helper.account(1).getEmail(), Helper.account(1).getPass());
		assertTrue(page.isRegistrationSuccessfulMsgDisplayed());

		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		accPage = accPage.deleteYourAccount();
		assertTrue(accPage.isAccountDeletedMsgDisplayed());
	}

	@Test
	public void testCreateAccountWithTakenUsername() {
		//create first account
		page = page.register(Helper.account(1).getUsername(), Helper.account(1).getEmail(), Helper.account(1).getPass());
		assertTrue(page.isRegistrationSuccessfulMsgDisplayed());

		//try to create second page
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"register.php");
		page = page.register(Helper.account(1).getUsername(), "whateverEmail@gmail.com", Helper.account(1).getPass());
		assertTrue(page.isUsernameTakenMsgDisplayed());

		//delete first account
		Helper.login(Helper.account(1), driver);
		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		accPage = accPage.deleteYourAccount();
		assertTrue(accPage.isAccountDeletedMsgDisplayed());
	}

	@Test
	public void testCreateAccountWithTakenEmail() {
		//create first account
		page = page.register(Helper.account(1).getUsername(), Helper.account(1).getEmail(), Helper.account(1).getPass());
		assertTrue(page.isRegistrationSuccessfulMsgDisplayed());

		//try to create second page
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"register.php");
		page = page.register("whateverUsername", Helper.account(1).getEmail(), Helper.account(1).getPass());
		assertTrue(page.isEmailTakenMsgDisplayed());

		//delete first account
		Helper.login(Helper.account(1), driver);
		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		accPage = accPage.deleteYourAccount();
		assertTrue(accPage.isAccountDeletedMsgDisplayed());
	}

	@AfterClass
	public static void closeBrowser() {
		driver.quit();
	}
}