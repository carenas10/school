//
//  SimulatorViewController.m
//  2.SD.Home.Control.Simulator
//
//  Created by Jake Dawkins on 11/30/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import "SimulatorViewController.h"

@interface SimulatorViewController()
{
    NSTimer *timer;
    
}
    @property (strong, nonatomic) Sensor *tempSensor;
    @property (strong, nonatomic) Sensor *humiditySensor;
    @property (strong, nonatomic) Sensor *carbonSensor;
    @property (strong, nonatomic) Sensor *waterSensor;
    @property (strong, nonatomic) Sensor *energySensor;
    //@property (strong, nonatomic) ToggleSensor *motionSensor;
    /*
    Don't need. Hue API instead for shipped app.
    @property (strong, nonatomic) ToggleSensor *light1;
    @property (strong, nonatomic) ToggleSensor *light2;
    @property (strong, nonatomic) ToggleSensor *light3;
    @property (strong, nonatomic) ToggleSensor *light4;
    @property (strong, nonatomic) ToggleSensor *light5;
    */

    @property (weak, nonatomic) IBOutlet UIButton *tempButton;
        @property (weak, nonatomic) IBOutlet UILabel *optimalTempLabel;
    @property (weak, nonatomic) IBOutlet UIButton *humidityButton;
        @property (weak, nonatomic) IBOutlet UILabel *optimalHumidityLabel;
    @property (weak, nonatomic) IBOutlet UIButton *carbonButton;
        @property (weak, nonatomic) IBOutlet UILabel *optimalCarbonLabel;
    @property (weak, nonatomic) IBOutlet UIButton *waterButton;
        @property (weak, nonatomic) IBOutlet UILabel *optimalWaterLabel;
    @property (weak, nonatomic) IBOutlet UIButton *energyButton;
        @property (weak, nonatomic) IBOutlet UILabel *optimalEnergyLabel;
    //@property (weak, nonatomic) IBOutlet UIButton *motionButton;

    @property (nonatomic) int runCounter;

@end


@implementation SimulatorViewController

- (void)viewDidLoad {
    _runCounter = 0;
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    // initialize sensors
    _tempSensor = [[Sensor alloc]initWithName:@"Temperature" value:[NSNumber numberWithInt:0] optimal:[NSNumber numberWithInt:0] tolerance:[NSNumber numberWithInt:5] lessIsBetter:NO];
    _humiditySensor = [[Sensor alloc]initWithName:@"Humidity" value:[NSNumber numberWithInt:0] optimal:[NSNumber numberWithInt:0] tolerance:[NSNumber numberWithInt:5] lessIsBetter:NO];
    _waterSensor = [[Sensor alloc]initWithName:@"Water Usage" value:[NSNumber numberWithInt:0] optimal:[NSNumber numberWithInt:0] tolerance:[NSNumber numberWithInt:5] lessIsBetter:YES];
    _energySensor = [[Sensor alloc]initWithName:@"Energy Usage" value:[NSNumber numberWithInt:0] optimal:[NSNumber numberWithInt:0] tolerance:[NSNumber numberWithInt:5] lessIsBetter:YES];
    _carbonSensor = [[Sensor alloc]initWithName:@"CO2 Content" value:[NSNumber numberWithInt:0] optimal:[NSNumber numberWithInt:0] tolerance:[NSNumber numberWithInt:100] lessIsBetter:YES];
    //_motionSensor = [[ToggleSensor alloc]initWithName:@"Motion Sensor" isActive:NO];
    
    //fires runSimulator method every 6 seconds.
    //this is the main simulator for the house.
    timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(runSimulator) userInfo:nil repeats:YES];
    
}

-(void)runSimulator {
    [self loadFromDatabase];
    [self changeHomeState];
    [self refreshUI];
}

