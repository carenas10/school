//
//  LightingViewController.m
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/18/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//
/*
 ///////////////////////////////////////
 
 use this link to find the bridge IP address
 https://www.meethue.com/api/nupnp
 
 ////////////////////////////////////////
 */

#import "LightingViewController.h"
#import "AppDelegate.h"
int numberOfLights;

@interface LightingViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *onDefault;
@property (strong, nonatomic) IBOutlet UIButton *offButton;
@property (strong, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (strong, nonatomic) IBOutlet UISlider *colorSlider;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;




@end
AppDelegate *lightsAppDelegate;
BOOL *hasShownNotification = FALSE;

NSString *ipAddress1 = @"000.000.000.000"; // this would be the ip address the bridge is on
NSString *kHueAPIUserName = @"2SDsmartHOMEcontrol"; // this is an account name to "login" to the bridge


int lightNum=0;
int currentHue = 15000;
int currentSat = 100;
int currentBrightness = 255;
/*
 These mutable arrays are holding the
 values for hue, name, brightness, status (is bulb on or off), 
 reachability (is power to bulb on or off), and text status based on
 status and reachability (status and reachability have values of 0 or 1)
 */
NSMutableArray *lightsHue;
NSMutableArray *myLights;
NSMutableArray *myLightBrightness;
NSMutableArray *myLightStatus;
NSMutableArray *myLightReachability;
NSMutableArray *lightDescription;


NSMutableArray *IP;
BOOL continueLoading = false;
// used to make sure you can control the lights on a new wireless network
// authorized user will only need to be false the first time you attempt to set the lights
// afterwards the hue bridge saves usernames until the bridge is reset
bool authorizedUser = false; 

BOOL enableButtons = false;
@implementation LightingViewController

-(void)adminCheck
{
        //check if user is an admin
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSLog(@"login info:\n");
        //NSLog([defaults objectForKey:@"username"]);
        //NSLog([defaults objectForKey:@"password"]);
    
    NSString *strURL1 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/adminLogin.php?username=%@&password=%@", [defaults objectForKey:@"username"], [defaults objectForKey:@"password"]];
    NSError *error1 = nil;
    NSString *returnString1;
    returnString1 = [[NSString alloc] init];
    returnString1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL1]  encoding:NSUTF8StringEncoding error:&error1];
    
    int isAdmin = (int)[returnString1 integerValue];
    
    if(isAdmin==1) {
        NSLog(@"isAdmin");
        lightsAppDelegate.isAdmin = true;
    } else {
        lightsAppDelegate.isAdmin = false;
        NSLog(@"isNotAdmin");
    }
        //end admin check

}



-(void)enableOrdisableButton: (BOOL) TorF
{
    
    self.onDefault.enabled = TorF;
    self.offButton.enabled = TorF;
    self.brightnessSlider.enabled=TorF;
    self.colorSlider.enabled=TorF;
    
 
}

