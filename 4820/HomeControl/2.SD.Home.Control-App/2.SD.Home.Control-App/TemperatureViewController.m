//
//  DetailViewController.m
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/18/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//


#import "TemperatureViewController.h"

@interface TemperatureViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>
    @property (weak, nonatomic) IBOutlet JBLineChartView *lineChartView;
    @property (nonatomic, strong) NSMutableArray *chartData;
    @property (nonatomic, strong) NSMutableArray *fullChartData;
    @property (weak, nonatomic) IBOutlet UILabel *currentChartValueLabel;
    @property (strong, nonatomic) IBOutlet UILabel *currentTempLabel;
    @property (strong, nonatomic) IBOutlet UIButton *DayButton;
    @property (strong, nonatomic) IBOutlet UIButton *weekButton;
@end

@implementation TemperatureViewController
    AppDelegate *temperatureAppDelegate;
    float setTemperature2=0;
    NSMutableArray *tempData;
    int numberOfViews2 = 25;
    NSString *latestDay;
    NSMutableArray *lastWeek; // the last 7 days
    NSMutableArray *sevenData; // the temp data for the week
    NSMutableArray *lastMonth; // the last 7 months ( that the last 7 days occured in
    NSMutableArray *hourData; // the hours of the day that have data
    int whichTypeofChart; // 0 for standard // 1 for weekly // 2 for daily
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
        temperatureAppDelegate.isAdmin = true;
    } else {
        temperatureAppDelegate.isAdmin = false;
        NSLog(@"isNotAdmin");
    }
    //end admin check
}


-(void)updateUI {
    //get current temp
    NSString *strURL1 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastTemperature.php"];
    NSError *error1 = nil;
    NSString *strResult1;
    strResult1 = [[NSString alloc] init];
    strResult1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL1]  encoding:NSUTF8StringEncoding error:&error1];

    //set temp label
    temperatureAppDelegate.currentTemperature = [strResult1 floatValue];
    self.currentLabel.text = [NSString stringWithFormat:@"%.1lf", [strResult1 floatValue]];
    
    //get ideal temp
    NSString *strURL2 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealTemp.php"];
    NSError *error2 = nil;
    NSString *strResult2;
    strResult2 = [[NSString alloc] init];
    strResult2 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL2]  encoding:NSUTF8StringEncoding error:&error2];

    //set ideal temp
    temperatureAppDelegate.setTemperature = [strResult2 floatValue];
    self.idealLabel.text = [NSString stringWithFormat:@"Set: %.1lf", [strResult2 floatValue]];
    setTemperature2 = [strResult2 floatValue];
    [self setColorOfCurrentTemp];

    //if user is not admin, hide increment/decrement buttons
    if(temperatureAppDelegate.isAdmin) {
        self.incrementButton.enabled = true;
        self.decrementButton.enabled = true;
    }
    // the user is not an admin
    if(!temperatureAppDelegate.isAdmin) {
        self.decrementButton.enabled = false;
        self.incrementButton.enabled = false;
    }
    // get all of the temperature data in the database store them into a mutable array called tempData
    NSString *strURL3 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getAllTemperatures.php"];
    NSError *error3 = nil;
    NSString *strResult3;
    strResult3 = [[NSString alloc] init];
    strResult3 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL3]  encoding:NSUTF8StringEncoding error:&error3];
    
    NSString *jsonData = [NSString stringWithFormat:@"%@", strResult3];
    NSRange searchRange = NSMakeRange(0,jsonData.length);
    NSRange foundRange;
    NSString *substring = @"currentTemp=";
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
            if(secondRange.location !=NSNotFound) {
                // we found the second substring too!
                searchRange.location = foundRange.location+foundRange.length;
                startLocation = searchRange.location;
                searchRange.location = secondRange.location +secondRange.length;
                lengthOfNameString = searchRange.location-startLocation;
                
                [tempData addObject:[jsonData substringWithRange:NSMakeRange(startLocation, lengthOfNameString)]];
            }
        } else {
            // no more substring to find
            break;
        }
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Set sound effects
    [self.incrementButton setSoundNamed:@"tap-warm.aif" forControlEvent:UIControlEventTouchDown];
    [self.decrementButton setSoundNamed:@"tap-muted.aif" forControlEvent:UIControlEventTouchDown];
} // viewDidLoad

