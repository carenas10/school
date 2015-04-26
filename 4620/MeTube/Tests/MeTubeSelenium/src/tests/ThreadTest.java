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
import org.testng.Assert;

import pages.InboxPage;
import pages.NewMessagePage;
import pages.ThreadPage;

public class ThreadTest {
	private static WebDriver driver;
	private ThreadPage page;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test accounts
		Helper.createAccountAndLogout(Helper.account(1), driver);
		Helper.createAccountAndLogout(Helper.account(2), driver);
		
		//login to first account
		Helper.login(Helper.account(1), driver);
		
		//send initial message
		driver.get(Helper.baseURL()+"newMessage.php");
		NewMessagePage newMessagePage = PageFactory.initElements(driver, NewMessagePage.class);
		newMessagePage.sendMessage(Helper.account(2).getUsername(), "First Message");
	}

	@Before
	public void getPage() {
		//get thread from inbox
		driver.get(Helper.baseURL()+"inbox.php");
		InboxPage inboxPage = PageFactory.initElements(driver, InboxPage.class);
		assertEquals(1, inboxPage.getNumThreads());
		page = inboxPage.goToThread(Helper.account(2).getUsername());
		Assert.assertNotNull(page);
	}

	@Test
	public void testEmptyMessageMsg() {
		page = page.submitNewMessage();

		assertTrue(page.isContentEmptyMsgDisplayed());
	}

	@Test
	public void testSuccessfulMessages() {
		assertEquals(1, page.getNumMessages());
		
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(0));
		assertEquals("First Message", page.getMessage(0));
		
		page = page.sendMessage("Second Message");
		page = page.sendMessage("Third Message");
		page = page.sendMessage("Fourth Message");
		
		//ensure sent messages show up
		assertEquals(4, page.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(1));
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(2));
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(3));
		assertEquals("Second Message", page.getMessage(1));
		assertEquals("Third Message", page.getMessage(2));
		assertEquals("Fourth Message", page.getMessage(3));
		
		//switch accounts and send message
		Helper.logout(driver);
		Helper.login(Helper.account(2), driver);
		
		//go to thread
		driver.get(Helper.baseURL()+"inbox.php");
		InboxPage inboxPage = PageFactory.initElements(driver, InboxPage.class);
		page = inboxPage.goToThread(Helper.account(1).getUsername());
		
		//send new messages
		page = page.sendMessage("Account 2's message");
		page = page.sendMessage("Account 2's second message");
		
		//ensure all messages appear with correct usernames
		assertEquals(6, page.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(0));
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(1));
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(2));
		assertEquals(Helper.account(1).getUsername(), page.getMessageUsername(3));
		assertEquals("First Message", page.getMessage(0));
		assertEquals("Second Message", page.getMessage(1));
		assertEquals("Third Message", page.getMessage(2));
		assertEquals("Fourth Message", page.getMessage(3));
		assertEquals(Helper.account(2).getUsername(), page.getMessageUsername(4));
		assertEquals(Helper.account(2).getUsername(), page.getMessageUsername(5));
		assertEquals("Account 2's message", page.getMessage(4));
		assertEquals("Account 2's second message", page.getMessage(5));
		
		//switch back to account 1
		Helper.logout(driver);
		Helper.login(Helper.account(1), driver);
	}

	@AfterClass
	public static void cleanup() {
		//delete test accounts
		Helper.logout(driver);
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		Helper.loginAndDeleteAccount(Helper.account(2), driver);

		//close browser
		driver.quit();
	}
}