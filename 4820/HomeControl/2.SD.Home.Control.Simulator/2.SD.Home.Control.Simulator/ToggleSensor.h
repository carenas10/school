//
//  toggleSensor.h
//  SmartHomeSimulator
//
//  Created by Jake Dawkins on 11/25/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

//used for lighting/motion

#include <stdlib.h>
#import <Foundation/Foundation.h>

@interface ToggleSensor : NSObject
    @property (strong, nonatomic) NSString *sensorName;
    @property (nonatomic) BOOL isActive;

-(ToggleSensor *)initWithName:(NSString *)sensorName isActive:(BOOL)isActive;

    -(NSString *)getSensorName;
    -(BOOL)isActive;

    -(void)setSensorName:(NSString *)sensorName;
    -(void)setIsActive:(BOOL)isActive;

    -(void)printSensorInfo;
    -(void)toggle;

@end
