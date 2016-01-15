//
//  SwagOMeterViewController.h
//  Swag O'Meter
//
//  Created by Jake Dawkins on 9/4/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwagOMeterViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSNumber *swagLevel;
@end
