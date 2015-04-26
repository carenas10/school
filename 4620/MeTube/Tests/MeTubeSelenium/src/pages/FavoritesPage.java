package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class FavoritesPage extends PageObject {
	public FavoritesPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"favorites"));
	}
	//results elements
	private WebElement noFavoritesMsg;

	@FindBy(xpath = "//*[@class='favoritesBlock']")
	private List<WebElement> favorites;

	/* result checks */
	public int getNumFavorites() {
		return favorites.size();
	}
	public boolean isItemPresent(String itemTitle) {
		return getRemoveButtonForItem(itemTitle) != null;
	}

	/* message checks */
	public boolean isNoFavoritesMsgDisplayed() {
		return noFavoritesMsg.isDisplayed();
	}

	/* services */
	public FavoritesPage removeFavorite(String itemTitle) {
		getRemoveButtonForItem(itemTitle).click();
		return this;
	}

	/* private methods */
	private WebElement getRemoveButtonForItem(String itemTitle) {
		for(int i = 0; i < favorites.size(); i++) {
			WebElement title = favorites.get(i).findElement(By.className("favoriteItemTitle"));
			if(title.getText().equals(itemTitle)) {
				WebElement removeButton = favorites.get(i).findElement(By.name("unfavorite"));
				return removeButton;
			}
		}
		return null;
	}
}
