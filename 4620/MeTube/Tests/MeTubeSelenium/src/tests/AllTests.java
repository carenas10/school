package tests;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ CommentTest.class, EditAccountTest.class, FavoritesTest.class,
		GuestRedirectTest.class, InboxTest.class, LoginTest.class,
		NewMessageTest.class, PlaylistsTest.class, RegisterTest.class,
		SearchTest.class, SubscriptionsTest.class, ThreadTest.class,
		UploadTest.class })
public class AllTests {

}