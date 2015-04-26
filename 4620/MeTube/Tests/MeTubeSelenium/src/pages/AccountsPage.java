package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class AccountsPage extends PageObject {
	public AccountsPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"accounts"));
	}
	
	@FindBy(className = "accountName")
	private List<WebElement> accounts;

	/* result checks */
	public int getNumAccounts() {
		return accounts.size();
	}
	public String getAccountName(int i) {
		return accounts.get(i).getText();
	}
	
	/* services */
	public AccountPage goToAccount(int i) {
		accounts.get(i).click();
		AccountPage newPage = PageFactory.initElements(driver, AccountPage.class);
		return newPage;
	}
	public AccountPage goToAccount(String accountName) {
		for(int i = 0; i < accounts.size(); i++) {
			if(accounts.get(i).getText().equalsIgnoreCase(accountName)) {
				return goToAccount(i);
			}
		}
		return null;
	}
}
