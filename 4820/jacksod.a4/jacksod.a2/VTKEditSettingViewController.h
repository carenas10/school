//
//  VTKEditSettingViewController.h
//  jacksod.a2
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import<UIKit/UIKit.h>
#import "database.h"
#import <Foundation/Foundation.h>



@interface VTKEditSettingViewController:UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *resolutionField;
@property (weak, nonatomic) IBOutlet UITextField *bitrateField;
@property (weak, nonatomic) IBOutlet UITextField *framerateField;
@property (strong, nonatomic) IBOutlet UIPickerView *codecPicker;

@property (strong,nonatomic) VidSetting *settingToEdit;
@property (nonatomic) NSArray* videoCodecs;
@property (nonatomic) NSArray* audioCodecs;

@end