- (IBAction)incrementSetTemp:(id)sender {
    setTemperature2 +=1;
    if(setTemperature2 > 110) {
        setTemperature2 = 50;
    }
    self.idealLabel.text  = [NSString stringWithFormat:@"Set: %.1lf", setTemperature2];
    temperatureAppDelegate.setTemperature = setTemperature2;
    // once you click the button start a timer. This timer will automatically click the set temperature button once 3 seconds have passed without another stepper button clicked.
    
    [timer invalidate];
    seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSeconds) userInfo:nil repeats:YES];
}

- (IBAction)decrementSetTemp:(id)sender {
    setTemperature2 -=1;
    if(setTemperature2 < 50) {
        setTemperature2 = 110;
    }
    self.idealLabel.text  = [NSString stringWithFormat:@"Set: %.1lf", setTemperature2];
    temperatureAppDelegate.setTemperature = setTemperature2;
    // once you click the button start a timer. This timer will automatically click the set temperature button once 3 seconds have passed without another stepper button clicked.
    
    [timer invalidate];
    seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSeconds) userInfo:nil repeats:YES];
}

-(void)timerSeconds {
    seconds = seconds +1;
    if(seconds >1) {
        // you have not pressed another button for at least 3 seconds so go ahead and set the temperature
        [self doSync];
    }
}

-(void)doSync {
    temperatureAppDelegate.setTemperature = setTemperature2;
    
    NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/setTemperature.php?setTemp=%lf", setTemperature2];
    NSError *error = nil;
    returnString = [[NSString alloc] init];
    returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
    
    [timer invalidate];
    seconds =0;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Temperature Set"
                                                    message:[NSString stringWithFormat:@"Your Thermometer is now set to %.1lf", temperatureAppDelegate.setTemperature]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self setColorOfCurrentTemp];
}

-(void)setColorOfCurrentTemp {
    float differenceOfTemps = fabsf(temperatureAppDelegate.setTemperature - temperatureAppDelegate.currentTemperature);
    
    if(differenceOfTemps < 3) {
        self.currentLabel.textColor = [UIColor greenColor];
    } else {
        self.currentLabel.textColor = [UIColor redColor];
    }
}

- (void)loadView {
    [super loadView];
    whichTypeofChart =0;
    tempData =  [[NSMutableArray alloc] initWithObjects:nil];
    temperatureAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    // Viewing data for today
    [self setDailyChart];
} // loadView

