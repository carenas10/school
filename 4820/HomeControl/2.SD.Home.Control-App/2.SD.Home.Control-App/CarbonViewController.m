//
//  CarbonViewController.m
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 12/5/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import "CarbonViewController.h"

@interface CarbonViewController()

@property (weak, nonatomic) IBOutlet JBLineChartView *lineChartView;
@property (nonatomic, strong) NSMutableArray *chartData;
@property (nonatomic, strong) NSMutableArray *fullChartData;
@property (strong, nonatomic) IBOutlet UIButton *dayButton;
@property (strong, nonatomic) IBOutlet UIButton *weekButton;
@property (weak, nonatomic) IBOutlet UILabel *currentChartValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentCarbonLabel;

@end

@implementation CarbonViewController

AppDelegate *carbonAppDelegate;
float setcarbon2=0;
NSMutableArray *carbonData;
int numberOfViews_C=20;

NSString *latestDay;
NSMutableArray *lastWeek; // the last 7 days
NSMutableArray *sevenData; // the temp data for the week
NSMutableArray *lastMonth; // the last 7 months ( that the last 7 days occured in

NSMutableArray *hourData; // the hours of the day that have data
int whichTypeofChart; // 0 for hourly // 1 for daily // 2 for monthly
NSMutableArray *aSingleHourArray;
NSMutableArray *averageOfHoursInDay;

-(void)adminCheck {
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
        carbonAppDelegate.isAdmin = true;
    } else {
        carbonAppDelegate.isAdmin = false;
        NSLog(@"isNotAdmin");
    }
    //end admin check
}


-(void)updateUI
{
        //Get current humidity from DB
    NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastCO2.php"];
    NSError *error = nil;
    NSString *strResult;
    strResult = [[NSString alloc] init];
    strResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
    
        //set current humidity
    carbonAppDelegate.currentCO2 = [strResult floatValue];
    self.currentLabel.text = [NSString stringWithFormat:@"%d", (int)[strResult integerValue]];
    
        //Get ideal humidity from DB
    NSString *strURL2 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealCO2.php"];
    NSError *error2= nil;
    NSString *strResult2;
    strResult2 = [[NSString alloc] init];
    strResult2 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL2]  encoding:NSUTF8StringEncoding error:&error2];
    
        //Set ideal label
    carbonAppDelegate.setCO2 = [strResult2 floatValue];
    self.idealLabel.text = [NSString stringWithFormat:@"Set: %d", (int)[strResult2 integerValue]];
    setcarbon2 = [strResult2 floatValue];
    [self setColorOfCurrentcarbon];
    
    //if user not admin, disable buttons
    if(carbonAppDelegate.isAdmin) {
        self.setButton.enabled = true;
    } else {
        self.setButton.enabled = false;
    }

        // get all of the carbon data in the database store them into a mutable array called humidityData
    NSString *strURL1 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getAllCO2.php"];
    NSError *error1 = nil;
    NSString *strResult3;
    strResult3 = [[NSString alloc] init];
    strResult3 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL1]  encoding:NSUTF8StringEncoding error:&error1];
    
    NSString *jsonData = [NSString stringWithFormat:@"%@", strResult3];
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @"carbonDioxideLevel=";
    NSString *scanUntilThisSubstring = @"<br>";
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
                    //NSLog(@"%@",[jsonData substringWithRange:NSMakeRange(startLocation, lengthOfNameString)]);
                [carbonData addObject:[jsonData substringWithRange:NSMakeRange(startLocation, lengthOfNameString)]];
            }
        } else {
                // no more substring to find
            break;
        }
    }//while
} //UpdateUI

- (void) viewDidLoad {
    [super viewDidLoad];
} // viewDidLoad

