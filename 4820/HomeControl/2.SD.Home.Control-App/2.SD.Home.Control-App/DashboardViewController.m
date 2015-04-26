//
//  DashboardViewController.m
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/17/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DashboardViewController.h"

// Octave sound effects
#import "UIControl+Sound.h"

@interface DashboardViewController()

//outlets in .h


@property (weak, nonatomic) IBOutlet UIView *contentView;

@end



@implementation DashboardViewController
AppDelegate *homeAppDelegate;
    // these setColorofCurrent*** functions ware used in the dashboard to color the tiles
    // color codes green for within optimal range
    // color codes red for outside of optimal range
-(void)setColorOfCurrentTempHome
{
    float difference = fabsf(homeAppDelegate.setTemperature - homeAppDelegate.currentTemperature);
        // if set to 70 & is 65
        // difference = 5
        // absolute value
    if(difference <3) // if current Temperature is within __ from set Temperature
    {
        self.currentTempLabel.textColor = [UIColor greenColor];
    }
    else
    {
        
        self.currentTempLabel.textColor = [UIColor redColor];
    }
}
-(void)setColorOfCurrentHumidityHome
{
    float difference = fabsf(homeAppDelegate.setHumidity - homeAppDelegate.currentHumidity);
    
    if(difference <4) // if current humidity is within __ from set humidity
    {
        self.currentHumidityLabel.textColor = [UIColor greenColor];
    }
    else
    {
        
        self.currentHumidityLabel.textColor = [UIColor redColor];
    }
}
-(void)setColorOfCurrentCarbonHome
{
    float isCO2LevelTooHigh = (homeAppDelegate.setCO2 - homeAppDelegate.currentCO2);
    
    if(isCO2LevelTooHigh >=100) // if the set ppm is less than current by more than 100
    {
        self.currentCarbonLabel.textColor = [UIColor greenColor];
    }
    else
    {
        
        self.currentCarbonLabel.textColor = [UIColor redColor];
    }
}
-(void)setColorOfCurrentWaterHome
{
    float isWaterConsumptionTooMuch = (homeAppDelegate.setWater - homeAppDelegate.currentWater);
    
    if(isWaterConsumptionTooMuch >0) // if set water consumption is less than current
    {
        self.currentWaterLabel.textColor = [UIColor greenColor];
    }
    else
    {
        
        self.currentWaterLabel.textColor = [UIColor redColor];
    }
}
-(void)setColorOfCurrentPowerHome
{
    float isPowerConsumptionTooMuch = (homeAppDelegate.setPower - homeAppDelegate.currentPower);
    
    if(isPowerConsumptionTooMuch >0) // if set power consumption is less than current
    {
        self.currentEnergyLabel.textColor = [UIColor greenColor];
    }
    else
    {
        
        self.currentEnergyLabel.textColor = [UIColor redColor];
    }
}
/*
 refreshButton
 The rightmost button on the dashboard navigation bar
 The only function this button does is refresh all of the labels 
 Calls upon the function updateUI 

This is used because as the dashboard only updates every minute, 
 if the user would like to have the most up to date information now
 they could click this button
 */
- (IBAction)refreshButton:(id)sender {
    [self updateUI];
}
/*
 updateUI
 void function that updates the entire dashboard labels
 a break down of the code in updateUI is as follows
 returnString* is the webcontents of the php script residing on the website stored in strURL*
 Once you know what the php script returns convert the ID value into a float or integer and 
 use the value in the appropriate label
 
 This function will run a total of 10 php scripts to obtain:
 Current & set temperature
 Current & set humidity
 Current & ideal water consumption in (US) gallons
 Current & ideal power consumption in kWh
 Current & ideal CO2 in PPM
 
 Once we have set the labels with the most up to date information in the database
 set the color of the current text label to red or green (setColorOfCurrent*** functions above)
 
 This function is used to display the most up to date information from the database on the tiles in the dashboard
 */
