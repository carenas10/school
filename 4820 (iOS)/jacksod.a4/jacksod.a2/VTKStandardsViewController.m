//
//  VTKStandardsViewController.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/22/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKStandardsViewController.h"
#import "VTKCodecDetailViewController.h"

@interface VTKStandardsViewController ()
@property (strong,nonatomic) VidSetting *settingInFocus;
@end

@implementation VTKStandardsViewController

@synthesize settingsTable;
@synthesize settings;
@synthesize refreshController;
@synthesize settingInFocus;


- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [super viewDidLoad];
    settings = [Database database].getSettings;
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self
                          action:@selector(refresh)
                forControlEvents:UIControlEventValueChanged];
    [settingsTable addSubview:refreshController];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailCodecView"]){
        VTKCodecDetailViewController *destination = [segue destinationViewController];
        destination.detailSetting =settingInFocus;
    }
}

//The actual action that takes place when we pull and then release.
-(void)refresh{
    settings = [Database database].getSettings;
    [settingsTable reloadData];
    [refreshController endRefreshing];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settings count];
}


//sets display properties for each row
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = ((VidSetting *)[settings objectAtIndex:indexPath.row]).name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    settingInFocus = [settings objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"detailCodecView" sender:self];
    
}

-(void) download {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //BOOL syncEnabled = [defaults boolForKey:@"sync"];
    NSString *username = [defaults stringForKey:@"username"];
    NSString *password = [defaults stringForKey:@"password"];
    NSError *error = nil;
    
    NSMutableString *getSettingsString = [NSMutableString stringWithString:@"http://people.cs.clemson.edu/~jacksod/get_settings.php"];
    
    //IF SYNC ENABLED
    NSLog(@"Username: %@ Password: %@",username,password);
    [getSettingsString appendString:@"?username="];
    [getSettingsString appendString:username];
    [getSettingsString appendString:@"&password="];
    [getSettingsString appendString:password];
    
    NSURL *getSettingsURL = [NSURL URLWithString:getSettingsString];
    //Retrieve settings data from server.
    NSData *getSettingsData = [NSData dataWithContentsOfURL:getSettingsURL
                                                  options:NSDataReadingUncached
                                                    error:&error];
    
    if(error){
        UIAlertView *syncSettingsError = [[UIAlertView alloc] initWithTitle:@"Oops...(2)"
                                                                  message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [syncSettingsError show];
        NSLog(@"Error downloading Settings: %@", [error localizedDescription]);
        return;
    }
    
    error = nil;

    //Parse JSON for settings
    NSDictionary* settingsJSON = [NSJSONSerialization JSONObjectWithData: getSettingsData
                                                               options:kNilOptions
                                                                 error:&error];
    if(error){
        UIAlertView *syncSettingsError = [[UIAlertView alloc] initWithTitle:@"Oops..."
                                                                    message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [syncSettingsError show];
        NSLog(@"Error downloading Settings: %@", [error localizedDescription]);
        return;
    }
    
    error = nil;
    
    NSLog(@"Settings Dictionary: %@",settingsJSON);
    
    bool settingsSuccess = [[settingsJSON valueForKey:@"sucess"] boolValue];
    NSLog(@"Settings sync succesful? %@", settingsSuccess ? @"YES" : @"NO");
    
    if (settingsSuccess) {
        NSArray *settingsResults = [settingsJSON objectForKey:@"results"];
        for (NSDictionary *setting in settingsResults){
            int setting_ID = [[setting valueForKey:@"setting_ID"]intValue];
            NSString *name = [setting valueForKey:@"name"];
            NSString *resolution = [setting valueForKey:@"setting"];
            int bitrate = [[setting valueForKey:@"bitrate"] intValue];
            int framerate = [[setting valueForKey:@"framerate"]intValue];
            int vidCodec = [[setting valueForKey:@"vidCodec"]intValue];
            int audioCodec = [[setting valueForKey:@"audioCodec"]intValue];
            int s_GID = [[setting valueForKey:@"GID"] intValue];
            BOOL is_deleted = [[setting valueForKey:@"is_deleted"] boolValue];
            
            int local_id = [[Database database] getSettingIDfromGID:s_GID]; //checks to see if setting is in local DB
            
            //if not in local DB, add new setting with a tempo
            if(local_id == -1){
                VidSetting *tmpSetting = [[VidSetting alloc] initWithID:-1 name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:s_GID is_deleted:is_deleted];
                [[Database database] addSetting:tmpSetting];
            } else {
                [[Database database] updateSetting:local_id name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:s_GID is_deleted:is_deleted];
            }
            
        }

        UIAlertView *donePopup = [[UIAlertView alloc] initWithTitle:@"Finished With Sync"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [donePopup show];
        [settingsTable reloadData];
    } else{
        NSMutableString *reasonString = [[NSMutableString alloc] initWithString:@""];
        if(!settingsJSON){
            [reasonString appendString:@"settings: "];
            [reasonString appendString:[settingsJSON objectForKey:@"reason"]];
            [reasonString appendString:@"\n"];
        }
        UIAlertView *badDataAlert = [[UIAlertView alloc] initWithTitle:@"Error in Data:"
                                                               message:reasonString
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [badDataAlert show];
    }//else
    //END IF SYNC ENABLED
} //download

- (IBAction)syncPressed:(id)sender {
    
    NSArray *unsyncedSettings = [[Database database] getUnsyncedSettings];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    BOOL syncEnabled = [defaults boolForKey:@"sync"];
    NSString *username = [defaults stringForKey:@"username"];
    
    NSString *password = [defaults stringForKey:@"password"];
    NSError *error = nil;
    
    NSMutableString *syncSetting = [NSMutableString stringWithString:@"http://people.cs.clemson.edu/~jacksod/put_settings.php"];

    for (VidSetting *setting in unsyncedSettings){

            [syncSetting appendString:@"?username="];
            [syncSetting appendString:username];
            [syncSetting appendString:@"&password="];
            [syncSetting appendString:password];
            
            [syncSetting appendString:@"&name="];
            [syncSetting appendString:setting.name];
            
            [syncSetting appendString:@"&resolution="];
            [syncSetting appendString:setting.resolution];
            
            [syncSetting appendString:@"&bitrate="];
            [syncSetting appendString:[NSString stringWithFormat:@"%d", setting.bitrate]];
        
            [syncSetting appendString:@"&framerate="];
            [syncSetting appendString:[NSString stringWithFormat:@"%d", setting.framerate]];
        
            [syncSetting appendString:@"&vidCodec="];
        //NSLog([NSString stringWithFormat:@"%d", setting.vidCodec ]);
            [syncSetting appendString:[NSString stringWithFormat:@"%d", setting.vidCodec+1]];
        
            [syncSetting appendString:@"&audioCodec="];
            [syncSetting appendString:[NSString stringWithFormat:@"%d", setting.audioCodec+1]];
        
            [syncSetting appendString:@"&is_deleted="];
            [syncSetting appendString:setting.is_deleted ? @"TRUE" : @"FALSE"];
            
            NSString *removedSpaces = [syncSetting stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSURL *syncSettingURL = [NSURL URLWithString:removedSpaces];
            NSData *syncSettingData = [NSData dataWithContentsOfURL:syncSettingURL
                                                         options:NSDataReadingUncached
                                                           error:&error];
            
            if(error){
                UIAlertView *syncErrorRoute = [[UIAlertView alloc] initWithTitle:@"Oops..."
                                                                         message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                [syncErrorRoute show];
                NSLog(@"Error downloading Routes: %@", [error localizedDescription]);
                return;
            }
            
            error = nil;
            NSDictionary* settingJSON = [NSJSONSerialization JSONObjectWithData: syncSettingData
                                                                      options:kNilOptions
                                                                        error:&error];
            if(error){
                UIAlertView *syncErrorRoute = [[UIAlertView alloc] initWithTitle:@"Oops...(1)"
                                                                         message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                [syncErrorRoute show];
                NSLog(@"Error parsing Routes: %@", [error localizedDescription]);
                return;
            }
            bool success = [[settingJSON valueForKey:@"sucess"] boolValue];
            int GID = [[settingJSON valueForKey:@"GID"] intValue];
            
            if (success) {
                [[Database database] setSettingGID:setting
                                             GID:GID];
                NSLog(@"GID: %d",GID);
            } else NSLog(@"Error putting unsynced:%@",[settingJSON valueForKey:@"reason"]);
    }

    NSArray *deletedSettings = [[Database database] getDeletedSettings];
    for(VidSetting *setting in deletedSettings){
        NSMutableString *deletedURLString = [NSMutableString stringWithString:@"http://people.cs.clemson.edu/~jacksod/delete_route.php"];
        [deletedURLString appendString:@"?username="];
        [deletedURLString appendString:username];
        [deletedURLString appendString:@"&password="];
        [deletedURLString appendString:password];
        [deletedURLString appendString:@"&GID="];
        [deletedURLString appendString:[NSString stringWithFormat:@"%d", setting.GID]];
        
        NSString *removedSpacesFromDeleteURL = [deletedURLString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSURL *deleteSettingURL = [NSURL URLWithString:removedSpacesFromDeleteURL];
        NSData *deleteSettingData = [NSData dataWithContentsOfURL:deleteSettingURL
                                                        options:NSDataReadingUncached
                                                          error:&error];
        
        if(error){
            UIAlertView *deleteSettingError = [[UIAlertView alloc] initWithTitle:@"Oops...(3)"
                                                                       message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
            [deleteSettingError show];
            NSLog(@"Error deleting Setting: %@", [error localizedDescription]);
            return;
        }
        
        error = nil;
        NSDictionary* settingJSON = [NSJSONSerialization JSONObjectWithData: deleteSettingData
                                                                  options:kNilOptions
                                                                    error:&error];
        if(error){
            UIAlertView *syncErrorSetting = [[UIAlertView alloc] initWithTitle:@"Oops..."
                                                                     message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [syncErrorSetting show];
            NSLog(@"Error parsing deleted Setting: %@", [error localizedDescription]);
            return;
        }
        bool success = [[settingJSON valueForKey:@"sucess"] boolValue];
        if(!success){
            UIAlertView *syncErrorSetting = [[UIAlertView alloc] initWithTitle:@"Oops..."
                                                                     message:@"There was an error downloading data. Please check your internet connection and try again later."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [syncErrorSetting show];
            NSLog(@"Error deleting Setting on server: %@", [settingJSON valueForKey:@"reason"]);
            return;
        }
    }
    
    [self download];
}








@end
