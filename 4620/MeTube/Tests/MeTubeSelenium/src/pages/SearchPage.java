package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class SearchPage extends PageObject {
	public SearchPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"search"));
	}
	
	//interactive elements
	@FindBy(className = "search_button")
	private WebElement search_button;
	private WebElement searchQuery;
	
	//result elements
	@FindBy(className = "searchResult")
	private List<WebElement> searchResults;

	/* input actions */
	public SearchPage typeSearch(String search) {
		searchQuery.clear();
		searchQuery.sendKeys(search);
		return this;
	}
	public SearchPage submitSearch() {
		search_button.click();
		return this;
	}
	public MediaPage selectResult(int i) {
		searchResults.get(i).click();
		return PageFactory.initElements(driver, MediaPage.class);
	}
	
	/* result checks */
	public int getNumResults() {
		return searchResults.size();
	}
	public String getResult(int i) {
		return searchResults.get(i).getText();
	}

	/* services */
	public SearchPage search(String search) {
		typeSearch(search);
		submitSearch();
		return this;
	}
}