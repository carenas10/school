package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class PlaylistsPage extends PageObject {
	public PlaylistsPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"playlists"));
	}

	//interactive elements
	private WebElement createNewPlaylist;
	private WebElement newPlaylistName;

	//results elements
	private WebElement noPlaylistsMsg;
	private WebElement playlistNameEmptyMsg;
	private WebElement playlistNameTooLongMsg;

	@FindBy(xpath = "//*[@class='playlist']")
	private List<WebElement> playlists;

	/* input actions */
	public PlaylistsPage typePlaylistName(String playlist) {
		newPlaylistName.clear();
		newPlaylistName.sendKeys(playlist);
		return this;
	}
	public PlaylistsPage submitNewPlaylist() {
		createNewPlaylist.click();
		return this;
	}
	public PlaylistsPage deletePlaylist(String playlistName) {
		WebElement deleteButton = getPlaylist(playlistName).findElement(By.name("deletePlaylist"));
		deleteButton.click();
		return this;
	}
	public PlaylistsPage removeItemFromPlaylist(String playlist, String item) {
		WebElement playlistElement = getPlaylist(playlist);
		List<WebElement> items = playlistElement.findElements(By.className("playlistItem"));
		for(int i = 0; i < items.size(); i++) {
			String itemTitle = items.get(i).findElement(By.className("playlistItemTitle")).getText();
			if(itemTitle.equals(item)) {
				items.get(i).findElement(By.name("removeMedia")).click();
				return this;
			}
		}
		//did not find item in playlists
		assert(false);
		return this;
	}

	/* result checks */
	public int getNumPlaylists() {
		return playlists.size();
	}
	public int getNumItems(String playlist) {
		List<WebElement> items = getPlaylist(playlist).findElements(By.className("playlistItem"));
		return items.size();
	}
	public boolean isPlaylistPresent(String playlist) {
		return getPlaylist(playlist) != null;
	}
	public boolean isItemPresent(String playlist, String item) {
		WebElement playlistElement = getPlaylist(playlist);
		assert(playlistElement != null);
		//look for item in playlist
		List<WebElement> items = playlistElement.findElements(By.className("playlistItem"));
		for(int i = 0; i < items.size(); i++) {
			String itemTitle = items.get(i).findElement(By.className("playlistItemTitle")).getText();
			if(itemTitle.equals(item)) {
				return true;
			}
		}
		return false;
	}

	/* message checks */
	public boolean isNoPlaylistsMsgDisplayed() {
		return noPlaylistsMsg.isDisplayed();
	}
	public boolean isPlaylistNameEmptyMsgDisplayed() {
		return playlistNameEmptyMsg.isDisplayed();
	}
	public boolean isPlaylistNameTooLongMsgDisplayed() {
		return playlistNameTooLongMsg.isDisplayed();
	}

	/* services */
	public PlaylistsPage createPlaylist(String name) {
		typePlaylistName(name);
		return submitNewPlaylist();
	}

	/* private methods */
	private WebElement getPlaylist(String playlist) {
		for(int i = 0; i < playlists.size(); i++) {
			if(getPlaylistName(i).equals(playlist)) {
				return playlists.get(i);
			}
		}
		return null;
	}
	private String getPlaylistName(int playlistIndex) {
		WebElement playlistNameElement = playlists.get(playlistIndex).findElement(By.className("playlistName"));
		return playlistNameElement.getText();
	}
}