-(void)viewDidLoad{
    [super viewDidLoad];
    lightsAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self adminCheck];
    if(lightsAppDelegate.isAdmin)
    {
        [self enableOrdisableButton:true];
    }
    else
    {
        [self enableOrdisableButton:false];
    }
    IP = [[NSMutableArray alloc]initWithObjects: nil];

 
    /*
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.meethue.com/api/nupnp"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSError         * e;
    NSData      *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&e];
    
    
    NSString *strResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     */
    NSString *strURL = [NSString stringWithFormat:@"https://www.meethue.com/api/nupnp"];
    NSError *error = nil;
    NSString *strResult;
    strResult = [[NSString alloc] init];
    strResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@", strResult);
    if([strResult isEqualToString:@"[]"])
    {
            //No bridge found on network
            // ask user to enter ip address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Bridge On Network"
                                                        message:@"Please connect to the same network the bridge is on."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        continueLoading = false;
    }
    else
    {
        continueLoading = true;
    
            // parsing
            // now we know the nupnp returns a value look for within the returned value an IP address
        
        NSString *jsonData = [NSString stringWithFormat:@"%@", strResult];
        NSRange searchRange = NSMakeRange(0,jsonData.length);
        NSRange foundRange;
        NSString *substring = @"internalipaddress";
        NSString *scanUntilThisSubstring = @"macaddress";
        NSRange secondRange;
        NSInteger lengthOfNameString;
        NSInteger startLocation;
        while (searchRange.location < jsonData.length) {
            searchRange.length = jsonData.length-searchRange.location;
            foundRange = [jsonData rangeOfString:substring options:NSCaseInsensitiveSearch range:searchRange];
                //NSLog(@"%@", [jsonData substringWithRange:foundRange]);

            if (foundRange.location != NSNotFound) {
                    // we found the first substring
                
                secondRange = [jsonData rangeOfString:scanUntilThisSubstring options:NSCaseInsensitiveSearch range:searchRange];
                    //NSLog(@"%@", [jsonData substringWithRange:secondRange]);
                if(secondRange.location !=NSNotFound)
                {
                        // we found the second substring too!
                    searchRange.location = foundRange.location+foundRange.length;
                    startLocation = searchRange.location;
                    searchRange.location = secondRange.location +secondRange.length;
                    lengthOfNameString = searchRange.location-startLocation;
                    NSString *temp = [jsonData substringWithRange:NSMakeRange(startLocation+3, lengthOfNameString-16)];
                        [IP addObject:[jsonData substringWithRange:NSMakeRange(startLocation+3, lengthOfNameString-16)]];
                    NSLog(@"THE IP ADDRESS FOUND WAS:%@", temp);
                    NSLog(@"%@", IP);
                }
                
            } else {
                    // no more substring to find
                break;
            }

    }
       
    }
    if(IP.count ==1)
    {
    ipAddress1 = [NSString stringWithFormat:@"%@", IP[0]];
            // add a bunch of code here to check if the user can access the lights through there new developer account
        [self checkIfDeveloperIsAuthorized];
        
    }
    else
    {
            //NSLog(@"%d", (int)IP.count);
            // there was not an IP address found
            // or there was more than one IP address found
            //NSLog(@"Something strange happened here");
            //NSLog(@"%@", IP);
            // go ahead and stop the app from attempting to reload everything
        continueLoading = false;
    }
    numberOfLights =0;
    
    if(continueLoading) //  if there was something returned from the nupnp
    { // and we set the IP address
        if(lightsAppDelegate.isAdmin) // and you are logged in as admin
        {
            
            [self enableOrdisableButton:true]; // enable the buttons
            enableButtons = true; // keep the buttons enabled
        }
        myLights = [[NSMutableArray alloc] initWithObjects:nil];
        myLightBrightness = [[NSMutableArray alloc]initWithObjects:nil];
        myLightStatus = [[NSMutableArray alloc] initWithObjects:nil];
        myLightReachability =[[NSMutableArray alloc] initWithObjects:nil];
        lightDescription = [[NSMutableArray alloc]initWithObjects: nil];
        
        lightsHue = [[NSMutableArray alloc]initWithObjects: nil];
      self.tableView.dataSource = self;
self.tableView.delegate = self;  
    [self updateUI];
    
    
  
    }
    if(!enableButtons) // this is needed because no bridge is found & your not logged in
    {
        [self enableOrdisableButton:false];

    }
}



     
         
