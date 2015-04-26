package pages;

import static org.junit.Assert.assertTrue;
import help.Helper;

import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.Select;

public class MediaPage extends PageObject {
	public MediaPage(WebDriver driver) {
		super(driver);
		assertTrue(driver.getCurrentUrl().startsWith(Helper.baseURL()+"media"));
	}
	
	//interactive elements
	private WebElement submitNewComment;
	private WebElement newCommentContent;
	private WebElement addToPlaylist;
	private WebElement playlistID;
	private WebElement favorite; //favorite button
	private WebElement unfavorite; //unfavorite button
	
	//display elements
	private WebElement mediaTitle;
	@FindBy(className = "commentContent")
	List<WebElement> comments;
	@FindBy(className = "commenterUsername")
	List<WebElement> commentUsernames;
	
	//message elements
	private WebElement commentEmptyMsg;
	private WebElement commentTooLongMsg;
	private WebElement mediaAlreadyInPlaylistMsg;
	
	/* input actions */
	public MediaPage typeComment(String comment) {
		newCommentContent.clear();
		newCommentContent.sendKeys(comment);
		return this;
	}
	public MediaPage submitComment() {
		submitNewComment.click();
		return this;
	}

	public int getNumComments() {
		assert(comments.size()==commentUsernames.size());
		return comments.size();
	}
	public String getComment(int i) {
		return comments.get(i).getText();
	}
	public String getCommentUsername(int i) {
		return commentUsernames.get(i).getText();
	}
	
	/* result checks */
	public String getMediaTitle() {
		return mediaTitle.getText();
	}
	public boolean isCommentEmptyMsgDisplayed() {
		return commentEmptyMsg.isDisplayed();
	}
	public boolean isCommentTooLongMsgDisplayed() {
		return commentTooLongMsg.isDisplayed();
	}
	public boolean isMediaAlreadyInPlaylistMsgDisplayed() {
		return mediaAlreadyInPlaylistMsg.isDisplayed();
	}
	public boolean isFavoriteButtonDisplayed() {
		return favorite.isDisplayed();
	}
	public boolean isUnfavoriteButtonDisplayed() {
		return unfavorite.isDisplayed();
	}

	/* services */
	public MediaPage comment(String comment) {
		typeComment(comment);
		return submitComment();
	}
	public MediaPage addToPlaylist(String playlistName) {
		Select dropdown = new Select(playlistID);
		dropdown.selectByVisibleText(playlistName);
		addToPlaylist.click();
		return this;
	}
	public MediaPage addToPlaylist(int index) {
		Select dropdown = new Select(playlistID);
		dropdown.selectByIndex(index);
		addToPlaylist.click();
		return this;
	}
	public MediaPage favorite() {
		favorite.click();
		return this;
	}
	public MediaPage unfavorite() {
		unfavorite.click();
		return this;
	}
}