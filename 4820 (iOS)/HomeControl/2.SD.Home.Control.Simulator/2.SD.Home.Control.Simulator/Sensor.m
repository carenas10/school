//
//  Sensor.m
//  SmartHomeSimulator
//
//  Created by Jake Dawkins on 11/24/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import "Sensor.h"

@implementation Sensor

-(Sensor *)init{
    self = [super init];
    _sensorName = @"My New Sensor";
    _currentValue = [NSNumber numberWithInt:0];
    _optimalValue = [NSNumber numberWithInt:0];
    _tolerance = [NSNumber numberWithInt:0];
    _isOptimal = YES;
    _lessIsBetter = NO;
    return self;
}//init

//create new sensor based on input
-(Sensor *)initWithName:(NSString *)sensorName value:(NSNumber *)currentValue optimal:(NSNumber *)optimalValue tolerance:(NSNumber *)tolerance lessIsBetter:(BOOL)lessIsBetter{
    
    self = [super init];
    _sensorName = sensorName;
    _currentValue = currentValue;
    _optimalValue = optimalValue;
    _tolerance = tolerance;
    _lessIsBetter = lessIsBetter;
    
    //set ifOptimal automatically
    if (!_lessIsBetter){
        if([currentValue intValue] > ([optimalValue intValue] - [tolerance intValue]) && [currentValue intValue] < ([optimalValue intValue] + [tolerance intValue])){
            _isOptimal = true;
        } else _isOptimal = false;
    }
    else{
        if([_currentValue intValue] <= [_optimalValue intValue] + [_tolerance intValue]){
            _isOptimal = true;
        }
        else _isOptimal = false;
    }
    
    return self;
}//initWithValues

//-------------------- GETTERS AND SETTERS --------------------

-(NSString *)getSensorName{
    return _sensorName;
}

-(NSNumber *)getCurrentValue{
    return _currentValue;
}

-(NSNumber *)getOptimalValue{
    return _optimalValue;
}

-(NSNumber *)getTolerance{
    return _tolerance;
}

-(BOOL)isOptimal{
    return _isOptimal;
}

-(BOOL)isLessBetter{
    return _lessIsBetter;
}

-(void)setSensorName:(NSString *)sensorName{
    _sensorName = sensorName;
}

-(void)setCurrentValue:(NSNumber *)currentValue{
    _currentValue = currentValue;

    //check tolerance again
    //set ifOptimal automatically
    if (!_lessIsBetter){
        if([_currentValue intValue] > ([_optimalValue intValue] - [_tolerance intValue]) && [_currentValue intValue] < ([_optimalValue intValue] + [_tolerance intValue])){
            _isOptimal = true;
        } else _isOptimal = false;
    }
    else{
        if([_currentValue intValue] <= [_optimalValue intValue] + [_tolerance intValue]){
            _isOptimal = true;
        }
        else _isOptimal = false;
    }
}

-(void)setOptimalValue:(NSNumber *)optimalValue{
    _optimalValue = optimalValue;
    
    //check tolerance again
    //set ifOptimal automatically
    if (!_lessIsBetter){
        if([_currentValue intValue] > ([_optimalValue intValue] - [_tolerance intValue]) && [_currentValue intValue] < ([_optimalValue intValue] + [_tolerance intValue])){
            _isOptimal = true;
        } else _isOptimal = false;
    }
    else{
        if([_currentValue intValue] <= [_optimalValue intValue] + [_tolerance intValue]){
            _isOptimal = true;
        }
        else _isOptimal = false;
    }
}

-(void)setTolerance:(NSNumber *)tolerance{
    _tolerance = tolerance;
    
    //check tolerance again
    //set ifOptimal automatically
    if (!_lessIsBetter){
        if([_currentValue intValue] > ([_optimalValue intValue] - [_tolerance intValue]) && [_currentValue intValue] < ([_optimalValue intValue] + [_tolerance intValue])){
            _isOptimal = true;
        } else _isOptimal = false;
    }
    else{
        if([_currentValue intValue] <= [_optimalValue intValue] + [_tolerance intValue]){
            _isOptimal = true;
        }
        else _isOptimal = false;
    }
}

-(void)setLessIsBetter:(BOOL)lessIsBetter{
    _lessIsBetter = lessIsBetter;
    
    //check tolerance again
    //set ifOptimal automatically
    if (!_lessIsBetter){
        if([_currentValue intValue] > ([_optimalValue intValue] - [_tolerance intValue]) && [_currentValue intValue] < ([_optimalValue intValue] + [_tolerance intValue])){
            _isOptimal = true;
        } else _isOptimal = false;
    }
    else{
        if([_currentValue intValue] <= [_optimalValue intValue] + [_tolerance intValue]){
            _isOptimal = true;
        }
        else _isOptimal = false;
    }
}

//prints a summary of all sensor information to stdout
-(void)printSensorInfo{
    printf("%s",[_sensorName UTF8String]);
    if(_isOptimal) printf("\t[GOOD]\n");
    else printf("\t[NOT GOOD]\n");
    printf("------------------------------\n");
    printf("\tCurrent Value:\t%.1f\n",[_currentValue floatValue]);
    printf("\tOptimal Value:\t%.1f\n",[_optimalValue floatValue]);
    if (!_lessIsBetter) printf("\tTolerance:\t\t%.1f\n",[_tolerance floatValue]);
    printf("------------------------------\n\n");
}

//this updates the sensor slightly, while occasionally allowing it to go out of desired range.
//changes value by up to 1/3 the tolerance.
-(void)marginallyUpate{
    int changeBy = [_tolerance intValue]; //the amount to increment/decrement the current by.
    if (changeBy == 0) changeBy = 1;
    
    //choose range to change within
    changeBy = arc4random()%changeBy; //random within change range.
    
    //chose to increment or decrement
    if (_lessIsBetter) [self setCurrentValue:[NSNumber numberWithFloat:[_currentValue floatValue] + arc4random() % 5]];
    else if (arc4random()%2 == 1) [self setCurrentValue:[NSNumber numberWithFloat:[_currentValue floatValue] + changeBy]];
    else [self setCurrentValue:[NSNumber numberWithFloat:[_currentValue floatValue] - changeBy]];
    
    //make sure the current isn't negative.
    if ([_currentValue intValue] <  0) [self setCurrentValue:[NSNumber numberWithInt:0]];
    
}//marginallyUpdate

-(void)radicallyUpdate{
    int changeBy = [_tolerance intValue];
    if (changeBy == 0) changeBy = 1;

    changeBy = arc4random()%changeBy;
    //changeBy += changeBy;
    
    //choose to increment or decrement
    if (arc4random()%2 == 1 || _lessIsBetter) [self setCurrentValue:[NSNumber numberWithFloat:[_currentValue floatValue] + changeBy]];
    else [self setCurrentValue:[NSNumber numberWithFloat:[_currentValue floatValue] - changeBy]];
    
    //make sure the current isn't negative.
    if ([_currentValue intValue] <  0) [self setCurrentValue:[NSNumber numberWithInt:0]];
}

//puts the current back within the optimal range.
-(void)optimallyUpdate{
    
    //optimal - (tolerance/2)
    [self setCurrentValue:[NSNumber numberWithFloat:[_optimalValue floatValue]-([_tolerance floatValue]/2)]];
}

@end