//table delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return numberOfLights;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"lightBulb";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *cellDescription = @"Light is off";
    NSString *isLightOn = [myLightStatus objectAtIndex:indexPath.row];
    NSString *isReachable = [myLightReachability objectAtIndex:indexPath.row];
    if([isLightOn isEqual:@"1"])
        cellDescription = @"Light is on";
    if([isReachable isEqual:@"0"])
        cellDescription = @"Light is off";
    
    lightDescription[indexPath.row] = cellDescription;
    
        //tag 100 is name label tag in UI Builder.
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    [nameLabel setText:[myLights objectAtIndex:[indexPath row]]];
    
        //tag 200 is name label tag in UI Builder.
    
    UILabel *descLabel = (UILabel *)[cell viewWithTag:200];
    [descLabel setText:[lightDescription objectAtIndex:[indexPath row]]];
    
    /*
     UILabel *descLabel = (UILabel *)[cell viewWithTag:200];
     [descLabel setText:@""];
    */
    return cell;
    
}
-(void)checkIfDeveloperIsAuthorized
{
    NSString *url = [NSString stringWithFormat:@"http://%@/api/%@", ipAddress1, kHueAPIUserName];
   
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
    NSString *jsonBody = @"";
    NSString *method = @"GET";
    NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    NSData *temp;
    temp = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *strResult = [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", mystring);
        //NSLog(@"DO WHAT: %@", strResult);
    if([strResult containsString:@"unauthorized user"])
    {
        NSLog(@"You are not a authorized user");
            // attempt to authorize user
        [self createDeveloper];
    }
    
    
}
-(void)createDeveloper
{
    bool showMessage = false;
    NSLog(@"ATTEMPTING TO CREATE DEVELOPER");
    
    NSString *url = [NSString stringWithFormat:@"http://%@/api", ipAddress1];
     NSString *jsonBody = [NSString stringWithFormat:@"{\"devicetype\":\"test user\",\"username\":\"%@\"}", kHueAPIUserName];
    NSString *method = @"POST";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
   
    NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        // NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
        [request setHTTPBody:bodyData];
    [request setHTTPMethod:method];
        // [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *temp;
    temp = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *mystring = [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", mystring);
    if([mystring containsString:@"link button not pressed"])
    {
            // you have 30 seconds to press the button to connect the lights
        NSLog(@"Press the link button now");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Press the link button"
                                                        message:@"Click the button below once you have clicked the link button on the bridge. (30 seconds)"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.connectButton.hidden = false;
        showMessage = true;
    }
    else if([mystring containsString:@"success"])
    {
            // you pressed the link button
        NSLog(@"You have clicked the link button");
        NSLog(@"%@", mystring);
        if(showMessage)
        {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Button Pressed"
                                                        message:@"You will now be able to control the lights in the house."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        }
        self.connectButton.hidden = true;
        [self updateUI];
    }
    else
    {
        NSLog(@"%@", mystring);
        NSLog(@"Dont know what happened here");
    }
    
}
- (IBAction)linkButton:(id)sender {
    [self createDeveloper];
}
/*
 www.meethue.com/en-US/api/gettoken?devicename=iPhone+5&appid=hueapp&deviceid=001788fffe10d24b

 enlBditMMDI3QW1POFFiUXg1bW5xZ0pOeFNYV0tmUmg3TVhTWnovd2E0WT0%3D
 
 
 */

-(void)updateUI
{
    /*
     
     myLights = [[NSMutableArray alloc] initWithObjects:nil];
     myLightBrightness = [[NSMutableArray alloc]initWithObjects:nil];
     myLightStatus = [[NSMutableArray alloc] initWithObjects:nil];
     myLightReachability =[[NSMutableArray alloc] initWithObjects:nil];
     lightDescription = [[NSMutableArray alloc]initWithObjects: nil];
     */
    [lightDescription removeAllObjects];
    [myLights removeAllObjects];
    [myLightBrightness removeAllObjects];
    [myLightStatus removeAllObjects];
    [myLightReachability removeAllObjects];
    numberOfLights =0;
         for(int i=0; i <numberOfLights;i++)
    {
        
        [lightDescription addObject:@"Light Off"];
    }
    NSString* lightList = [NSString stringWithFormat:@"http://%@/api/%@/lights", ipAddress1, kHueAPIUserName];
    [self getLight:[NSURL URLWithString:lightList] second:@"GET"];
   
         [self.tableView reloadData];

    
}
-(void)getLight:(NSURL*) url second:(NSString*) method
{
    [lightsHue removeAllObjects];
    [myLights removeAllObjects];
    [myLightBrightness removeAllObjects];
    [myLightStatus removeAllObjects];
    [myLightReachability removeAllObjects];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
        // get the current brightess of each bulb and store them in an array
    [self getLightBrightness:url second:method];
        // get the current state of each bulb (is light switch on and is bulb on) and store in array
    [self getLightStates:url second:method];
        // get the current Hue of each bulb and store them in an array
    [self getLightHue:url second:method];

    [request setHTTPMethod:method];
    
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSArray *response=[NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableContainers error:&error];

    NSString *jsonData = [NSString stringWithFormat:@"%@", response];
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @"name = ";
    NSString *scanUntilThisSubstring = @"pointsymbol =";
    NSRange secondRange;
    NSInteger lengthOfNameString;
    NSInteger startLocation;
    while (searchRange.location < jsonData.length) {
        searchRange.length = jsonData.length-searchRange.location;
        foundRange = [jsonData rangeOfString:substring options:NSCaseInsensitiveSearch range:searchRange];
        
        if (foundRange.location != NSNotFound) {
                // we found the first substring
            numberOfLights = numberOfLights +1;
            secondRange = [jsonData rangeOfString:scanUntilThisSubstring options:NSCaseInsensitiveSearch range:searchRange];
            if(secondRange.location !=NSNotFound)
            {
                    // we found the second substring too!
                searchRange.location = foundRange.location+foundRange.length;
                startLocation = searchRange.location;
                searchRange.location = secondRange.location +secondRange.length;
                lengthOfNameString = searchRange.location-startLocation;
                NSString *lightBulbRawDataName = [jsonData substringWithRange:NSMakeRange(startLocation, lengthOfNameString-19)];
                NSString *LightBulb = [lightBulbRawDataName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                LightBulb = [LightBulb stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                LightBulb = [LightBulb stringByReplacingOccurrencesOfString:@";" withString:@""];
                
                [myLights addObject:LightBulb];
            
            }
            
        } else {
                // no more substring to find
            break;
        }
        
        
    }
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}
 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lightNum = (int)indexPath.row+1;
    self.brightnessSlider.value = [myLightBrightness[lightNum-1] floatValue];
    self.colorSlider.value = (int)[lightsHue[indexPath.row] floatValue];
    
}

-(void) getLightStates:(NSURL *) url second:(NSString *)method
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:method];
    
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=[NSError new];
    NSArray *response=[NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableContainers error:&error];

    NSString *jsonData = [NSString stringWithFormat:@"%@", response];
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @" on =";
    NSString *scanUntilThisSubstring = @"reachable =";
    NSRange secondRange;
    NSInteger lengthOfNameString;
    NSInteger startLocation;
    while (searchRange.location < jsonData.length) {
        searchRange.length = jsonData.length-searchRange.location;
        foundRange = [jsonData rangeOfString:substring options:NSLiteralSearch range:searchRange];
        
        if (foundRange.location != NSNotFound) {
                // we found the first substring
            secondRange = [jsonData rangeOfString:scanUntilThisSubstring options:NSLiteralSearch range:searchRange];
            if(secondRange.location !=NSNotFound)
            {
                
                    // we found the second substring too!
                searchRange.location = foundRange.location+foundRange.length;
                startLocation = searchRange.location;
                searchRange.location = secondRange.location +secondRange.length;
                lengthOfNameString = searchRange.location-startLocation;
                NSString *status = [NSString stringWithFormat:@"%@", [jsonData substringWithRange:NSMakeRange(startLocation, lengthOfNameString-scanUntilThisSubstring.length)]];
                int temp = (int)status.length;
                status = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                status= [status substringToIndex:status.length-1];
                NSString *reachability = [NSString stringWithFormat:@"%@", [jsonData substringWithRange:NSMakeRange(startLocation+temp+scanUntilThisSubstring.length+1, 1)]];
                    //[lightsHue addObject:[jsonData substringWithRange:NSMakeRange(startLocation+1,5)]];
                    [myLightStatus addObject:status];
                    [myLightReachability addObject:reachability];
                    // NSLog(@"%@", status);
                    // NSLog(@"%@", reachability);
            }
            
        } else {
                // no more substring to find
            break;
        }
        
        
    }
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}
-(void) getLightHue:(NSURL *) url second:(NSString *)method
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:method];
    
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=[NSError new];
    NSArray *response=[NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableContainers error:&error];
    
    NSString *jsonData = [NSString stringWithFormat:@"%@", response];
        //NSLog(@"%@", jsonData);
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @"hue =";
    NSString *scanUntilThisSubstring = @" on =";
        //NSLog(@"%@", scanUntilThisSubstring);
    NSRange secondRange;
    NSInteger lengthOfNameString;
    NSInteger startLocation;
    while (searchRange.location < jsonData.length) {
        searchRange.length = jsonData.length-searchRange.location;
        foundRange = [jsonData rangeOfString:substring options:NSLiteralSearch range:searchRange];
        
        if (foundRange.location != NSNotFound) {
                // we found the first substring
            secondRange = [jsonData rangeOfString:scanUntilThisSubstring options:NSLiteralSearch range:searchRange];
            if(secondRange.location !=NSNotFound)
            {
                
                    // we found the second substring too!
                searchRange.location = foundRange.location+foundRange.length;
                startLocation = searchRange.location;
                searchRange.location = secondRange.location +secondRange.length;
                lengthOfNameString = searchRange.location-startLocation;
                NSString *hue = [NSString stringWithFormat:@"%@",[jsonData substringWithRange:NSMakeRange(startLocation+1,lengthOfNameString-scanUntilThisSubstring.length)] ];
                hue = [hue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                hue = [hue substringToIndex:hue.length-1];
                [lightsHue addObject:hue];
                    // NSLog(@"%@", hue);
            }
            
        } else {
                // no more substring to find
            break;
        }
        
        
    }
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}
-(void) getLightBrightness:(NSURL *) url second:(NSString *)method
{
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:method];
    
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSArray *response=[NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableContainers error:&error];

    NSString *jsonData = [NSString stringWithFormat:@"%@", response];
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @"bri =";
    NSString *scanUntilThisSubstring = @"colormode =";
    NSRange secondRange;
    NSInteger lengthOfNameString;
    NSInteger startLocation;
    while (searchRange.location < jsonData.length) {
        searchRange.length = jsonData.length-searchRange.location;
        foundRange = [jsonData rangeOfString:substring options:NSCaseInsensitiveSearch range:searchRange];
        
        if (foundRange.location != NSNotFound) {
                // we found the first substring
            secondRange = [jsonData rangeOfString:scanUntilThisSubstring options:NSCaseInsensitiveSearch range:searchRange];
            if(secondRange.location !=NSNotFound)
            {
                
                    // we found the second substring too!
                searchRange.location = foundRange.location+foundRange.length;
                startLocation = searchRange.location;
                searchRange.location = secondRange.location +secondRange.length;
                lengthOfNameString = searchRange.location-startLocation;
                [myLightBrightness addObject:[jsonData substringWithRange:NSMakeRange(startLocation+1, lengthOfNameString-26)]];
            }
            
        } else {
                // no more substring to find
            break;
        }
        
        
    }
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
}
 
