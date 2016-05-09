//
//  LightingViewController.h
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/16/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *lightsName;
@property (strong, nonatomic) NSMutableArray *lightStates;

@end