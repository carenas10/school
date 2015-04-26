package tests;

import static org.junit.Assert.assertEquals;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.InboxPage;
import pages.NewMessagePage;

public class InboxTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		Helper.createAccountAndLogout(Helper.account(1), driver);
		Helper.createAccountAndLogout(Helper.account(2), driver);
		Helper.createAccountAndLogout(Helper.account(3), driver);
	}

	@Test
	public void testThreadsAppear() {
		//log in to account 1
		Helper.login(Helper.account(1), driver);

		//send message to account 2
		driver.get(Helper.baseURL()+"newMessage.php");
		NewMessagePage newMessagePage = PageFactory.initElements(driver, NewMessagePage.class);
		newMessagePage.sendMessage(Helper.account(2).getUsername(), "A message to account 2");

		//send message to account 3
		driver.get(Helper.baseURL()+"newMessage.php");
		newMessagePage = PageFactory.initElements(driver, NewMessagePage.class);
		newMessagePage.sendMessage(Helper.account(3).getUsername(), "A message to account 3");

		//make sure threads show up in account 1's inbox
		driver.get(Helper.baseURL()+"inbox.php");
		InboxPage inboxPage = PageFactory.initElements(driver, InboxPage.class);
		assertEquals(2, inboxPage.getNumThreads());

		//log in to account 2
		Helper.logout(driver);
		Helper.login(Helper.account(2), driver);

		//make sure thread from account 1 shows up
		driver.get(Helper.baseURL()+"inbox.php");
		inboxPage = PageFactory.initElements(driver, InboxPage.class);
		assertEquals(1, inboxPage.getNumThreads());
		assertEquals(Helper.account(1).getUsername(), inboxPage.getThreadUsername(0));
		assertEquals("A message to account 2", inboxPage.getThreadPreview(0));

		//log in to account 3
		Helper.logout(driver);
		Helper.login(Helper.account(3), driver);

		//make sure thread from account 1 shows up
		driver.get(Helper.baseURL()+"inbox.php");
		inboxPage = PageFactory.initElements(driver, InboxPage.class);
		assertEquals(1, inboxPage.getNumThreads());
		assertEquals(Helper.account(1).getUsername(), inboxPage.getThreadUsername(0));
		assertEquals("A message to account 3", inboxPage.getThreadPreview(0));

		//log out
		Helper.logout(driver);
	}

	@AfterClass
	public static void cleanup() {
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		Helper.loginAndDeleteAccount(Helper.account(2), driver);
		Helper.loginAndDeleteAccount(Helper.account(3), driver);
		
		//close browser
		driver.quit();
	}
}