-(void)loadFromDatabase {
    //TEMPERATURE
    NSURLRequest *currentTempRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastTemperature.php"]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];
    NSError *errorCurrentTemp;
    NSData *dataCurrentTemp = [NSURLConnection sendSynchronousRequest:currentTempRequest returningResponse:nil error:&errorCurrentTemp];
    NSString *resultCurrentTemp = [[NSString alloc] initWithData:dataCurrentTemp encoding:NSUTF8StringEncoding];
    [_tempSensor setCurrentValue:[NSNumber numberWithFloat:[resultCurrentTemp floatValue]]];
    
    NSURLRequest *idealTempRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getIdealTemp.php"]
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
    NSError         * errorIdealTemp;
    NSData      *dataIdealTemp = [NSURLConnection sendSynchronousRequest:idealTempRequest returningResponse:nil error:&errorIdealTemp];
    NSString *resultIdealTemp = [[NSString alloc] initWithData:dataIdealTemp encoding:NSUTF8StringEncoding];
    [_tempSensor setOptimalValue: [NSNumber numberWithFloat:[resultIdealTemp floatValue]]];
    
    //HUMIDITY
    NSURLRequest *currentHumidityRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastHumidity.php"]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:60.0];
    NSError         * errorCurrentHumidity;
    NSData      *dataCurrentHumidity = [NSURLConnection sendSynchronousRequest:currentHumidityRequest returningResponse:nil error:&errorCurrentHumidity];
    NSString *resultCurrentHumidity = [[NSString alloc] initWithData:dataCurrentHumidity encoding:NSUTF8StringEncoding];
    [_humiditySensor setCurrentValue: [NSNumber numberWithFloat:[resultCurrentHumidity floatValue]]];
    
    NSURLRequest *idealHumidityRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getIdealHumidity.php"]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
    NSError         * errorIdealHumidity;
    NSData      *dataIdealHumidity = [NSURLConnection sendSynchronousRequest:idealHumidityRequest returningResponse:nil error:&errorIdealHumidity];
    NSString *resultIdealHumidity = [[NSString alloc] initWithData:dataIdealHumidity encoding:NSUTF8StringEncoding];
    [_humiditySensor setOptimalValue: [NSNumber numberWithFloat:[resultIdealHumidity floatValue]]];
    
    //WATER USAGE
    NSURLRequest *currentWaterRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastWater.php"]
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:60.0];
    NSError         * errorCurrentWater;
    NSData      *dataCurrentWater = [NSURLConnection sendSynchronousRequest:currentWaterRequest returningResponse:nil error:&errorCurrentWater];
    NSString *resultCurrentWater = [[NSString alloc] initWithData:dataCurrentWater encoding:NSUTF8StringEncoding];
    [_waterSensor setCurrentValue:[NSNumber numberWithFloat:[resultCurrentWater floatValue]]];
    
    NSURLRequest *idealWaterRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getIdealWater.php"]
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:60.0];
    NSError         * errorIdealWater;
    NSData      *dataIdealWater = [NSURLConnection sendSynchronousRequest:idealWaterRequest returningResponse:nil error:&errorIdealWater];
    NSString *resultIdealWater = [[NSString alloc] initWithData:dataIdealWater encoding:NSUTF8StringEncoding];
    
    [_waterSensor setOptimalValue:[NSNumber numberWithFloat:[resultIdealWater floatValue]]];
    
    //ENERGY USAGE
    NSURLRequest *currentPowerRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastPower.php"]
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:60.0];
    NSError         * errorCurrentPower;
    NSData      *dataCurrentPower = [NSURLConnection sendSynchronousRequest:currentPowerRequest returningResponse:nil error:&errorCurrentPower];
    NSString *resultCurrentPower = [[NSString alloc] initWithData:dataCurrentPower encoding:NSUTF8StringEncoding];
    [_energySensor setCurrentValue:[NSNumber numberWithFloat:[resultCurrentPower floatValue]]];
    
    NSURLRequest *idealPowerRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getIdealPower.php"]
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:60.0];
    NSError         * errorIdealPower;
    NSData      *dataIdealPower = [NSURLConnection sendSynchronousRequest:idealPowerRequest returningResponse:nil error:&errorIdealPower];
    NSString *resultIdealPower = [[NSString alloc] initWithData:dataIdealPower encoding:NSUTF8StringEncoding];
    [_energySensor setOptimalValue:[NSNumber numberWithFloat:[resultIdealPower floatValue]]];
    
    //CO2 CONTENT
    NSURLRequest *currentCarbonRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastCO2.php"]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
    NSError         * errorCurrentCarbon;
    NSData      *dataCurrentCarbon = [NSURLConnection sendSynchronousRequest:currentCarbonRequest returningResponse:nil error:&errorCurrentCarbon];
    NSString *resultCurrentCarbon = [[NSString alloc] initWithData:dataCurrentCarbon encoding:NSUTF8StringEncoding];
    [_carbonSensor setCurrentValue:[NSNumber numberWithInt:[resultCurrentCarbon intValue]]];
    
    NSURLRequest *idealCarbonRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getIdealCO2.php"]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
    NSError         * errorIdealCarbon;
    NSData      *dataIdealCarbon = [NSURLConnection sendSynchronousRequest:idealCarbonRequest returningResponse:nil error:&errorIdealCarbon];
    NSString *resultIdealCarbon = [[NSString alloc] initWithData:dataIdealCarbon encoding:NSUTF8StringEncoding];
    [_carbonSensor setOptimalValue:[NSNumber numberWithInt:[resultIdealCarbon intValue]]];

    //MOTION
    /*NSURLRequest *currentMotionRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://people.cs.clemson.edu/~jacosta/getLastMotion.php"]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
    NSError *errorCurrentMotion;
    NSData *dataCurrentMotion = [NSURLConnection sendSynchronousRequest:currentMotionRequest returningResponse:nil error:&errorCurrentMotion];
    NSString *resultCurrentMotion = [[NSString alloc] initWithData:dataCurrentMotion encoding:NSUTF8StringEncoding];
    if ([resultCurrentMotion isEqualToString:@"Is currently detecting motion:  1"]){
        [_motionSensor setIsActive:YES];
    }
    else [_motionSensor setIsActive:NO];
    */
    [self refreshUI];
}//loadFromDatabase