// -----------------SETTING NEW VALUE METHODS----------------------
//opens a dialog where user can set new optimal energy
-(IBAction)setCarbonWithButton:(id)sender {
    
    //open dialog
    UIAlertView * setAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter new Ideal CO2 Content:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    setAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *alertTextField = [setAlert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [setAlert setDelegate:self];
    [setAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //user presses OK.
    if (buttonIndex == 1) {
        UITextField *textfield = [alertView textFieldAtIndex:0];
        NSString *input = textfield.text;
        NSLog(@"text: %@", textfield.text);
        
        if ([self isPositiveNumber:input] && input.length <= 5) {
            setcarbon2 = [input floatValue];
            [self.idealLabel setText:[NSString stringWithFormat:@"Ideal: %.1f",setcarbon2]];
            [self doSync];
        } else {
            //NSLog(@"INVALID INPUT TO TEXT FIELD");
            UIAlertView * invalidAlert =[[UIAlertView alloc ] initWithTitle:@"Invalid Entry"
                                                                    message:@"Entries must be positive numbers of less than 6 digits."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles: nil];
            [invalidAlert show];
        }
    }//if
}//alertView

//a valid entry must be a positive numeric value
- (BOOL)isPositiveNumber: (NSString *)s
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:s];
    if (!!number){
        if([number intValue]>=0)
            return YES;
    }
    //return !!number; // If the string is not numeric, number will be nil
    return NO;
}
// -----------------END SETTING NEW VALUE METHODS----------------------

-(void)doSync
{
    carbonAppDelegate.setCO2 = setcarbon2;
    
    NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/setwarningPPMCO2.php?setwarningPPMCO2=%d", (int)setcarbon2];
    NSError *error = nil;
    returnString3 = [[NSString alloc] init];
    returnString3 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Carbon Set"
                                                    message:[NSString stringWithFormat:@"Your Carbon goal is now %d ppm", (int)carbonAppDelegate.setCO2]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self setColorOfCurrentcarbon];
}






-(void)setColorOfCurrentcarbon
{
        //if current less than ideal, good.
    if(carbonAppDelegate.currentCO2 < carbonAppDelegate.setCO2) {
        self.currentLabel.textColor = [UIColor greenColor];
    } else {
        self.currentLabel.textColor = [UIColor redColor];
    }
}

- (void)loadView {
    [super loadView];
    carbonData =  [[NSMutableArray alloc] initWithObjects:nil];
    carbonAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self adminCheck];

    [self updateUI];
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    
        // Initialize graph features
    self.lineChartView.frame = CGRectMake(20.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - (115.0f * 2));
    self.lineChartView.backgroundColor = [UIColor colorWithRed:0.149 green:0.149 blue:0.149 alpha:1];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
        // Create hour by hour chart data
    [self setDailyChart];
    
} // loadView



    ////////////////////////////////////
    // Use this space between JB charts to set up the daily and weekly charts
    // Note the changes above


    // Two buttons created a DayButton and weekButton
    // Connect them to the buttons and create properties above to enable/disable them progromatically


/*
 NSMutableArray *hourData; // the hours of the day that have data
 int whichTypeofChart; // 0 for hourly // 1 for daily // 2 for monthly
 NSMutableArray *aSingleHourArray;
 NSMutableArray *averageOfHoursInDay;
 */


    // In the function -(void)loadView()
    // After the comment // Create 20 humidity chart values
    //Replace all until end of funtion with
/*
 // Create hour by hour chart data
 [self setDailyChart];
 */

    //removal of the function -(void)createTemperatureData
    // created storeAllTempData in place of


    // ALSO a decent amount of changes to the charts view

    // Labels and variables are the same from DetailViewController
    //if you need to rename variables then change them from here not in temperatures

