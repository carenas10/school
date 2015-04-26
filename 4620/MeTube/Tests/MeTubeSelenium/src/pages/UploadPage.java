package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.io.File;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class UploadPage extends PageObject {
	public UploadPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"upload"));
	}

	//interactive elements
	private WebElement title;
	private WebElement description;
	private WebElement keywords;
	private WebElement fileToUpload;
	private WebElement upload; 

	//message elements
	private WebElement uploadSuccessfulMsg;
	private WebElement titleEmptyMsg;
	private WebElement descriptionEmptyMsg;
	private WebElement titleTooLongMsg;
	private WebElement descriptionTooLongMsg;
	private WebElement keywordTooLongMsg;
	private WebElement noFileSelectedMsg;


	/* inputs action */
	public UploadPage typeTitle(String _title) {
		title.clear();
		title.sendKeys(_title);
		return this;
	}
	public UploadPage typeDescription(String _description) {
		description.clear();
		description.sendKeys(_description);
		return this;
	}
	public UploadPage typeKeywords(String _keywords) {
		keywords.clear();
		keywords.sendKeys(_keywords);
		return this;
	}
	public UploadPage chooseFile(String filePath) {
		File f = new File(filePath);
		fileToUpload.sendKeys(f.getAbsolutePath());
		return this;
	}
	public UploadPage submitUpload() {
		upload.click();
		return this;
	}

	/* display checks */
	public boolean isUploadSuccessfulMsgDisplayed() {
		return uploadSuccessfulMsg.isDisplayed();
	}
	public boolean isTitleEmptyMsgDisplayed() {
		return titleEmptyMsg.isDisplayed();
	}
	public boolean isTitleTooLongMsgDisplayed() {
		return titleTooLongMsg.isDisplayed();
	}
	public boolean isDescriptionEmptyMsgDisplayed() {
		return descriptionEmptyMsg.isDisplayed();
	}
	public boolean isDescriptionTooLongMsgDisplayed() {
		return descriptionTooLongMsg.isDisplayed();
	}
	public boolean isKeywordTooLongMsgDisplayed() {
		return keywordTooLongMsg.isDisplayed();
	}
	public boolean isNoFileSelectedMsgDisplayed() {
		return noFileSelectedMsg.isDisplayed();
	}

	/* services */
	public UploadPage upload(String title, String description, String keywords, String filePath) {
		chooseFile(filePath);
		typeTitle(title);
		typeDescription(description);
		typeKeywords(keywords);
		submitUpload();
		return this;
	}
}