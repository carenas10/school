package tests;

import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.AccountPage;
import pages.AccountsPage;
import pages.SubscriptionsPage;

public class SubscriptionsTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test accounts
		Helper.createAccountAndLogout(Helper.account(1), driver);
		Helper.createAccountAndLogout(Helper.account(2), driver);
	}

	@Test
	public void testSubscriptions() {
		//log into first account
		Helper.login(Helper.account(1), driver);

		//test no subscriptions
		driver.get(Helper.baseURL()+"subscriptions.php");
		SubscriptionsPage subPage = PageFactory.initElements(driver, SubscriptionsPage.class);
		assertTrue(subPage.isNoSusbscriptionsMsgDisplayed());
		
		//subscribe to account 2's channel
		driver.get(Helper.baseURL()+"accounts.php");
		AccountsPage accountsPage = PageFactory.initElements(driver, AccountsPage.class);
		AccountPage accPage = accountsPage.goToAccount(Helper.account(2).getUsername());
		assertTrue(accPage.isSubscribeButtonDisplayed());
		accPage.subscribe();
		
		//test subscriptions show up
		driver.get(Helper.baseURL()+"subscriptions.php");
		subPage = PageFactory.initElements(driver, SubscriptionsPage.class);
		assertTrue(subPage.isYourSubscriptionsHeaderDisplayed());
		
		//log out
		Helper.logout(driver);
	}

	@AfterClass
	public static void closeBrowser() {
		//delete test accounts
		Helper.loginAndDeleteAccount(Helper.account(1), driver);
		Helper.loginAndDeleteAccount(Helper.account(2), driver);
		
		//close browser
		driver.quit();
	}
}