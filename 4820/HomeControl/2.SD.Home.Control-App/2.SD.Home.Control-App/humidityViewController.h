//
//  humidityViewController.h
//  2.SD.Home.Control-App
//
//  Created by Joey Costa on 11/24/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JBChartView.h"

#import "JBLineChartView.h"

// JB Chart View
#import <UIKit/UIKit.h>
#import "JBChartView/JBChartView.h"
#import "JBChartView/JBBarChartView.h"
#import "JBChartView/JBLineChartView.h"

// App Delegate
#import "AppDelegate.h"



int seconds3 =0;
NSString *returnString3;

@interface humidityViewController : UIViewController<JBLineChartViewDelegate, JBLineChartViewDataSource>
{
    NSTimer *timer;
    
}
-(void)timerSeconds;
//non-admin items
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *idealLabel;

//admin items
@property (weak, nonatomic) IBOutlet UIButton *incrementButton;
@property (weak, nonatomic) IBOutlet UIButton *decrementButton;

// check for device rotation
@property (readwrite, assign) BOOL isShowingLandscapeView;
@property (readwrite, assign) BOOL previousOrientation;

@end
