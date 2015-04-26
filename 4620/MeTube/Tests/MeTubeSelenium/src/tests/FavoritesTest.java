package tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.FavoritesPage;
import pages.MediaPage;
import pages.SearchPage;

public class FavoritesTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test account
		Helper.createAccountAndLogin(Helper.account(1), driver);

		//upload test document
		Helper.upload(Helper.doc(1), driver);
	}

	private MediaPage getMediaPage() {
		driver.get(Helper.baseURL()+"search");
		SearchPage searchPage = PageFactory.initElements(driver, SearchPage.class);
		searchPage.search(Helper.doc(1).getTitle());
		assertTrue(searchPage.getNumResults() == 1);
		return searchPage.selectResult(0);
	}

	@Test
	public void testPlaylists() {
		//ensure "no favorites" message appears
		driver.get(Helper.baseURL()+"favorites");
		FavoritesPage page = PageFactory.initElements(driver, FavoritesPage.class);
		assertTrue(page.isNoFavoritesMsgDisplayed());

		//add media to favorite
		MediaPage mediaPage = getMediaPage();
		assertTrue(mediaPage.isFavoriteButtonDisplayed());
		mediaPage.favorite();

		//go back to favorites and check that media showed up
		driver.get(Helper.baseURL()+"favorites");
		page = PageFactory.initElements(driver, FavoritesPage.class);
		assertEquals(1, page.getNumFavorites());
		assertTrue(page.isItemPresent(Helper.doc(1).getTitle()));

		//remove media from favorites
		page.removeFavorite(Helper.doc(1).getTitle());

		assertEquals(0, page.getNumFavorites());
		assertTrue(page.isNoFavoritesMsgDisplayed());

		//add and remove favorite from media page
		mediaPage = getMediaPage();
		assertTrue(mediaPage.isFavoriteButtonDisplayed());
		mediaPage.favorite();
		assertTrue(mediaPage.isUnfavoriteButtonDisplayed());
		mediaPage.unfavorite();


		//go back to favorites and check that media does not show up
		driver.get(Helper.baseURL()+"favorites");
		page = PageFactory.initElements(driver, FavoritesPage.class);
		
		assertEquals(0, page.getNumFavorites());
		assertTrue(page.isNoFavoritesMsgDisplayed());
	}

	@AfterClass
	public static void cleanup() {
		Helper.deleteAccount(driver);

		//close browser
		driver.quit();
	}
}