package help;

import org.openqa.selenium.WebDriver;

import static org.junit.Assert.assertTrue;

import org.openqa.selenium.support.PageFactory;

import pages.LoginPage;
import pages.MyAccountPage;
import pages.RegisterPage;
import pages.UploadPage;

public class Helper {
	public static String baseURL() {
		return "http://people.cs.clemson.edu/~bmgeorg/";
	}
	
	public static TestAccount account(int i) {
		switch(i) {
		case 1:
			return new TestAccount("Quantisha", "quantish123@hotmail.com", "brett1");
		case 2:
			return new TestAccount("Remarkus", "remarkus@gmail.com", "brett2");
		case 3:
			return new TestAccount("blackbaud", "blackbaud@yahoo.com", "brett3");
		default:
			throw new IllegalArgumentException();
		}
	}
	
	public static TestDoc doc(int i) {
		switch(i) {
		case 1:
			return new TestDoc("DesignDoc90970984920341234",
					"Database620database89u41234",
					"designdocumentdatabase1234",
					"image.png");
		default:
			throw new IllegalArgumentException();
		}
	}
	
	public static UploadPage upload(TestDoc doc, WebDriver driver) {
		driver.get(Helper.baseURL()+"upload.php");
		UploadPage page = PageFactory.initElements(driver, UploadPage.class);
		page.upload(doc.getTitle(), doc.getDescription(), doc.getKeywords(), doc.getPath());
		assertTrue(page.isUploadSuccessfulMsgDisplayed());
		return page;
	}
	
	public static RegisterPage createAccountAndLogin(TestAccount account, WebDriver driver) {
		//register account
		driver.get(Helper.baseURL()+"register.php");
		RegisterPage regPage = PageFactory.initElements(driver, RegisterPage.class);
		return regPage.register(account.getUsername(), account.getEmail(), account.getPass());
	}
	
	public static LoginPage createAccountAndLogout(TestAccount account, WebDriver driver) {
		//register account
		driver.get(Helper.baseURL()+"register.php");
		RegisterPage regPage = PageFactory.initElements(driver, RegisterPage.class);
		regPage.register(account.getUsername(), account.getEmail(), account.getPass());
		
		return logout(driver);
	}
	
	public static LoginPage login(TestAccount account, WebDriver driver) {
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		return loginPage.login(account.getUsername(), account.getPass());
	}
	
	public static LoginPage logout(WebDriver driver) {
		driver.get(Helper.baseURL()+"login.php");
		LoginPage loginPage = PageFactory.initElements(driver, LoginPage.class);
		return loginPage.submitLogout();
	}
	
	public static MyAccountPage loginAndDeleteAccount(TestAccount account, WebDriver driver) {
		login(account, driver);
		
		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		return accPage.deleteYourAccount();
	}
	
	public static MyAccountPage deleteAccount(WebDriver driver) {
		driver.get(Helper.baseURL()+"myAccount.php");
		MyAccountPage accPage = PageFactory.initElements(driver, MyAccountPage.class);
		return accPage.deleteYourAccount();
	}
	
	public static String getStringOfLength(int length) {
		StringBuffer result = new StringBuffer();
		for(int i = 0; i < length; i++) {
			result.append('a');
		}
		return result.toString();
	}
}
