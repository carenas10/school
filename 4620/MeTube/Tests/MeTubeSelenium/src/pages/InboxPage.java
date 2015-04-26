package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class InboxPage extends PageObject {
	public InboxPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"inbox"));
	}
	
	@FindBy(className="threadUsername")
	private List<WebElement> threadUsernames;
	@FindBy(className="threadPreview")
	private List<WebElement> threadPreviews;

	/* result checks */
	public int getNumThreads() {
		assert(threadUsernames.size() == threadPreviews.size());
		return threadUsernames.size();
	}
	public String getThreadUsername(int i) {
		return threadUsernames.get(i).getText();
	}
	public String getThreadPreview(int i) {
		return threadPreviews.get(i).getText();
	}
	
	/* services */
	public ThreadPage goToThread(int i) {
		threadUsernames.get(i).click();
		ThreadPage newPage = PageFactory.initElements(driver, ThreadPage.class);
		return newPage;
	}
	public ThreadPage goToThread(String username) {
		for(int i = 0; i < threadUsernames.size(); i++) {
			if(threadUsernames.get(i).getText().equalsIgnoreCase(username)) {
				return goToThread(i);
			}
		}
		return null;
	}
}
