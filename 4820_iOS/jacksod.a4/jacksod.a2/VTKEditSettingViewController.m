//
//  VTKEditSettingViewController.m
//  jacksod.a4
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//
// SHOULD BE EXTERNAL DB COMPLIANT

#import "VTKEditSettingViewController.h"


@implementation VTKEditSettingViewController

@synthesize settingToEdit;
@synthesize videoCodecs;
@synthesize audioCodecs;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}

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
    
    _nameField.text = settingToEdit.name;
    
    _resolutionField.text = settingToEdit.resolution;
    
    _bitrateField.text = [NSString stringWithFormat:@"%d",settingToEdit.bitrate];
    _framerateField.text = [NSString stringWithFormat:@"%d",settingToEdit.framerate];
    [_codecPicker selectRow:settingToEdit.vidCodec inComponent:0 animated:NO];
    [_codecPicker selectRow:settingToEdit.audioCodec inComponent:1 animated:NO];
    
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
    if([[Database database] updateSetting:settingToEdit.setting_ID name:_nameField.text resolution:_resolutionField.text bitrate:[_bitrateField.text intValue] framerate:[_framerateField.text intValue] vidCodec:[self.codecPicker selectedRowInComponent:0] audioCodec:[self.codecPicker selectedRowInComponent:1] GID:settingToEdit.GID is_deleted:settingToEdit.is_deleted]){
    
    //pop back to table
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *settingSavedAlert = [[UIAlertView alloc]initWithTitle:@"Setting Saved!"
                                                               message:@"Your setting has been Updated! Pull down to refresh."
                                                              delegate:nil
                                                     cancelButtonTitle:@"Okay"
                                                     otherButtonTitles:nil];
    [settingSavedAlert show];
        
    }
    
    //success!

    
}





@end