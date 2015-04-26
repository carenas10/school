//
//  VTKAddSettingViewController.h
//  jacksod.a2
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//
#import "database.h"

@interface VTKAddSettingViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *resolutionField;
@property (strong, nonatomic) IBOutlet UITextField *bitrateField;
@property (strong, nonatomic) IBOutlet UITextField *framerateField;
@property (strong, nonatomic) IBOutlet UIPickerView *codecPicker;


@property (nonatomic) NSArray* videoCodecs;
@property (nonatomic) NSArray* audioCodecs;


@end