- (IBAction)turnOnLight:(id)sender {
    
    NSString* onCommand = @"{\"on\":true,\"bri\":255,\"sat\":100,\"transitiontime\":10,\"effect\":\"none\",\"hue\":15000}";
    NSString* lightStateURL = [NSString stringWithFormat:@"http://%@/api/%@/lights/%d/state", ipAddress1, kHueAPIUserName, lightNum];
    updateLight([NSURL URLWithString:lightStateURL], @"PUT", onCommand);
    currentHue = 15000;
    currentSat =100;
        [self updateUI];
    self.brightnessSlider.value = 255;

}

- (IBAction)turnOffLight:(id)sender {
    
    
    NSString* onCommand = [NSString stringWithFormat:@"{\"on\":false,\"bri\":%d,\"sat\":%d,\"transitiontime\":10,\"effect\":\"none\",\"hue\":%d}", (int)[myLightBrightness[lightNum-1] integerValue], currentSat, currentHue];
    NSString* lightStateURL = [NSString stringWithFormat:@"http://%@/api/%@/lights/%d/state", ipAddress1, kHueAPIUserName, lightNum];
    updateLight([NSURL URLWithString:lightStateURL], @"PUT", onCommand);
    currentHue = 15000;
    currentSat =100;
        [self updateUI];
}




