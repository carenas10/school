//
//  SwagResultsViewController.m
//  Swag O'Meter
//
//  Created by Jake Dawkins on 9/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "SwagResultsViewController.h"
#import "SwagOMeterViewController.h"

@interface SwagResultsViewController ()


@end

@implementation SwagResultsViewController

@synthesize swagLevelLabel;

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    swagLevelLabel.text = [NSString stringWithFormat:@"%.2f",[_swagLevelValue floatValue]];
    
    if([_swagLevelValue intValue] == 11){
        swagLevelLabel.text = @"∞";
    }
    
    if ([_swagLevelValue intValue] < 2){
       [_swagLevelDescription setText:@"- Literally can't even... \n- Like walks on the beach. \n- Drive a Prius. \n- Drink unsweet tea."];
    } else if ([_swagLevelValue intValue] == 2){
        [_swagLevelDescription setText:@"- Are well known by the online community. \n- Have a nice home in MineCraft."];
    } else if ([_swagLevelValue intValue] == 3){
        [_swagLevelDescription setText:@"- Are highly involved in a Pokemon forum."];
    } else if ([_swagLevelValue intValue] == 4){
        [_swagLevelDescription setText:@"- Could make money off your WOW account."];
    } else if ([_swagLevelValue intValue] == 5){
        [_swagLevelDescription setText:@"- Don't have Netflix. \n- Have homies."];
    } else if ([_swagLevelValue intValue] == 6){
        [_swagLevelDescription setText:@"- Are basic. \n- Immediately regret doing this."];
    } else if ([_swagLevelValue intValue] == 7){
        [_swagLevelDescription setText:@"- Drive a hummer... because why not?"];
    } else if ([_swagLevelValue intValue] == 8){
        [_swagLevelDescription setText:@"- Only drink scotch."];
    } else if ([_swagLevelValue intValue] == 9){
        [_swagLevelDescription setText:@"- Are your own BAE. \n- Are known by people."];
    } else if ([_swagLevelValue intValue] == 10){
        [_swagLevelDescription setText:@"- Shot someone today. \n- Started frmo the bottom. Now you're here. \n- Win."];
    } else if ([_swagLevelValue intValue] == 11){
        [_swagLevelDescription setText:@"- Need no introduction as 'The B0$$' \n- Fight bears with a jug of milk. \n- Can mute silence.\n- Don't have a shadow because it got in your way."];
    }
    
    
}

@end