// parse some extra data from the php scripts and add the value to the chart
-(void)storeAllTempData {
    self.chartData = [[NSMutableArray alloc] init];
    self.fullChartData = [[NSMutableArray alloc] init];
    for (int i = 0; i <tempData.count; i++) {
        if (i <= tempData.count) {
            NSString *currentTemp = [NSString stringWithFormat:@"%@", tempData[i]];
            currentTemp = [currentTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *fullTemp = [currentTemp stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            [self.fullChartData addObject:fullTemp];
            currentTemp = [currentTemp substringToIndex:5];
            
            [self.chartData addObject:[NSNumber numberWithFloat:[currentTemp doubleValue]]];
            if(i==tempData.count)
                latestDay = self.fullChartData[i];
        }
    }
}

-(void)setDailyChart {
    [self storeAllTempData];
    NSString *TodaysDate = [NSString stringWithFormat:@"%@",self.fullChartData[self.fullChartData.count-1]];
    
    NSString *TodaysDay = [TodaysDate substringWithRange:NSMakeRange(13, 2)];
    NSMutableArray *day1Data = [[NSMutableArray alloc]init];
    NSMutableArray *fullTextData = [[NSMutableArray alloc] init];
    aSingleHourArray = [[NSMutableArray alloc] init];
    averageOfHoursInDay = [[NSMutableArray alloc] init];
    hourData = [[NSMutableArray alloc] init];
    int dayToStart =0;
    dayToStart = (int)[TodaysDay integerValue];
    
    for(int i=0; i < self.fullChartData.count; i++) {
        NSString *label = [NSString stringWithFormat:@"%@", self.fullChartData[i]];
        
        // Parse some extra data from the data returned value to find the date
        NSString *currentDate = [label substringFromIndex:4];
        NSString *currentYear = [currentDate substringToIndex:6];
        currentYear = [currentYear substringToIndex:4];
        
        NSString *currentDay = [currentDate substringWithRange:NSMakeRange(9, 2)];
        
        if([currentDay integerValue] == dayToStart) {
            [fullTextData addObject:label];
            [day1Data addObject:label];
        }
    }
    
    if(day1Data.count ==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Data Found"
                                                        message:@"There was no data recorded for today. Trying Weekly data..."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.weekButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    } else if (day1Data.count ==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Data Yet"
                                                        message:@"Wait for more data to be recorded... The charts will now show weekly data."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.weekButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        // find how many hours a day the thermometer recorded data for
        // then set the numberofViews2 to this value
        
        for(int i=0; i<day1Data.count;i++) {
            NSString *label = [NSString stringWithFormat:@"%@", fullTextData[i]];
            // Parse some extra data from the data returned value to find the date
            NSString *currentDate = [label substringFromIndex:4];
            
            
            NSString *currentHour = [currentDate substringWithRange:NSMakeRange(12, 2)];
            int currentHour1 = (int)[currentHour integerValue];
            // if the array is empty add the first hour data
            if(hourData.count ==0) {
                [hourData addObject:currentHour];
            }
            // otherwise go through the array to make sure it has not already been added. Then add it if it does not exist
            else {
                if([hourData[hourData.count-1] integerValue] == currentHour1) {
                    // do Nothing
                }
                else {
                    [hourData addObject:currentHour];
                }
            }//else
        }
        int temp=0;
        int currentHour1=0;
        for(int q =0; q<day1Data.count;q++) {
            if(aSingleHourArray.count==0) {
                NSString *label = [NSString stringWithFormat:@"%@", fullTextData[q]];
                // Parse some extra data from the data returned value to find the date
                NSString *currentDate = [label substringFromIndex:4];
                NSString *currentHour = [currentDate substringWithRange:NSMakeRange(12, 2)];
                currentHour1 = (int)[currentHour integerValue];
                [aSingleHourArray addObject:label];
            }
            else {
                temp = currentHour1;
                NSString *label = [NSString stringWithFormat:@"%@", fullTextData[q]];
                // Parse some extra data from the data returned value to find the date
                NSString *currentDate = [label substringFromIndex:4];
                
                NSString *currentHour = [currentDate substringWithRange:NSMakeRange(12, 2)];
                currentHour1 = (int)[currentHour integerValue];
                
                if(temp == currentHour1) {
                    [aSingleHourArray addObject:label];
                } else {
                    float average = [self findAverage:aSingleHourArray];
                    // a simple way to convert int's to ID's
                    NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
                    [averageOfHoursInDay addObject:averageHour];
                    [aSingleHourArray removeAllObjects];
                    if(q!=day1Data.count-1) {
                        [aSingleHourArray addObject:label];
                    }
                    if(q==day1Data.count-1) {
                        //currentHour1+=1;
                        [aSingleHourArray removeAllObjects];
                        [aSingleHourArray addObject:label];
                        float average =      [self findAverage:aSingleHourArray];
                        // a simple way to convert floats's to ID's
                        NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
                        [averageOfHoursInDay addObject:averageHour];
                    }
                }
            }
        }
        if(aSingleHourArray.count>0) {
            float average = [self findAverage:aSingleHourArray];
            // a simple way to convert floats's to ID's
            NSString *averageHour = [NSString stringWithFormat:@"%.1lf", average];
            [averageOfHoursInDay addObject:averageHour];
        }
        
        numberOfViews2 = (int)averageOfHoursInDay.count;
        whichTypeofChart=0;
        [self.lineChartView reloadData];
    }
}
- (IBAction)dailyChart:(id)sender{
    
    [self setDailyChart];
    
    self.DayButton.enabled=false;
    self.weekButton.enabled=true;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hour To Hour Data"
                                                    message:@"Currently viewing hourly averages from today"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    // once the alert is shown go ahead and clear the labels =)
    self.currentChartValueLabel.text = @"";
    self.currentTempLabel.text = @"";
    
}

-(void)handleAddWeek:(int)dayToStart
              second:(int)daysInMonth
               third:(int)monthToStart
{
    [lastWeek removeAllObjects];
    [lastMonth removeAllObjects];
    int insertDay = dayToStart+1;
    monthToStart-=1;
    for(int i=1; i<=7; i++) {
        if(insertDay>daysInMonth) {
            insertDay =1;
            
            if(monthToStart==0) {
                monthToStart=12;
            }
            else
                monthToStart+=1;
        }//if
        [lastWeek addObject:[NSString stringWithFormat:@"%d", insertDay]];
        insertDay+=1;
        
        [lastMonth addObject:[NSString stringWithFormat:@"%d", monthToStart]];
    }//for
}//handleAddWeek

- (IBAction)WeeklyChart:(id)sender{
    int startMonth=0;
    int startDay=0;
    int monthValue;
    NSString *TodaysDate = [NSString stringWithFormat:@"%@",self.fullChartData[self.fullChartData.count-1]];
    // NSLog(@"%@", TodaysDate);
    NSString *TodaysMonth = [TodaysDate substringWithRange:NSMakeRange(10, 2)];
    NSString *TodaysDay = [TodaysDate substringWithRange:NSMakeRange(13, 2)];
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
    } else {
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
    [self.fullChartData removeAllObjects];
    [self.chartData removeAllObjects];
    [self storeAllTempData];
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
        NSString *currentDate = [label substringFromIndex:4];
        NSString *currentDay = [currentDate substringWithRange:NSMakeRange(9, 2)];
        
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
    self.currentTempLabel.text = @"";
    
    numberOfViews2 =7;
    whichTypeofChart =1;
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
    self.DayButton.enabled=true;
}

// this will find the average for any array
-(float)findAverage:(NSMutableArray*)array {
    float average=0;
    
    for(int i=0; i< array.count; i++) {
        NSString *label = [NSString stringWithFormat:@"%@", array[i]];
        // the first 4 characters will be the current temp
        NSString *currentTemp = [label substringToIndex:4];
        
        average = average+ [currentTemp floatValue];
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
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !self.isShowingLandscapeView) {
        self.isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             self.isShowingLandscapeView) {
        self.isShowingLandscapeView = NO;
    }
    
    if (self.previousOrientation != self.isShowingLandscapeView) {
        if (self.isShowingLandscapeView) {
        } else {
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
    return numberOfViews2;
} // lineChartView numberOfVerticalValuesAtLineIndex

// REQUIRED: how we retrieve y values for each x values
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    
    if(whichTypeofChart==1) {
        float val = [[sevenData objectAtIndex:horizontalIndex] floatValue];
        return val;
    } else {
        float val = [[averageOfHoursInDay objectAtIndex:horizontalIndex] floatValue];
        return val;
    }
} // lineChartView verticalValueForHorizontalIndex

// OPTIONAL: line color. You can apparently use the index to have different colors at different points
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    // NSLog(@"LINE INDEX %d", (int)lineIndex);
    if(lineIndex <=1) { // if you have selected line index 0 (or nothing)
        return [UIColor grayColor];
    } else // while scrolling it changes colors
        return [UIColor  whiteColor]; // color of line in chart
} // lineChartView colorForLineAtLineIndex

// OPTIONAL: take the value once updated and display it on a label
- (void)lineChartView:(JBLineChartView *)lineChartView
 didSelectLineAtIndex:(NSUInteger)lineIndex
      horizontalIndex:(NSUInteger)horizontalIndex
           touchPoint:(CGPoint)touchPoint{
    
    if(whichTypeofChart ==0) {
        self.currentTempLabel.text = [NSString stringWithFormat:@"%.1lf ℉", [[averageOfHoursInDay objectAtIndex:horizontalIndex] floatValue]];
        int hour =(int)[[hourData objectAtIndex:horizontalIndex] integerValue];
        self.currentChartValueLabel.text = [NSString stringWithFormat:@"%d:00 - %d:00",hour, (hour +1)];
    }
    if(whichTypeofChart ==1) {
        self.currentTempLabel.text = [NSString stringWithFormat:@"%@ ℉", sevenData[(int)horizontalIndex]];
        self.currentChartValueLabel.text = [NSString stringWithFormat:@"%@/%@",lastMonth[(int)horizontalIndex],  lastWeek[(int)horizontalIndex]];
    }
} // lineChartView didSelectLineAtIndex horizontalIndex touchPoint

// END JB CHART METHODS ----------------------------------------------------------------------------

@end