//updates each sensor in a pseudo-intelligent manner.
-(void)changeHomeState {
    //only run 10% of the time (every minute)
    //_runCounter++;
    //if(_runCounter % 10 != 0) return;
    
    //if sensor optimal, marginally or radically, else optimally
    if([_tempSensor isOptimal]){
        if (arc4random()%10 == 0) [_tempSensor radicallyUpdate];
        else [_tempSensor marginallyUpate];
    } else [_tempSensor optimallyUpdate];
    if([_humiditySensor isOptimal]){
        if (arc4random()%10 == 0) [_humiditySensor radicallyUpdate];
        else [_humiditySensor marginallyUpate];
    } else [_humiditySensor optimallyUpdate];
    if([_carbonSensor isOptimal]){
        if (arc4random()%10 == 0) [_carbonSensor radicallyUpdate];
        else [_carbonSensor marginallyUpate];
    } else [_carbonSensor optimallyUpdate];

    if (arc4random()%5 == 0) [_waterSensor marginallyUpate];
    if (arc4random()%5 == 0) [_energySensor marginallyUpate];
    
    //if (arc4random()%10 == 0) [_motionSensor toggle];
    
    //for all sensors, select an update type
    //marginally - 80%
    //radically - 10%
    //optimally - 10%
    /*
        int picker = arc4random()%10;
        if(picker <= 7){
            [_tempSensor marginallyUpate];
            [_humiditySensor marginallyUpate];
            [_carbonSensor marginallyUpate];
            [_waterSensor marginallyUpate];
            [_energySensor marginallyUpate];
            printf("marginally updated\n");
        } else if (picker > 7 && picker < 9){
            [_tempSensor radicallyUpdate];
            [_humiditySensor radicallyUpdate];
            [_carbonSensor radicallyUpdate];
            //[_waterSensor radicallyUpdate];
            //[_energySensor radicallyUpdate];
            [_motionSensor toggle];
            printf("radically updated\n");
        } else {
            [_tempSensor optimallyUpdate];
            [_humiditySensor optimallyUpdate];
            [_carbonSensor optimallyUpdate];
            //[_waterSensor optimallyUpdate];
            //[_energySensor optimallyUpdate];
            printf("optimally updated\n");
        }
     */
        //set database
    
        //TEMPERATURE
        NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertTemperature.php?currentTemp=%@", [_tempSensor getCurrentValue]];
        NSError *error = nil;
        NSString *returnString = [[NSString alloc] init];
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //HUMIDITY
        strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertHumidity.php?currHumid=%@", [_humiditySensor getCurrentValue]];
        error = nil;
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //CO2
        strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertCO2.php?currentPPM=%@", [_carbonSensor getCurrentValue]];
        error = nil;
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //WATER
        strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertWater.php?currentUseinGal=%@", [_waterSensor getCurrentValue]];
        error = nil;
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //ENERGY
        strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertPower.php?currentUseinkWh=%@", [_energySensor getCurrentValue]];
        error = nil;
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
        //MOTION
        /* if ([_motionSensor isActive]) strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertMotion.php?detectingMotion=1"];
        else strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/insertMotion.php?detectingMotion=0"];
        error = nil;
        returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
         */
        //load database
        [self loadFromDatabase];
}


