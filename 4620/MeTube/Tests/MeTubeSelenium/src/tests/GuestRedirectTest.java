package tests;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.InboxPage;
import pages.LoginPage;
import pages.MyAccountPage;
import pages.NewMessagePage;
import pages.PlaylistsPage;
import pages.SubscriptionsPage;
import pages.UploadPage;

public class GuestRedirectTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();
		
		//create test account
		Helper.createAccountAndLogout(Helper.account(1), driver);
	}
	
	@Test
	@SuppressWarnings("unused")
	public void testGuestRedirectsToLogin() {
		//ensure that for each of the following pages, not-logged-in guests get redirected to login
		//also ensure that after login, user gets redirected to page she/he originally requested
		driver.get(Helper.baseURL()+"inbox");
		LoginPage page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		InboxPage inboxPage = page.loginAndRedirectToInbox(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"thread");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		//instead of redirecting to a thread, this should redirect to inbox since no threadID is specified
		inboxPage = page.loginAndRedirectToInbox(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"newMessage");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		NewMessagePage newMessagePage = page.loginAndRedirectToNewMessage(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"upload");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		UploadPage uploadPage = page.loginAndRedirectToUpload(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"subscriptions");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		SubscriptionsPage subscriptionsPage = page.loginAndRedirectToSubscriptions(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"playlists");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		PlaylistsPage playlistsPage = page.loginAndRedirectToPlaylists(Helper.account(1).getEmail(), Helper.account(1).getPass());
		Helper.logout(driver);
		
		
		driver.get(Helper.baseURL()+"myAccount");
		page = PageFactory.initElements(driver, LoginPage.class);
		assertTrue(page.isLoginButtonDisplayed());
		MyAccountPage myAccountPage = page.loginAndRedirectToMyAccount(Helper.account(1).getEmail(), Helper.account(1).getPass());
	}

	@AfterClass
	public static void cleanup() {
		//delete test account
		Helper.deleteAccount(driver);
		
		//close browser
		driver.quit();
	}
}