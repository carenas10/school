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

import pages.NewMessagePage;
import pages.ThreadPage;

public class NewMessageTest {
	private static WebDriver driver;
	private NewMessagePage page;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		Helper.createAccountAndLogout(Helper.account(1), driver);
		Helper.createAccountAndLogout(Helper.account(2), driver);
		//log in to sender
		Helper.login(Helper.account(1), driver);
	}

	@Before
	public void getPage() {
		driver.get(Helper.baseURL()+"newMessage.php");
		page = PageFactory.initElements(driver, NewMessagePage.class);
	}

	@Test
	public void testMessageWithNoRecipient() {
		page.typeMessage("Here is a message");
		page = page.submitNewMessageWithError();

		assertTrue(page.isRecipientEmptyMsgDisplayed());
	}

	@Test
	public void testNonexistentRecipient() {
		page.typeRecipient("doesnotexist234791389470192347");
		page.typeMessage("message");
		page = page.submitNewMessageWithError();

		assertTrue(page.isRecipientDoesNotExistMsgDisplayed());
	}

	@Test
	public void testEmptyMessage() {
		page.typeRecipient(Helper.account(2).getUsername());
		page = page.submitNewMessageWithError();

		assertTrue(page.isContentEmptyMsgDisplayed());
	}

	@Test
	public void testMessageToSelf() {
		page.typeRecipient(Helper.account(1).getUsername());
		page.typeMessage("message");
		page = page.submitNewMessageWithError();

		assertTrue(page.isMessageToSelfMsgDisplayed());
	}

	@Test
	public void testSuccessfulMessages() {
		//try with regular case username
		ThreadPage threadPage = page.sendMessage(Helper.account(2).getUsername(), "Hey Remarkus!");
		assertEquals(1, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(0));
		assertEquals("Hey Remarkus!", threadPage.getMessage(0));

		//try with upper case username
		driver.get(Helper.baseURL()+"newMessage.php");
		page = PageFactory.initElements(driver, NewMessagePage.class);
		threadPage = page.sendMessage(Helper.account(2).getUsername().toUpperCase(), "Hey Remarkus 2!");
		assertEquals(2, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(1));
		assertEquals("Hey Remarkus 2!", threadPage.getMessage(1));

		//try with lower case username
		driver.get(Helper.baseURL()+"newMessage.php");
		page = PageFactory.initElements(driver, NewMessagePage.class);
		threadPage = page.sendMessage(Helper.account(2).getUsername().toLowerCase(), "Hey Remarkus 3!");
		assertEquals(3, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(2));
		assertEquals("Hey Remarkus 3!", threadPage.getMessage(2));

		//try with regular case email
		driver.get(Helper.baseURL()+"newMessage.php");
		threadPage = page.sendMessage(Helper.account(2).getEmail(), "Hey Remarkus 4!");
		assertEquals(4, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(3));
		assertEquals("Hey Remarkus 4!", threadPage.getMessage(3));

		//try with upper case email
		driver.get(Helper.baseURL()+"newMessage.php");
		page = PageFactory.initElements(driver, NewMessagePage.class);
		threadPage = page.sendMessage(Helper.account(2).getEmail().toUpperCase(), "Hey Remarkus 5!");
		assertEquals(5, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(4));
		assertEquals("Hey Remarkus 5!", threadPage.getMessage(4));

		//try with lower case email
		driver.get(Helper.baseURL()+"newMessage.php");
		page = PageFactory.initElements(driver, NewMessagePage.class);
		threadPage = page.sendMessage(Helper.account(2).getEmail().toLowerCase(), "Hey Remarkus 6!");
		assertEquals(6, threadPage.getNumMessages());
		assertEquals(Helper.account(1).getUsername(), threadPage.getMessageUsername(5));
		assertEquals("Hey Remarkus 6!", threadPage.getMessage(5));
	}

	@AfterClass
	public static void cleanup() {
		Helper.logout(driver);
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		Helper.loginAndDeleteAccount(Helper.account(2), driver);

		//close browser
		driver.quit();
	}
}