-(void)updateUI
{
        ///FIND OUT WHAT THE CURRENT TEMPERATURE IS AND SET THE LABEL
           // php script that returns last temperature
           /////////////////
    NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastTemperature.php"];
    NSError *error = nil;
    NSString *returnString;
    returnString = [[NSString alloc] init];
    returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //////////////////
            // convert the value into a float then set the label
    homeAppDelegate.currentTemperature = [returnString floatValue];
    self.currentTempLabel.text = [NSString stringWithFormat:@"%.1lf", homeAppDelegate.currentTemperature];
    
        //FIND OUT WHAT THE IDEAL TEMPERATURE IS AND SET THE LABEL
           // php script that returns ideal temperature
        //////////////
    NSString *strURL2 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealTemp.php"];
    NSError *error2 = nil;
    NSString *returnString2;
    returnString2 = [[NSString alloc] init];
    returnString2 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL2]  encoding:NSUTF8StringEncoding error:&error2];
            //////////////
        // convert the value into a float then set the label and color of label
    homeAppDelegate.setTemperature = [returnString2 floatValue];
    self.idealTempLabel.text = [NSString stringWithFormat:@"Set: %.1lf deg", homeAppDelegate.setTemperature];
    [self setColorOfCurrentTempHome];
    
        ///FIND OUT WHAT THE CURRENT HUMIDITY IS AND SET THE LABEL
        // php script that returns current humidity
        /////////////////
    NSString *strURL3 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastHumidity.php"];
    NSError *error3 = nil;
    NSString *returnString3;
    returnString3 = [[NSString alloc] init];
    returnString3 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL3]  encoding:NSUTF8StringEncoding error:&error3];
            /////////////////
            // convert the value into an int then set the label
    homeAppDelegate.currentHumidity = (int)[returnString3 integerValue];
    self.currentHumidityLabel.text = [NSString stringWithFormat:@"%d", homeAppDelegate.currentHumidity];
    
        ///FIND OUT WHAT THE IDEAL Humidity IS AND SET THE LABEL
        // php script that returns ideal humidity
        ////////////////
    NSString *strURL4 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealHumidity.php"];
    NSError *error4 = nil;
    NSString *returnString4;
    returnString4 = [[NSString alloc] init];
    returnString4 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL4]  encoding:NSUTF8StringEncoding error:&error4];
            ////////////////
            // convert the value into an int then set the label and color of label
    homeAppDelegate.setHumidity = (int)[returnString4 integerValue];
    self.idealHumidityLabel.text = [NSString stringWithFormat:@"Set: %d%%", homeAppDelegate.setHumidity];
    [self setColorOfCurrentHumidityHome];
    
        ///FIND OUT WHAT THE CURRENT WATER CONSUMPTION IS AND SET THE LABEL
        // php script that returns current water consumption
        /////////////////
    NSString *strURL5 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastWater.php"];
    NSError *error5 = nil;
    NSString *returnString5;
    returnString5 = [[NSString alloc] init];
    returnString5 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL5]  encoding:NSUTF8StringEncoding error:&error5];
            /////////////////
            // convert the value into an int then set the label
    homeAppDelegate.currentWater = (int)[returnString5 integerValue];
    self.currentWaterLabel.text = [NSString stringWithFormat:@"%d", homeAppDelegate.currentWater];
    
        ///FIND OUT WHAT THE IDEAL WATER CONSUMPTION IS AND SET THE LABEL
        // php script that returns ideal water consumption
        ////////////////
    NSString *strURL6 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealWater.php"];
    NSError *error6 = nil;
    NSString *returnString6;
    returnString6 = [[NSString alloc] init];
    returnString6 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL6]  encoding:NSUTF8StringEncoding error:&error6];
            ///////////////
            // convert the value into an int then set the label and color of label
    homeAppDelegate.setWater = (int)[returnString6 integerValue];
    self.idealWaterLabel.text = [NSString stringWithFormat:@"Goal: %d Gal", homeAppDelegate.setWater];
    [self setColorOfCurrentWaterHome];
    
        /// EVERY TIME THE VIEW LOADS FIND OUT WHAT THE CURRENT POWER CONSUMPTION IS AND SET THE LABEL
        // php script that returns current power consumption
        //////////////////
    NSString *strURL7 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastPower.php"];
    NSError *error7 = nil;
    NSString *returnString7;
    returnString7 = [[NSString alloc] init];
    returnString7 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL7]  encoding:NSUTF8StringEncoding error:&error7];
            /////////////////
            // convert the value into an int then set the label
    homeAppDelegate.currentPower = (int)[returnString7 integerValue];
 self.currentEnergyLabel.text = [NSString stringWithFormat:@"%d", homeAppDelegate.currentPower];
    
        // EVERYTIME THE VIEW LOADS FIND OUT WHAT THE IDEAL POWER CONSUMPTION IS AND SET THE LABEL
        // php script that returns ideal power consumption

        ///////////////
    
    NSString *strURL8 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealPower.php"];
    NSError *error8 = nil;
    NSString *returnString8;
    returnString8 = [[NSString alloc] init];
    returnString8 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL8]  encoding:NSUTF8StringEncoding error:&error8];
    //////////////
        // convert the value into an int then set the label and color of label
    homeAppDelegate.setPower = (int)[returnString8 integerValue];
    self.idealEnergyLabel.text = [NSString stringWithFormat:@"Goal: %d kWh", homeAppDelegate.setPower];
    [self setColorOfCurrentPowerHome];
    
        /// EVERY TIME THE VIEW LOADS FIND OUT WHAT THE CURRENT CO2 LEVEL IS AND SET THE LABEL
        // php script that returns current CO2 in PPM
        ///////////////////
    NSString *strURL9 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getLastCO2.php"];
    NSError *error9 = nil;
    NSString *returnString9;
    returnString9 = [[NSString alloc] init];
    returnString9 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL9]  encoding:NSUTF8StringEncoding error:&error9];
        //////////////////
        // convert the value into an int then set the label
        homeAppDelegate.currentCO2 = (int)[returnString9 integerValue];
    self.currentCarbonLabel.text = [NSString stringWithFormat:@"%d", homeAppDelegate.currentCO2];
    
        // EVERYTIME THE VIEW LOADS FIND OUT WHAT THE IDEAL CO2 LEVEL IS AND SET THE LABEL
        // php script that returns ideal CO2 in PPM
        ////////////////////
    NSString *strURL10 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/getIdealCO2.php"];
    NSError *error10 = nil;
    NSString *returnString10;
    returnString10 = [[NSString alloc] init];
    returnString10 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL10]  encoding:NSUTF8StringEncoding error:&error10];
        ////////////////////
        // convert the value into an int then set the label and color of label
        homeAppDelegate.setCO2 = (int)[returnString10 integerValue];
    self.idealCarbonLabel.text = [NSString stringWithFormat:@"Set: %d PPM", homeAppDelegate.setCO2];
    [self setColorOfCurrentCarbonHome];
}
/*
 timerSecondsDashboard
 This function is a timer. It is called automatically when the application starts (viewDidLoad)
 this function will call upon [self updateUI] after 60 seconds has passed
 
The use of this function is so every minute of the dashboard being open it will update the labels
 
 */
