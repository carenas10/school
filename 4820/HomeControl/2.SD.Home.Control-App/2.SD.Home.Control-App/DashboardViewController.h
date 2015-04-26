//
//  DashboardViewController.h
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/16/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

// attributions
// scrollview - http://spin.atomicobject.com/2014/03/05/uiscrollview-autolayout-ios/
// bar tint - https://stackoverflow.com/questions/18929864/how-to-change-navigation-bar-color-in-ios-7
// prototype cells http://www.colejoplin.com/2012/09/28/ios-tutorial-basics-of-table-views-and-prototype-cells-in-storyboards/

#import <UIKit/UIKit.h>
int secondsDashboard =0;
NSString *returnStringDashboard;

@interface DashboardViewController : UIViewController 
{
    NSTimer *timerDashboard;
    
}
-(void)timerSecondsDashboard;
//dashboard outlets

//Temperature
@property (weak, nonatomic) IBOutlet UIButton *tempButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealTempLabel;

//Humidity
@property (weak, nonatomic) IBOutlet UIButton *humidityButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHumidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealHumidityLabel;

//Water
@property (weak, nonatomic) IBOutlet UIButton *waterButton;
@property (weak, nonatomic) IBOutlet UILabel *currentWaterLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealWaterLabel;

//Energy
@property (weak, nonatomic) IBOutlet UIButton *energyButton;
@property (weak, nonatomic) IBOutlet UILabel *currentEnergyLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealEnergyLabel;

//Humidity
@property (weak, nonatomic) IBOutlet UIButton *carbonButton;
@property (weak, nonatomic) IBOutlet UILabel *currentCarbonLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealCarbonLabel;

//Lights
@property (weak, nonatomic) IBOutlet UIButton *lightsButton;





@end