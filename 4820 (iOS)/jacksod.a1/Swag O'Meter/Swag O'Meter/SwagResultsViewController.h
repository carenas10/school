//
//  SwagResultsViewController.h
//  Swag O'Meter
//
//  Created by Jake Dawkins on 9/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwagResultsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *swagLevelLabel;
@property (strong, nonatomic) IBOutlet UITextView *swagLevelDescription;
@property (strong) NSNumber *swagLevelValue;

@end
