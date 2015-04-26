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

import pages.SearchPage;
import pages.UploadPage;

public class SearchTest {
	static WebDriver driver;
	SearchPage page;
	
	//test data
	//insert random numbers into fields to ensure we are finding our test document
	//and not some other media with same name
	static String title = "TestDocumentTitle42789";
	static String description = "DesignDescription899814 for document for testing.";
	static String keyword1 = "keyword1";
	static String keyword2 = "keyword2";
	static String keyword3 = "unique12341asdfjlkm898579";

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();
		
		//create account
		Helper.createAccountAndLogin(Helper.account(1), driver);
		
		//upload media
		driver.get(Helper.baseURL()+"upload.php");
		UploadPage uploadPage = PageFactory.initElements(driver, UploadPage.class);
		uploadPage.upload(title, description, keyword1+", "+keyword2+", "+keyword3, Helper.doc(1).getPath());
	}
	
	@Before
	public void getPage() {
		driver.get(Helper.baseURL()+"search.php");
		page = PageFactory.initElements(driver, SearchPage.class);
	}
	
	@Test
	public void testNoResultsSearch() {
		page.search("completeGarbageasf248970918498");
		assertEquals(page.getNumResults(), 0);
	}
	
	@Test
	public void testSearchForTitle() throws InterruptedException {
		page.search(title);
		assertTrue(page.getNumResults() > 0);
	}
	
	@Test
	public void testSearchDescription() {
		page.search(description);
		assertTrue(page.getNumResults() > 0);
	}
	
	@Test
	public void testSearchIsCaseInsensitive() {
		page.search(keyword3.toUpperCase());
		assertTrue(page.getNumResults() > 0);
		
		page.search(keyword3.toLowerCase());
		assertTrue(page.getNumResults() > 0);
	}
	
	@Test
	public void testSearchKeywords() {
		page.search(keyword1);
		assertTrue(page.getNumResults() > 0);
		
		page.search(keyword2);
		assertTrue(page.getNumResults() > 0);
		
		page.search(keyword3);
		assertTrue(page.getNumResults() > 0);
		
		page.search(keyword3 + " " + keyword2 + " " + keyword1);
		assertTrue(page.getNumResults() > 0);
	}
	
	@AfterClass
	public static void shutdown() {
		//delete test account
		Helper.logout(driver);
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		
		//ensure uploaded media no longer appears
		driver.get(Helper.baseURL()+"search");
		SearchPage searchPage = PageFactory.initElements(driver, SearchPage.class);
		searchPage = searchPage.search(keyword3);
		assertEquals(searchPage.getNumResults(), 0);
		
		//close browser
		driver.quit();
	}
}
