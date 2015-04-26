//
//  AppDelegate.h
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/9/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

    @property (strong, nonatomic) UIWindow *window;
    @property (assign, nonatomic) Boolean isAdmin;
    @property (assign, nonatomic) float setTemperature;
    @property (assign, nonatomic) float currentTemperature;
    @property (assign, nonatomic) int setHumidity;
    @property (assign, nonatomic) int currentHumidity;
    @property (assign, nonatomic) int setWater;
    @property (assign, nonatomic) int currentWater;
    @property (assign, nonatomic) int setPower;
    @property (assign, nonatomic) int currentPower;
    @property (assign, nonatomic) int setCO2;
    @property (assign, nonatomic) int currentCO2;
    @property (assign, nonatomic) NSString *ipAddress;

@end

