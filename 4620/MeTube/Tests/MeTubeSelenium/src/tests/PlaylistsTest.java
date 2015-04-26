package tests;

import static org.junit.Assert.*;
import help.Helper;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.PageFactory;

import pages.MediaPage;
import pages.PlaylistsPage;
import pages.SearchPage;

public class PlaylistsTest {
	private static WebDriver driver;

	@BeforeClass
	public static void setup() {
		driver = new FirefoxDriver();

		//create test accounts
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
		//ensure "no playlists" message appears
		driver.get(Helper.baseURL()+"playlists");
		PlaylistsPage page = PageFactory.initElements(driver, PlaylistsPage.class);
		assertTrue(page.isNoPlaylistsMsgDisplayed());

		//test empty name playlist
		page.createPlaylist("   ");
		assertTrue(page.isPlaylistNameEmptyMsgDisplayed());

		//test too-long name playlist
		page.createPlaylist(Helper.getStringOfLength(36));
		assertTrue(page.isPlaylistNameTooLongMsgDisplayed());

		//create actual playlists
		page.createPlaylist("Playlist 1");
		page.createPlaylist("Playlist 2");

		//add media to playlists
		MediaPage mediaPage = getMediaPage();
		mediaPage.addToPlaylist("Playlist 1");
		mediaPage.addToPlaylist("Playlist 2");

		//add media to already playlist it is a member of
		mediaPage.addToPlaylist(0);
		assertTrue(mediaPage.isMediaAlreadyInPlaylistMsgDisplayed());

		//go back to playlists and check that media showed up
		driver.get(Helper.baseURL()+"playlists");
		page = PageFactory.initElements(driver, PlaylistsPage.class);
		assertEquals(2, page.getNumPlaylists());
		assertTrue(page.isPlaylistPresent("Playlist 1"));
		assertTrue(page.isPlaylistPresent("Playlist 2"));
		assertEquals(1, page.getNumItems("Playlist 1"));
		assertEquals(1, page.getNumItems("Playlist 2"));
		assertTrue(page.isItemPresent("Playlist 1", Helper.doc(1).getTitle()));
		assertTrue(page.isItemPresent("Playlist 2", Helper.doc(1).getTitle()));

		//remove media
		page.removeItemFromPlaylist("Playlist 1", Helper.doc(1).getTitle());

		assertEquals(2, page.getNumPlaylists());
		assertTrue(page.isPlaylistPresent("Playlist 1"));
		assertTrue(page.isPlaylistPresent("Playlist 2"));
		assertEquals(0, page.getNumItems("Playlist 1"));
		assertEquals(1, page.getNumItems("Playlist 2"));
		assertFalse(page.isItemPresent("Playlist 1", Helper.doc(1).getTitle()));
		assertTrue(page.isItemPresent("Playlist 2", Helper.doc(1).getTitle()));

		//delete playlists
		page.deletePlaylist("Playlist 1");
		page.deletePlaylist("Playlist 2");

		assertTrue(page.isNoPlaylistsMsgDisplayed());
	}

	@AfterClass
	public static void cleanup() {
		Helper.deleteAccount(driver);

		//close browser
		driver.quit();
	}
}