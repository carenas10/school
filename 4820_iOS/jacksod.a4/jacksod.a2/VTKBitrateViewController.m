//
//  VTKBitrateViewController.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/20/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKBitrateViewController.h"

@interface VTKBitrateViewController ()
@property (weak, nonatomic) IBOutlet UITextField *durationField1;
@property (weak, nonatomic) IBOutlet UITextField *bitrateField;
@property (weak, nonatomic) IBOutlet UIButton *calculateFileSizeButton;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;

@property (weak, nonatomic) IBOutlet UITextField *durationField2;
@property (weak, nonatomic) IBOutlet UITextField *fileSizeField;
@property (weak, nonatomic) IBOutlet UIButton *calculateBitrateButton;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fileSizeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIScrollView *theScrollView;
@end

@implementation VTKBitrateViewController
@synthesize theScrollView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set keyboard delegates
    self.durationField1.delegate = self;
    self.bitrateField.delegate = self;
    self.durationField2.delegate = self;
    self.fileSizeField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
    
    //determine what the active field is.
    UITextField *activeTextField;
    if (_durationField1.isFirstResponder){
        activeTextField = _durationField1;
    } else if (_durationField2.isFirstResponder){
        activeTextField = _durationField2;
    } else if (_bitrateField.isFirstResponder){
        activeTextField = _bitrateField;
    } else if (_fileSizeField.isFirstResponder){
        activeTextField = _fileSizeField;
    }
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeTextField.frame.origin.y - (keyboardSize.height-15));
        [theScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;

}

//upon background touches, resign keyboard.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.durationField1 resignFirstResponder];
    [self.bitrateField resignFirstResponder];
    [self.durationField2 resignFirstResponder];
    [self.fileSizeField resignFirstResponder];
}

//calling back the keyboard with done.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField){
        [textField resignFirstResponder];
    }
    return YES;
}

//-----------------------Primary Methods------------------------------
-(IBAction)calculateFileSize:(id)sender
{
    [self.durationField1 resignFirstResponder];
    [self.bitrateField resignFirstResponder];
    [self.durationField2 resignFirstResponder];
    [self.fileSizeField resignFirstResponder];
    
    //validate timecode before processing
    if(![self validTimecode:_durationField1.text]){
        UIAlertView *invalidTimecodeAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Timecode"
                                                                       message:@"Timecode must be in form hh:mm:ss"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Okay"
                                                             otherButtonTitles:nil];
        [invalidTimecodeAlert show];
        return;
    }
    
    if(![self validBitrate:_bitrateField.text]){
        UIAlertView *invalidBitrateAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Bitrate"
                                                                       message:@"Bitrate must be a Nonnegative number."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Okay"
                                                             otherButtonTitles:nil];
        [invalidBitrateAlert show];
        return;
    }
    int seconds = [[self timecodeToSeconds:_durationField1.text]intValue];
    float mbps = [_bitrateField.text floatValue];
    float fileSize = (seconds * mbps) / 8; //div by 8 for bit->byte
    
    if(fileSize > 1000){
        _fileSizeLabel.text = [NSString stringWithFormat:@"%.3f GB",fileSize/1000];
    } else{
        _fileSizeLabel.text = [NSString stringWithFormat:@"%.2f MB",fileSize];
    }
}//calculateFileSize

-(IBAction)calculateBitrate:(id)sender
{
    [self.durationField1 resignFirstResponder];
    [self.bitrateField resignFirstResponder];
    [self.durationField2 resignFirstResponder];
    [self.fileSizeField resignFirstResponder];

    //validate timecode before processing
    if(![self validTimecode:_durationField2.text]){
        UIAlertView *invalidTimecodeAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Timecode"
                                                                      message:@"Timecode must be in form hh:mm:ss"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [invalidTimecodeAlert show];
        return;
    }//timecode validation
    
    if(![self validFileSize:_fileSizeField.text]){
        UIAlertView *invalidFileSizeAlert = [[UIAlertView alloc]initWithTitle:@"Invalid File Size"
                                                                      message:@"File suze must be a positive number."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [invalidFileSizeAlert show];
    }//file size validation
    
    int seconds = [[self timecodeToSeconds:_durationField2.text]intValue];
    float filesize = [_fileSizeField.text floatValue]; // in MB
    if (_fileSizeSegmentedControl.selectedSegmentIndex == 1){ //if GB
        filesize = filesize*1000;
    }
    
    float mbps = (filesize * 8) / seconds;
    if (mbps<1){
        _bitrateLabel.text = [NSString stringWithFormat:@"%.1f Kbit/sec",mbps*1000];
    } else {
        _bitrateLabel.text = [NSString stringWithFormat:@"%.3f Mbit/sec",mbps];
    }
}

//------------------------Helper Methods-------------------------------
-(NSNumber *)timecodeToSeconds:(NSString *)tc
{
    NSArray *timeUnits = [[NSArray alloc]initWithArray:[tc componentsSeparatedByString:@":"]];
    int seconds = [timeUnits[0] intValue]*3600 + [timeUnits[1] intValue]*60 + [timeUnits[2] intValue];
    return [NSNumber numberWithInt:seconds];
}//timecodeToSeconds


//-------------------------Validation Methods---------------------------

//Validate Timecode
//break up into elements of tc, check number of elements then check each element for valid value (positive int)
-(BOOL)validTimecode: (NSString *)tc
{
    //check 4 strings with separator
    NSArray *timeUnits = [[NSArray alloc]initWithArray:[tc componentsSeparatedByString:@":"]];
    
    //Begin Validations tests with timeUnits array
    
    //if timeunits not 4 long, invalid timecode format
    if([timeUnits count]!=3) return NO;
    
    //check to make sure all strings are int-equivalent
    for (int i=0;i<3;i++){
        NSScanner *scanner = [NSScanner scannerWithString:timeUnits[i]];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        if (!isNumeric) return NO;
    }
    
    //check for negative values. None allowed. Returns no if found.
    for (int i=0; i<3; i++){
        if([timeUnits[i] intValue]<0) return NO;
    }
    
    return YES; //no violations. Valid timecode
}//validTimecode

//a valid framerate must be a positive numeric value
- (BOOL)validBitrate: (NSString *)s
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:s];
    if (!!number){
        if([number intValue]>=0)
            return YES;
    }
   //return !!number; // If the string is not numeric, number will be nil
    return NO;
}

-(BOOL)validFileSize: (NSString *)s
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:s];
    if (!!number){
        if([number intValue]>=0)
            return YES;
    }
    //return !!number; // If the string is not numeric, number will be nil
    return NO;
}

@end
