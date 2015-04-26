package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class ThreadPage extends PageObject {
	public ThreadPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"thread"));
	}
	
	//interactive elements
	private WebElement messageContent;
	private WebElement submitNewMessage;
	
	//results elements
	@FindBy(className="senderUsername")
	private List<WebElement> senderUsernames;
	@FindBy(className="messageContent")
	private List<WebElement> messages;
	
	//message elements
	private WebElement contentEmptyMsg;
	private WebElement contentTooLongMsg;
	
	/* input actions */
	public ThreadPage typeMessage(String message) {
		messageContent.clear();
		messageContent.sendKeys(message);
		return this;
	}
	public ThreadPage submitNewMessage() {
		submitNewMessage.click();
		return this;
	}

	/* result checks */
	public int getNumMessages() {
		assert(senderUsernames.size() == messages.size());
		return senderUsernames.size();
	}
	public String getMessageUsername(int i) {
		return senderUsernames.get(i).getText();
	}
	public String getMessage(int i) {
		return messages.get(i).getText();
	}
	
	/* message checks */
	public boolean isContentEmptyMsgDisplayed() {
		return contentEmptyMsg.isDisplayed();
	}
	public boolean isContentTooLongMsgDisplayed() {
		return contentTooLongMsg.isDisplayed();
	}
	
	/* services */
	public ThreadPage sendMessage(String message) {
		typeMessage(message);
		submitNewMessage();
		return this;
	}
}