void updateLight(NSURL* url, NSString* method, NSString* jsonBody)
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    NSData* bodyData = [jsonBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]];
    
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}
    /*
     brightnessSlider
     
     This code accesses the phillips hue web based api and updates the brightness 
     
     Preserves: current saturation and color
     
     */
- (IBAction)brightnessSlider:(id)sender {
    
    NSString* onCommand = [NSString stringWithFormat:@"{\"on\":true,\"bri\":%d,\"sat\":%d,\"transitiontime\":1,\"effect\":\"none\",\"hue\":%d}", (int)self.brightnessSlider.value, currentSat, currentHue];
    NSString* lightStateURL = [NSString stringWithFormat:@"http://%@/api/%@/lights/%d/state", ipAddress1, kHueAPIUserName, lightNum];
    updateLight([NSURL URLWithString:lightStateURL], @"PUT", onCommand);
    currentBrightness = (int)self.brightnessSlider.value;

}
/*
 colorSlider
 
 This code accesses the phillips hue web based api and updates the color
 
 Preserves: current saturation and brightness
 
 */
- (IBAction)colorSlider:(id)sender {
    
    currentSat = 255;
    NSString* onCommand = [NSString stringWithFormat:@"{\"on\":true,\"bri\":%d,\"sat\":%d,\"transitiontime\":1,\"effect\":\"none\",\"hue\":%d}", currentBrightness, currentSat, (int)self.colorSlider.value];
    NSString* lightStateURL = [NSString stringWithFormat:@"http://%@/api/%@/lights/%d/state", ipAddress1, kHueAPIUserName, lightNum];
    updateLight([NSURL URLWithString:lightStateURL], @"PUT", onCommand);
    currentHue = (int)self.colorSlider.value;
    
    
}
@end