-(void)timerSecondsDashboard
{
    
    secondsDashboard = secondsDashboard +1;
    if(secondsDashboard >59)
    {
            // update the home screen every minute
        [self updateUI];
            // stop the timer. Then reset it.
        [timerDashboard invalidate];
        secondsDashboard =0;
        timerDashboard = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSecondsDashboard) userInfo:nil repeats:YES];
    }
}
-(void) viewDidLoad{
        // initiate the singleton class appdelegate
    homeAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // set the labels initially before you load anything else
    [self updateUI];
    //set content view's constraints at runtime, instead of with placeholder constraints used in IB.
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];

    //DISABLED FOR NOW. MESSES WITH SCROLLVIEW POSITIONING
    // Start the timer
      timerDashboard = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSecondsDashboard) userInfo:nil repeats:YES];
    
    //set the nav bar tint
    //only need to do this once here, and in no other controllers.
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    }
    
    // Set sound effects
    [self.tempButton setSoundNamed:@"tap-resonant.aif" forControlEvent:UIControlEventTouchDown];
    [self.humidityButton setSoundNamed:@"tap-resonant.aif" forControlEvent:UIControlEventTouchDown];
    [self.waterButton setSoundNamed:@"tap-resonant.aif" forControlEvent:UIControlEventTouchDown];
    [self.energyButton setSoundNamed:@"tap-resonant.aif" forControlEvent:UIControlEventTouchDown];
    [self.carbonButton setSoundNamed:@"tap-resonant.aif" forControlEvent:UIControlEventTouchDown];
    
}

@end