-(void)refreshUI {
    UIColor *myGreen = [UIColor colorWithRed:50.0f/255.0f green:200.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    [_tempButton setTitle:[NSString stringWithFormat:@"%@",[_tempSensor getCurrentValue]] forState:UIControlStateNormal];
        [_optimalTempLabel setText:[NSString stringWithFormat:@"%@ deg",[_tempSensor getOptimalValue]]];
        if ([_tempSensor isOptimal]) [_tempButton setBackgroundColor:myGreen];
        else [_tempButton setBackgroundColor:[UIColor redColor]];
    [_humidityButton setTitle:[NSString stringWithFormat:@"%@",[_humiditySensor getCurrentValue]] forState:UIControlStateNormal];
        [_optimalHumidityLabel setText:[NSString stringWithFormat:@"%@ percent",[_humiditySensor getOptimalValue]]];
        if ([_humiditySensor isOptimal]) [_humidityButton setBackgroundColor:myGreen];
        else [_humidityButton setBackgroundColor:[UIColor redColor]];
    [_carbonButton setTitle:[NSString stringWithFormat:@"%@",[_carbonSensor getCurrentValue]] forState:UIControlStateNormal];
        [_optimalCarbonLabel setText:[NSString stringWithFormat:@"%@ ppm",[_carbonSensor getOptimalValue]]];
        if ([_carbonSensor isOptimal]) [_carbonButton setBackgroundColor:myGreen];
        else [_carbonButton setBackgroundColor:[UIColor redColor]];
    [_waterButton setTitle:[NSString stringWithFormat:@"%@",[_waterSensor getCurrentValue]] forState:UIControlStateNormal];
        [_optimalWaterLabel setText:[NSString stringWithFormat:@"%@ gal",[_waterSensor getOptimalValue]]];
        if ([_waterSensor isOptimal]) [_waterButton setBackgroundColor:myGreen];
        else [_waterButton setBackgroundColor:[UIColor redColor]];
    [_energyButton setTitle:[NSString stringWithFormat:@"%@",[_energySensor getCurrentValue]] forState:UIControlStateNormal];
        [_optimalEnergyLabel setText:[NSString stringWithFormat:@"%@ Kwh",[_energySensor getOptimalValue]]];
        if ([_energySensor isOptimal]) [_energyButton setBackgroundColor:myGreen];
        else [_energyButton setBackgroundColor:[UIColor redColor]];
    //MOTION
    /*if ([_motionSensor isActive]){
        [_motionButton setTitle:[NSString stringWithFormat:@"MOTION"] forState:UIControlStateNormal];
        [_motionButton setBackgroundColor:myGreen];
    }
    else{
        [_motionButton setTitle:[NSString stringWithFormat:@"NO MOTION"] forState:UIControlStateNormal];
        [_motionButton setBackgroundColor:[UIColor redColor]];
    }
    */
}//refreshUI

@end