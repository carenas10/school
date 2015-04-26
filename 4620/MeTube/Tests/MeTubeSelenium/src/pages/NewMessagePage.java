package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;

public class NewMessagePage extends PageObject {
	public NewMessagePage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"newMessage"));
	}
	
	//interactive elements
	private WebElement messageRecipient;
	private WebElement messageContent;
	private WebElement submitNewMessage;
	
	//message elements
	private WebElement messageSentSuccessfullyMsg;
	private WebElement recipientEmptyMsg;
	private WebElement recipientDoesNotExistMsg;
	private WebElement messageToSelfMsg;
	private WebElement contentEmptyMsg;
	private WebElement contentTooLongMsg;
	
	/* input actions */
	public NewMessagePage typeRecipient(String recipient) {
		messageRecipient.clear();
		messageRecipient.sendKeys(recipient);
		return this;
	}
	public NewMessagePage typeMessage(String message) {
		messageContent.clear();
		messageContent.sendKeys(message);
		return this;
	}
	//errors redirect to NewMessagePage
	//successfully sent messages redirect to ThreadPage
	public NewMessagePage submitNewMessageWithError() {
		submitNewMessage.click();
		return this;
	}
	public ThreadPage submitNewMessage() {
		submitNewMessage.click();
		ThreadPage newPage = PageFactory.initElements(driver, ThreadPage.class);
		return newPage;
	}
	
	/* message checks */
	public boolean isMessageSuccessfulSentMsgDisplayed() {
		return messageSentSuccessfullyMsg.isDisplayed();
	}
	public boolean isRecipientEmptyMsgDisplayed() {
		return recipientEmptyMsg.isDisplayed();
	}
	public boolean isRecipientDoesNotExistMsgDisplayed() {
		return recipientDoesNotExistMsg.isDisplayed();
	}
	public boolean isMessageToSelfMsgDisplayed() {
		return messageToSelfMsg.isDisplayed();
	}
	public boolean isContentEmptyMsgDisplayed() {
		return contentEmptyMsg.isDisplayed();
	}
	public boolean isContentTooLongMsgDisplayed() {
		return contentTooLongMsg.isDisplayed();
	}
	
	/* services */
	public ThreadPage sendMessage(String recipient, String message) {
		typeRecipient(recipient);
		typeMessage(message);
		return submitNewMessage();
	}
	public NewMessagePage sendMessageWithError(String recipient, String message) {
		typeRecipient(recipient);
		typeMessage(message);
		return submitNewMessageWithError();
	}
}
