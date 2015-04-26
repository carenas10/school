package tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.EditAccountPage;
import pages.LoginPage;
import pages.MyAccountPage;

public class EditAccountTest {
	private static WebDriver driver;
	private static EditAccountPage page;

	@BeforeClass
	public static void createDriver() {
		driver = new FirefoxDriver();

		Helper.createAccountAndLogin(Helper.account(1), driver);
	}

	@Before
	public void reload() {
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
	}

	@Test
	public void testInitialFormValues() {
		//initial form values should be those of the account
		assertEquals(Helper.account(1).getUsername(), page.getUsernameText());
		assertEquals(Helper.account(1).getEmail(), page.getEmailText());
		assertEquals("", page.getPasswordText());
	}

	@Test
	public void testErrorMessages1() {
		page.typeUsername(Helper.getStringOfLength(36));
		page.typeEmail(Helper.getStringOfLength(256));
		page.submitSaveChanges();

		assertTrue(page.isUsernameTooLongMsgDisplayed());
		assertTrue(page.isEmailTooLongMsgDisplayed());
	}

	@Test
	public void testErrorMessages2() {
		page.typeUsername("");
		page.typeEmail("blah");
		page.typePassword("A password");
		page.submitSaveChanges();

		assertTrue(page.isEmailInvalidMsgDisplayed());
		assertTrue(page.isUsernameEmptyMsgDisplayed());

		//ensure changes were saved
		assertEquals("", page.getUsernameText());
		assertEquals("blah", page.getEmailText());
		//ensure password did not persist
		assertEquals("", page.getPasswordText());
	}

	@Test
	public void testInvalidUsername() {
		//username can't contain @ symbol
		page.typeUsername("Bob@hope");
		page.submitSaveChanges();

		assertTrue(page.isUsernameContainsAtSymbolMsgDisplayed());
	}

	@Test
	public void testUsernameChange() {
		//change username
		page.typeUsername(Helper.account(2).getUsername());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());

		//try logging out and back in with new username
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		loginPage.login(Helper.account(2).getUsername(), Helper.account(1).getPass());
		assertTrue(loginPage.isLogoutButtonDisplayed());

		//change username back
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typeUsername(Helper.account(1).getUsername());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());
	}

	@Test
	public void testEmailChange() {
		//change email
		page.typeEmail(Helper.account(2).getEmail());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());

		//try logging out and back in with new email
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		loginPage.login(Helper.account(2).getEmail(), Helper.account(1).getPass());
		assertTrue(loginPage.isLogoutButtonDisplayed());

		//change email back
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typeEmail(Helper.account(1).getEmail());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());
	}

	@Test
	public void testPasswordChange() {
		//change password
		page.typePassword(Helper.account(2).getPass());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());

		//try logging out and back in with new password
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		loginPage.login(Helper.account(1).getEmail(), Helper.account(2).getPass());
		assertTrue(loginPage.isLogoutButtonDisplayed());

		//change password back
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typePassword(Helper.account(1).getPass());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());
	}

	@Test
	public void testCancelChanges() {
		//make changes and cancel them
		page.typeUsername(Helper.account(2).getUsername());
		page.typeEmail(Helper.account(2).getEmail());
		page.typePassword(Helper.account(2).getPass());
		MyAccountPage myAccountPage = page.submitCancelChanges();

		assertTrue(myAccountPage.isEditAccountButtonDisplayed());
		page = myAccountPage.goToEditAccount();
		
		//ensure original info persists
		assertEquals(Helper.account(1).getUsername(), page.getUsernameText());
		assertEquals(Helper.account(1).getEmail(), page.getEmailText());
		assertEquals("", page.getPasswordText());

		//ensure you can log out and in with original info
		Helper.logout(driver);
		LoginPage loginPage = Helper.login(Helper.account(1), driver);
		assertTrue(loginPage.isLogoutButtonDisplayed());
	}

	@Test
	public void testSimultaneousChanges() {
		//change username, email, and password
		page.typeUsername(Helper.account(2).getUsername());
		page.typeEmail(Helper.account(2).getEmail());
		page.typePassword(Helper.account(2).getPass());
		page.submitSaveChanges();

		assertTrue(page.isUpdateSuccessfulMsgDisplayed());

		//try logging out and back in with new email/pass
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		loginPage.login(Helper.account(2).getEmail(), Helper.account(2).getPass());
		assertTrue(loginPage.isLogoutButtonDisplayed());

		//try logging out and back in with new username/pass
		Helper.logout(driver);
		driver.get(Helper.baseURL()+"login.php");
		loginPage = PageFactory.initElements(driver, LoginPage.class);
		loginPage.login(Helper.account(2).getUsername(), Helper.account(2).getPass());
		assertTrue(loginPage.isLogoutButtonDisplayed());

		//change info back
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typeUsername(Helper.account(1).getUsername());
		page.typeEmail(Helper.account(1).getEmail());
		page.typePassword(Helper.account(1).getPass());
		page.submitSaveChanges();
		assertTrue(page.isUpdateSuccessfulMsgDisplayed());
	}

	@Test
	public void testTakenUsernameAndEmail() {
		//create second account
		Helper.logout(driver);
		Helper.createAccountAndLogout(Helper.account(3), driver);
		
		//try setting account 1's email to account 3's email
		Helper.login(Helper.account(1), driver);
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typeEmail(Helper.account(3).getEmail());
		page.submitSaveChanges();
		
		assertTrue(page.isEmailTakenMsgDisplayed());

		//try setting account 1's username to account 3's username
		driver.get(Helper.baseURL()+"editAccount.php");
		page = PageFactory.initElements(driver, EditAccountPage.class);
		page.typeUsername(Helper.account(3).getUsername());
		page.submitSaveChanges();
		
		assertTrue(page.isUsernameTakenMsgDisplayed());
		
		//delete account 3
		Helper.logout(driver);
		Helper.loginAndDeleteAccount(Helper.account(3), driver);
		
		//log back into account 1
		LoginPage loginPage = Helper.login(Helper.account(1), driver);
		assertTrue(loginPage.isLogoutButtonDisplayed());
	}
	@AfterClass
	public static void closeBrowser() {
		Helper.deleteAccount(driver);
		driver.quit();
	}
}