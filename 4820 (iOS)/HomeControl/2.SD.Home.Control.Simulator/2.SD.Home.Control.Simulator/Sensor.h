//
//  Sensor.h
//  SmartHomeSimulator
//
//  Created by Jake Dawkins on 11/24/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

//used for temp, humidity, CO2, water, power

#include <stdlib.h>
#import <Foundation/Foundation.h>

@interface Sensor : NSObject

    @property (strong, nonatomic) NSString *sensorName;
    @property (strong, nonatomic) NSNumber *currentValue;
    @property (strong, nonatomic) NSNumber *optimalValue;
    @property (strong,nonatomic) NSNumber *tolerance;
    @property (nonatomic) BOOL isOptimal;
    @property (nonatomic) BOOL lessIsBetter;

-(Sensor *)initWithName:(NSString *)sensorName value:(NSNumber *)currentValue optimal:(NSNumber *)optimalValue tolerance:(NSNumber *)tolerance lessIsBetter:(BOOL)lessIsBetter;

    //-(void)marginallyUpdateCurrent;
    -(NSString *)getSensorName;
    -(NSNumber *)getCurrentValue;
    -(NSNumber *)getOptimalValue;
    -(NSNumber *)getTolerance;
    -(BOOL)isOptimal;
    -(BOOL)isLessBetter;

    -(void)setSensorName:(NSString *)sensorName;
    -(void)setCurrentValue:(NSNumber *)currentValue;
    -(void)setOptimalValue:(NSNumber *)optimalValue;
    -(void)setTolerance:(NSNumber *)tolerance;
    -(void)setLessIsBetter:(BOOL)lessIsBetter;

    -(void)printSensorInfo;
    -(void)marginallyUpate;
    -(void)radicallyUpdate;
    -(void)optimallyUpdate;

@end