-(void)storeAllcarbonData
{
    self.chartData = [[NSMutableArray alloc] init];
    self.fullChartData = [[NSMutableArray alloc] init];
        // NSLog(@"count: %d", (int)carbonData.count);
    for (int i = 0; i <carbonData.count; i++) {
        
        if (i <= carbonData.count) {
            NSString *currentcarbon = [NSString stringWithFormat:@"%@", carbonData[i]];
            currentcarbon = [currentcarbon stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *fullHumid = [currentcarbon stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            
            [self.fullChartData addObject:fullHumid];
                // NSLog(@"%@", fullHumid);
            currentcarbon = [currentcarbon substringToIndex:5];
            currentcarbon = [currentcarbon stringByReplacingOccurrencesOfString:@"*" withString:@""];
                //   NSLog(@"%@", currentcarbon);
            [self.chartData addObject:[NSNumber numberWithFloat:[currentcarbon doubleValue]]];
            if(i==carbonData.count)
                latestDay = self.fullChartData[i];
        }
    }
}

-(void)setDailyChart
{
    [self storeAllcarbonData];
        //NSLog(@"%@", self.fullChartData);
    NSString *TodaysDate = [NSString stringWithFormat:@"%@",self.fullChartData[self.fullChartData.count-1]];
    TodaysDate = [TodaysDate substringFromIndex:5];
    TodaysDate = [TodaysDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSString *TodaysDay = [TodaysDate substringWithRange:NSMakeRange(8, 2)];
        // NSLog(@"%@", TodaysDay);
    NSMutableArray *day1Data = [[NSMutableArray alloc]init];
    NSMutableArray *fullTextData = [[NSMutableArray alloc] init];
    aSingleHourArray = [[NSMutableArray alloc] init];
    averageOfHoursInDay = [[NSMutableArray alloc] init];
    hourData = [[NSMutableArray alloc] init];
    int dayToStart =0;
    dayToStart = (int)[TodaysDay integerValue];
    
    for(int i=0; i < self.fullChartData.count; i++)
    {
        NSString *label = [NSString stringWithFormat:@"%@", self.fullChartData[i]];
        
            // Parse some extra data from the data returned value to find the date
        NSString *currentDate = [label substringFromIndex:5];
        currentDate = [currentDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
        NSString *currentDay = [currentDate substringWithRange:NSMakeRange(8, 2)];
            // NSLog(@"%@",currentDay);
        if([currentDay integerValue] == dayToStart)
        {
                // NSLog(@"label: %@", label);
            [fullTextData addObject:label];
            [day1Data addObject:label];
        }
    }
    if(day1Data.count ==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Data Found"
                                                        message:@"There was no data recorded for today. Trying Weekly data..."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.weekButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    else if (day1Data.count ==1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Data Yet"
                                                        message:@"Wait for more data to be recorded... The charts will now show weekly data."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.weekButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
            // find how many hours a day the carbon meter recorded data for
            // then set the numberofViews2 to this value
        
        for(int i=0; i<day1Data.count;i++)
        {
            NSString *label = [NSString stringWithFormat:@"%@", fullTextData[i]];
                // Parse some extra data from the data returned value to find the date
            NSString *currentDate = [label substringFromIndex:5];
            currentDate = [currentDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
            NSString *currentHour = [currentDate substringWithRange:NSMakeRange(11, 2)];
                // NSLog(@"Current Hour %@", currentHour);
            int currentHour1 = (int)[currentHour integerValue];
                // if the array is empty add the first hour data
            if(hourData.count ==0) {
                [hourData addObject:currentHour];
            }
                // otherwise go through the array to make sure it has not already been added. Then add it if it does not exist
            else {
                if([hourData[hourData.count-1] integerValue] == currentHour1) {
                        //do nothing
                } else {
                    [hourData addObject:currentHour];
                }
            }
        }
            // create integers the currentHour will be the current itteration through the loop
            // the temp will store the previous itteration (the last hour read) in the loop
        int temp=0;
        int currentHour1=0;
        for(int q =0; q<day1Data.count;q++) {
                // do not have temp be set yet
                // just add the first element to aSingleHourArray
            if(aSingleHourArray.count==0) {
                NSString *label = [NSString stringWithFormat:@"%@", fullTextData[q]];
                    // Parse some extra data from the data returned value to find the date
                NSString *currentDate = [label substringFromIndex:5];
                currentDate = [currentDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
                NSString *currentHour = [currentDate substringWithRange:NSMakeRange(11, 2)];
                currentHour1 = (int)[currentHour integerValue];
                [aSingleHourArray addObject:label];
            } else {
                    // Now that there is data in the array save the previous Hour read
                    // then find what current hour read is
                
                temp = currentHour1;
                NSString *label = [NSString stringWithFormat:@"%@", fullTextData[q]];
                    // Parse some extra data from the data returned value to find the date
                NSString *currentDate = [label substringFromIndex:5];
                currentDate = [currentDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
                    // NSLog(@"%@", currentDate);
                NSString *currentHour = [currentDate substringWithRange:NSMakeRange(11, 2)];
                currentHour1 = (int)[currentHour integerValue];
                    // if the previous and the current hour are the same then add them to the same hour array
                if(temp == currentHour1) {
                    [aSingleHourArray addObject:label];
                } else {
                        // if the previous and current hour are different then find the average of the array without the current value
                    float average =      [self findAverage:aSingleHourArray];
                        // a simple way to convert int's to ID's
                    NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
                    [averageOfHoursInDay addObject:averageHour];
                    [aSingleHourArray removeAllObjects]; // clear the array once its used
                                                         //if you are not the last element add it automatically to the new array
                    
                    if(q!=day1Data.count-1) {
                        [aSingleHourArray addObject:label];
                    }
                        // if you are the last element and it is not the same as the last hour then add it to an array and
                        // get its average add it to the array and end the for loop
                    if(q==day1Data.count-1) {
                        [aSingleHourArray addObject:label];
                        float average = [self findAverage:aSingleHourArray];
                            // a simple way to convert floats's to ID's
                        NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
                        [averageOfHoursInDay addObject:averageHour];
                    }//if
                }//else
            }//else
        }//for
        
            // if you still had data in the array before the for loop ended find the average and record it
            // This is used because if the last hour and the current hour are the same they will end the for loop before
            // finding out the average for the last hour
        if(aSingleHourArray.count>0) {
            float average = [self findAverage:aSingleHourArray];
                // a simple way to convert int's to ID's
            NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
            [averageOfHoursInDay addObject:averageHour];
        }
            // set the number of views to the amount of hours found in the database with the current day
        numberOfViews_C = (int)averageOfHoursInDay.count;
        whichTypeofChart=0; // hour to hour view
        [self.lineChartView reloadData]; // set the chart
    }
}

- (IBAction)dailyChart:(id)sender{
    
    [self setDailyChart]; // set hour to hour charts
                          // dont allow you to click the button again
    self.dayButton.enabled=false;
    self.weekButton.enabled=true;
        // alert the user to what they are now viewing
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hour To Hour Data"
                                                    message:@"Currently viewing hourly averages from today"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
        // once the alert is shown go ahead and clear the labels =)
    self.currentChartValueLabel.text = @"";
    self.currentCarbonLabel.text = @"";
}

-(void)handleAddWeek:(int)dayToStart
              second:(int)daysInMonth
               third:(int)monthToStart {
        // remove all of the objects in the arrays before adding to them
    [lastWeek removeAllObjects];
    [lastMonth removeAllObjects];
    int insertDay = dayToStart+1;
    monthToStart-=1;
    for(int i=1; i<=7; i++) {
        if(insertDay>daysInMonth) {
            insertDay =1;
            
            if(monthToStart==0) {
                monthToStart=12;
            } else monthToStart+=1;
        }
        [lastWeek addObject:[NSString stringWithFormat:@"%d", insertDay]];
        insertDay+=1;
        
        [lastMonth addObject:[NSString stringWithFormat:@"%d", monthToStart]];
    }
}

- (IBAction)WeeklyChart:(id)sender {
    int startMonth=0;
    int startDay=0;
    int monthValue;
    NSString *TodaysDate = [NSString stringWithFormat:@"%@",self.fullChartData[self.fullChartData.count-1]];
    TodaysDate = [TodaysDate substringFromIndex:5];
    TodaysDate = [TodaysDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSLog(@"%@", TodaysDate);
    NSString *TodaysMonth = [TodaysDate substringWithRange:NSMakeRange(5, 2)];
    NSString *TodaysDay = [TodaysDate substringWithRange:NSMakeRange(8, 2)];
    NSLog(@"%@/%@", TodaysMonth, TodaysDay);
    monthValue = (int)[TodaysMonth integerValue];
        // this array will hold the 7 days that you want
        // for example 4, 3, 2, 1, 31, 30, 29
        // or 17, 16, 15, 14, 13, 12, 11
    lastWeek = [[NSMutableArray alloc] init];
        // the month data will hold the last 7 days month
        // for example 12, 12, 12, 11, 11, 11,11
        // or 1, 1, 1, 12, 12, 12, 12
    lastMonth =[[NSMutableArray alloc] init];
    
    sevenData = [[NSMutableArray alloc] init];
        // since you are within the first week we need to find out what is the 7th day back
    if([TodaysDay integerValue]<7) {
            // if your in january 1st-7th then you would end up in december
        if([TodaysMonth integerValue] <1) {
            startMonth =12;
        }
            // otherwise you are in the month previous
        else {
            startMonth = monthValue -1;
        }
            // there are 31 days in the month previous
        
        if(monthValue == 1 || monthValue ==2|| monthValue == 4 || monthValue == 6 || monthValue == 8 || monthValue == 9 || monthValue == 11) {
            int temp;
            temp = (int)[TodaysDay integerValue] -7;
                // if you are still within the first 7 days
            if(temp <=0) {
                temp = abs(temp);
                startDay =31- temp;
                [self handleAddWeek:startDay second:31
                              third:monthValue];
            }
        }
            // there are 30 days in the month previous
        if(monthValue == 5 || monthValue ==7|| monthValue == 10 || monthValue == 12) {
            int temp;
            temp = (int)[TodaysDay integerValue] -7;
                // if you are still within the first 7 days
            if(temp <=0) {
                temp = abs(temp);
                startDay =30- temp;
                [self handleAddWeek:startDay second:30 third:monthValue];
                
            }
        }
            // there are 28 days in the month previous
        if(monthValue == 3) {
            int temp;
            temp = (int)[TodaysDay integerValue] -7;
                // if you are still within the first 7 days
            if(temp <=0) {
                temp = abs(temp);
                startDay =28- temp;
                [self handleAddWeek:startDay second:28 third:monthValue];
            }
        }
    }
    else {
        startDay = (int)[TodaysDay integerValue] -7;
            // the second parameter doesnt mean anything here
            // but add 1 to the month value!!!
        [self handleAddWeek:startDay second:30 third:monthValue+1];
    }
        // This is the day and month we should start on if you click on weekly data
        //Once you click on weekly data then you want to average all of the data from each day and just display 1 number for each day. (the average)
        // First lets load up a bunch of values from the PHP scripts
    
        // Then we will create new temperature data based on the new constraints
        // but first we want to clear out all of the old data from the arrays as to not have extra data
        // NSLog(@"handleAddWeek: %@", lastWeek);
        //NSLog(@"%@", lastMonth);
    [self.fullChartData removeAllObjects];
    [self.chartData removeAllObjects];
    [self storeAllcarbonData];
        // Now that we have the new data we will search through it and exctract out each days data
    NSMutableArray *day1Data = [[NSMutableArray alloc]init];
    NSMutableArray *day2Data = [[NSMutableArray alloc]init];
    NSMutableArray *day3Data = [[NSMutableArray alloc]init];
    NSMutableArray *day4Data = [[NSMutableArray alloc]init];
    NSMutableArray *day5Data = [[NSMutableArray alloc]init];
    NSMutableArray *day6Data = [[NSMutableArray alloc]init];
    NSMutableArray *day7Data = [[NSMutableArray alloc]init];
    for(int i=0; i < self.fullChartData.count; i++) {
        
        NSString *label = [NSString stringWithFormat:@"%@", self.fullChartData[i]];
        
            // Parse some extra data from the data returned value to find the date
        NSString *currentDate = [label substringFromIndex:5];
        currentDate = [currentDate stringByReplacingOccurrencesOfString:@"*" withString:@""];
        NSString *currentDay = [currentDate substringWithRange:NSMakeRange(8, 2)];
        
        if([currentDay integerValue] == [lastWeek[6]integerValue]) {
            [day1Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[5]integerValue]) {
            [day2Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[4]integerValue]) {
            [day3Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[3]integerValue]) {
            [day4Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[2]integerValue]) {
            [day5Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[1]integerValue]) {
            [day6Data addObject:label];
        }
        if([currentDay integerValue] == [lastWeek[0]integerValue]) {
            [day7Data addObject:label];
        }
            //LEAVE THIS SPACE HERE TO ADD MORE THAN 7 DAYS WORTH OF DATA
            // ALSO CREATE A FOR LOOP TO CREATE 1 ARRAY ONCE A NEW DAY CREATE NEW AVERAGE
    }
    
        // alert the user what will happen with the charts
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Day To Day Data"
                                                    message:@"Currently viewing averages for the past 7 days"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
        // once the alert is shown go ahead and clear the labels =)
    self.currentChartValueLabel.text = @"";
    self.currentCarbonLabel.text = @"";
    
    numberOfViews_C =7; // this can later be used for a user preference to expand to 10 day history instead
    whichTypeofChart =1; // day to day chart
    /*
    NSLog(@"Size of arrays");
    NSLog(@"%d", (int)day1Data.count);
    NSLog(@"%d", (int)day2Data.count);
    NSLog(@"%d", (int)day3Data.count);
    NSLog(@"%d", (int)day4Data.count);
    NSLog(@"%d", (int)day5Data.count);
    NSLog(@"%d", (int)day6Data.count);
    NSLog(@"%d", (int)day7Data.count);
    */
        // add to a NSMutableArray the last seven days averages for arrays
    /*
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day1Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day2Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day3Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day4Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day5Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day6Data]]];
     [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day7Data]]];
     */
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day7Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day6Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day5Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day4Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day3Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day2Data]]];
    [sevenData addObject:[NSString stringWithFormat:@"%.1lf", [self findAverage:day1Data]]];
    [self.lineChartView reloadData];
    self.weekButton.enabled=false;
    self.dayButton.enabled=true;
}

    // this will find the average for any array
-(float)findAverage:(NSMutableArray*)array {
    float average=0;
    
    for(int i=0; i< array.count; i++) {
        NSString *label = [NSString stringWithFormat:@"%@", array[i]];
            // the first 3 characters will be the current humidity
        NSString *currentHumidity = [label substringToIndex:3];
        
        average = average+ [currentHumidity integerValue];
    }
    average = average/array.count;
    
    return average;
}

#pragma Notification
- (void) registerAllNotification {
    self.isShowingLandscapeView = UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    self.previousOrientation    = NO;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

#pragma mark -
#pragma mark Orientation Method
- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !self.isShowingLandscapeView) {
        self.isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && self.isShowingLandscapeView) {
        self.isShowingLandscapeView = NO;
    }
    
    if (self.previousOrientation != self.isShowingLandscapeView) {
        if (self.isShowingLandscapeView) {
                //  NSLog(@"Orientation Change Occur: Landscape Mode");
        }
        else {
                // NSLog(@"Orientation Change Occur: Portrait Mode");
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrientationChange" object:nil];
        [self updateUI];
    }
    
    self.previousOrientation = self.isShowingLandscapeView;
    if (self.isShowingLandscapeView) {
            //do the landscape tasks
            //NSLog(@"LANDSCAPE");
        [self.lineChartView reloadData];
    } else {
            //do the portrait tasks
            // NSLog(@"Portrait");
        [self.lineChartView reloadData];
    }
}


    // JB CHART METHODS --------------------------------------------------------------------------------

    // REQUIRED: number of lines in the chart
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    return 1;
} // numberOfLinesInLineChartView

    // REQUIRED: number of x values for each line
- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return numberOfViews_C;
} // lineChartView numberOfVerticalValuesAtLineIndex

    // REQUIRED: how we retrieve y values for each x values
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
        // used for day to day chart
    if(whichTypeofChart==1) {
        float val = [[sevenData objectAtIndex:horizontalIndex] floatValue];
        return val;
    } else { // this will be a hour by hour chart // later to add week by week
        float val = [[averageOfHoursInDay objectAtIndex:horizontalIndex] floatValue];
        return val;
    }
} // lineChartView verticalValueForHorizontalIndex

    // OPTIONAL: line color. You can apparently use the index to have different colors at different points
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    if(lineIndex <=1) { // if you have selected line index 0 (or nothing)
        return [UIColor grayColor];
    } else // while scrolling it changes colors
        return [UIColor  whiteColor]; // color of line in chart
} // lineChartView colorForLineAtLineIndex

    // OPTIONAL: take the value once updated and display it on a label
- (void)lineChartView:(JBLineChartView *)lineChartView
 didSelectLineAtIndex:(NSUInteger)lineIndex
      horizontalIndex:(NSUInteger)horizontalIndex
           touchPoint:(CGPoint)touchPoint {
        //NSNumber *valueNumber = [self.chartData objectAtIndex:horizontalIndex];
    
        //self.currentChartValueLabel.text = [NSString stringWithFormat:@"%.0f", [valueNumber floatValue]];
        // this is the chart for viewing hourly data
    if(whichTypeofChart ==0) {
            //NSLog(@"%@", averageOfHoursInDay);
            //NSLog(@"%d, %d", (int)averageOfHoursInDay.count, (int)hourData.count);
        self.currentCarbonLabel.text = [NSString stringWithFormat:@"%.0lf ppm", [[averageOfHoursInDay objectAtIndex:horizontalIndex] floatValue]];
        int hour =(int)[[hourData objectAtIndex:horizontalIndex] integerValue];
        self.currentChartValueLabel.text = [NSString stringWithFormat:@"%d:00 - %d:00",hour, (hour +1)];
    }
        // this chart it for viewing averages of daily values for an entire 7 days
    if(whichTypeofChart ==1) {
        self.currentCarbonLabel.text = [NSString stringWithFormat:@"%@ ppm", sevenData[(int)horizontalIndex]];
        self.currentChartValueLabel.text = [NSString stringWithFormat:@"%@/%@",lastMonth[(int)horizontalIndex],  lastWeek[(int)horizontalIndex]];
    }
} // lineChartView didSelectLineAtIndex horizontalIndex touchPoint

    // END JB CHART METHODS ----------------------------------------------------------------------------





@end