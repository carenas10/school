//
//  VTKAddSettingViewController.m
//  jacksod.a4
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//
// SHOULD BE EXTERNAL DB COMPLIANT

#import <Foundation/Foundation.h>
#import "VTKAddSettingViewController.h"

@implementation VTKAddSettingViewController

@synthesize videoCodecs;
@synthesize audioCodecs;

-(void)viewDidLoad{
    [super viewDidLoad];
    videoCodecs = [Database database].getVideoCodecs;
    audioCodecs = [Database database].getAudioCodecs;
    
    //text field delegate setups
    self.nameField.delegate = self;
    self.resolutionField.delegate = self;
    self.bitrateField.delegate = self;
    self.framerateField.delegate = self;
    
    // Connect data
    self.codecPicker.dataSource = self;
    self.codecPicker.delegate = self;
}

//upon background touches, resign keyboard.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nameField resignFirstResponder];
    [self.resolutionField resignFirstResponder];
    [self.bitrateField resignFirstResponder];
    [self.framerateField resignFirstResponder];
}


//calling back the keyboard with done.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField){
        [textField resignFirstResponder];
    }
    return YES;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (component==0){
        return [videoCodecs count];
    } else {
        return [audioCodecs count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return ((Codec *)[self.videoCodecs objectAtIndex:row]).codecName;
    }
    else
    {
        return ((Codec *)[self.audioCodecs objectAtIndex:row]).codecName;
    }
}

- (IBAction)saveSetting:(id)sender {
    
    VidSetting *newSetting = [[VidSetting alloc]initWithID:0 name:_nameField.text resolution:_resolutionField.text bitrate:[_bitrateField.text intValue] framerate:[_framerateField.text intValue] vidCodec:[self.codecPicker selectedRowInComponent:0] audioCodec:[self.codecPicker selectedRowInComponent:1] GID:-1 is_deleted:NO];
    [[Database database] addSetting:newSetting];
    
    
    //success!
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *settingSavedAlert = [[UIAlertView alloc]initWithTitle:@"Setting Saved!"
                                                                   message:@"Your setting has been saved. Pull down to refresh."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Okay"
                                                         otherButtonTitles:nil];
    [settingSavedAlert show];
    
}


@end