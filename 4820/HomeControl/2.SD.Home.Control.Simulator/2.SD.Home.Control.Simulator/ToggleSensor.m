//
//  toggleSensor.m
//  SmartHomeSimulator
//
//  Created by Jake Dawkins on 11/25/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import "ToggleSensor.h"

@implementation ToggleSensor

@synthesize isActive;

-(ToggleSensor *)initWithName:(NSString *)sensorName isActive:(BOOL)state{
   self =  [super init];
    _sensorName = sensorName;
    isActive = state;
    return self;
}

//---------------------- GETTERS & SETTERS --------------------------

-(NSString *)getSensorName{
    return _sensorName;
}

-(BOOL)isActive{
    return isActive;
}

-(void)setSensorName:(NSString *)sensorName{
    _sensorName = sensorName;
}

-(void)setIsActive:(BOOL)state{
    isActive = state;
}

-(void)printSensorInfo{
    printf("%s\n",[_sensorName UTF8String]);
    printf("------------------------------\n");
    if(self.isActive) printf("Status:\tON\n");
    else printf("Status:\t OFF\n");
    printf("------------------------------\n\n");
}

-(void)toggle{
    self.isActive = !self.isActive;
}

@end