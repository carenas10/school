package tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.MediaPage;
import pages.SearchPage;

public class CommentTest {
	private static WebDriver driver;
	private MediaPage page;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test accounts
		Helper.createAccountAndLogout(Helper.account(1), driver);
		Helper.createAccountAndLogout(Helper.account(2), driver);
		
		//upload test document
		Helper.login(Helper.account(1), driver);
		Helper.upload(Helper.doc(1), driver);
		Helper.logout(driver);
	}
	
	public void getMediaPage() {
		driver.get(Helper.baseURL()+"search");
		SearchPage searchPage = PageFactory.initElements(driver, SearchPage.class);
		searchPage.search(Helper.doc(1).getTitle());
		assertTrue(searchPage.getNumResults() == 1);
		page = searchPage.selectResult(0);
	}

	@Test
	public void testEmptyComments() {
		Helper.login(Helper.account(1), driver);
		getMediaPage();
		
		page.comment("");
		assertTrue(page.isCommentEmptyMsgDisplayed());

		//spaces
		page.comment("         ");
		assertTrue(page.isCommentEmptyMsgDisplayed());
		
		//tabs
		page.comment("			");
		assertTrue(page.isCommentEmptyMsgDisplayed());
		
		//mixed tabs and spaces
		page.comment(" 		  	 	");
		assertTrue(page.isCommentEmptyMsgDisplayed());
		
		Helper.logout(driver);
	}
	
	@Test
	public void testTooLongComment() {
		Helper.login(Helper.account(1), driver);
		getMediaPage();
		
		page.comment(Helper.getStringOfLength(501));
		assertTrue(page.isCommentTooLongMsgDisplayed());
		Helper.logout(driver);
	}

	@Test
	public void testMultipleValidComments() throws InterruptedException {
		Helper.login(Helper.account(1), driver);
		getMediaPage();
		
		//must sleep for one second between comments so database can detect time difference
		page.comment("comment 0");
		Thread.sleep(1000);
		page.comment("comment 1");
		Thread.sleep(1000);
		page.comment("comment 2");
		
		Helper.logout(driver);
		
		Helper.login(Helper.account(2), driver);
		getMediaPage();
		
		page.comment("comment 3");
		Thread.sleep(1000);
		page.comment("comment 4");
		
		//comments should appear in reverse chronological order
		assertEquals(5, page.getNumComments());
		assertEquals(Helper.account(2).getUsername(), page.getCommentUsername(0));
		assertEquals(Helper.account(2).getUsername(), page.getCommentUsername(1));
		assertEquals(Helper.account(1).getUsername(), page.getCommentUsername(2));
		assertEquals(Helper.account(1).getUsername(), page.getCommentUsername(3));
		assertEquals(Helper.account(1).getUsername(), page.getCommentUsername(4));
		assertEquals("comment 4", page.getComment(0));
		assertEquals("comment 3", page.getComment(1));
		assertEquals("comment 2", page.getComment(2));
		assertEquals("comment 1", page.getComment(3));
		assertEquals("comment 0", page.getComment(4));
		
		Helper.logout(driver);
	}

	@AfterClass
	public static void cleanup() {
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		Helper.loginAndDeleteAccount(Helper.account(2), driver);

		//close browser
		driver.quit();
	}
}