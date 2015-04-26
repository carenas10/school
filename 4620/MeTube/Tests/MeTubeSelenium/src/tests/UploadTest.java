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

import pages.UploadPage;

public class UploadTest {
	private static WebDriver driver;
	private UploadPage page;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test account
		Helper.createAccountAndLogin(Helper.account(1), driver);
	}

	@Before
	public void getPage() {
		driver.get(Helper.baseURL()+"upload.php");
		page = PageFactory.initElements(driver, UploadPage.class);
	}

	@Test
	public void testEmptySubmitErrorMessages() {
		page.submitUpload();

		assertTrue(page.isDescriptionEmptyMsgDisplayed());
		assertTrue(page.isTitleEmptyMsgDisplayed());
		assertTrue(page.isNoFileSelectedMsgDisplayed());
	}

	@Test
	public void testInvalidErrorMessages() {
		page.typeTitle(Helper.getStringOfLength(71));
		page.typeDescription(Helper.getStringOfLength(256));
		page.typeKeywords(Helper.getStringOfLength(36));
		page.submitUpload();

		assertTrue(page.isTitleTooLongMsgDisplayed());
		assertTrue(page.isDescriptionTooLongMsgDisplayed());
		assertTrue(page.isKeywordTooLongMsgDisplayed());
	}

	@Test
	public void testSuccessfulUpload() throws InterruptedException {
		page.upload("Design Doc", "Design document for CPSC 4620 project", "design database mindnode", Helper.doc(1).getPath());
		assertTrue(page.isUploadSuccessfulMsgDisplayed());
	}

	@AfterClass
	public static void closeBrowser() {
		//delete account
		Helper.deleteAccount(driver);

		//close browser
		driver.quit();
	}
}