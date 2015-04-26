//
//  VTKTimecodeController.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 9/20/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "VTKTimecodeController.h"

@interface VTKTimecodeController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *framerateField;
@property (weak, nonatomic) IBOutlet UITextField *time1Field;
@property (weak, nonatomic) IBOutlet UITextField *time2Field;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;
@end

@implementation VTKTimecodeController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //set text field delegates for keyboard control.
    self.framerateField.delegate = self;
    self.time1Field.delegate = self;
    self.time2Field.delegate = self;
}

//upon background touches, resign keyboard.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.framerateField resignFirstResponder];
    [self.time1Field resignFirstResponder];
    [self.time2Field resignFirstResponder];
}


//calling back the keyboard with done.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _time1Field || textField == _time2Field){
        [textField resignFirstResponder];
    }
    return YES;
}

//----------------------Button Presses-------------------------------------

//Add timecodes with the given framerate
-(IBAction)addTimecodes:(id)sender
{
    //if keyboard isnt already hidden when user clicks to add, remove it.
    [self.framerateField resignFirstResponder];
    [self.time1Field resignFirstResponder];
    [self.time2Field resignFirstResponder];
    
    if (![self validFrameRate:_framerateField.text])
    {
        UIAlertView *invalidFrameRateAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Frame Rate"
                                                                    message:@"Frame rate must be positive number."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
        [invalidFrameRateAlert show];
        return;
    }//if invalid FR
    
    //if tc's are valid, convert to frames, add, convert back to tc, set label
    if ([self validTimecode:_time1Field.text] && [self validTimecode:_time2Field.text]){
        int frames1 = [[self timecodeToFrames:_time1Field.text withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]] intValue];
        int frames2 = [[self timecodeToFrames:_time2Field.text withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]] intValue];
        
        _resultsLabel.text = [self framesToTimecode:[NSNumber numberWithInt:(frames1 + frames2)] withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]];
    } else {
        UIAlertView *invalidTimeCodeAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Timecode"
                                                                       message:@"Timecode must have format hh:mm:ss;ff"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Okay"
                                                             otherButtonTitles:nil];
        [invalidTimeCodeAlert show];
        return;
    }//else
}//addTimecodes - Button

-(IBAction)subtractTimecodes:(id)sender
{
    //if keyboard isnt already hidden when user clicks to subtract, remove it.
    [self.framerateField resignFirstResponder];
    [self.time1Field resignFirstResponder];
    [self.time2Field resignFirstResponder];
    
    if (![self validFrameRate:_framerateField.text])
    {
        UIAlertView *invalidFrameRateAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Frame Rate"
                                                                       message:@"Frame rate must be positive number."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Okay"
                                                             otherButtonTitles:nil];
        [invalidFrameRateAlert show];
        return;
    }//if invalid FR
    
    //if tc's are valid, convert to frames, subtract, convert back to tc, set label
    if ([self validTimecode:_time1Field.text] && [self validTimecode:_time2Field.text]){
        int frames1 = [[self timecodeToFrames:_time1Field.text withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]] intValue];
        int frames2 = [[self timecodeToFrames:_time2Field.text withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]] intValue];
        
        //if second value larger than first, swap
        if (frames2 > frames1){
            int tmp = frames1;
            frames1=frames2;
            frames2=tmp;
        }
        
        _resultsLabel.text = [self framesToTimecode:[NSNumber numberWithInt:(frames1 - frames2)] withFrameRate:[NSNumber numberWithInt:[_framerateField.text intValue]]];
    } else {
        UIAlertView *invalidTimeCodeAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Timecode"
                                                                      message:@"Timecode must have format hh:mm:ss;ff"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [invalidTimeCodeAlert show];
        return;
    }//else
}//subtract timecodes - button

//----------------------Helper Methods-------------------------------------

//Convert time to frames
//calculations always done in frames
-(NSNumber *)timecodeToFrames:(NSString *)tc withFrameRate: (NSNumber *)fr
{
    //split string into tc elements
    NSArray *split1 = [[NSArray alloc]initWithArray:[tc componentsSeparatedByString:@":"]];
    NSArray *split2 = [[NSArray alloc]initWithArray:[[split1 lastObject] componentsSeparatedByString:@";"]];
    
    NSMutableArray *timeUnits = [[NSMutableArray alloc]init];
    for (int i=0; i<[split1 count]-1; i++){
        [timeUnits addObject:split1[i]];
    }
    [timeUnits addObjectsFromArray:split2];
    
    int frames = 3600*[fr intValue]*[timeUnits[0] intValue] +
                60*[fr intValue]*[timeUnits[1] intValue] +
                [fr intValue]*[timeUnits[2] intValue] +
                [timeUnits[3] intValue];
    return [NSNumber numberWithInt:frames];
}

//Convert frame to timecode
//calculations always done in frames, and converted back to formatted string for readability
-(NSString *)framesToTimecode:(NSNumber *)frames withFrameRate:(NSNumber *)fr
{
    int tcHours, tcMinutes, tcSeconds, tcFrames, remainder;

    tcHours = [frames intValue]/(3600*[fr intValue]);
    remainder = [frames intValue] - tcHours * (3600*[fr intValue]);

    tcMinutes = remainder / (60*[fr intValue]);
    remainder = remainder - tcMinutes * (60*[fr intValue]);
    
    tcSeconds = remainder / [fr intValue];
    
    tcFrames = remainder - tcSeconds * [fr intValue];
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d;%02d",tcHours,tcMinutes,tcSeconds,tcFrames];
}//framesToTimecode


//----------------------Validation Methods---------------------------------

//Validate Timecode
//break up into elements of tc, check number of elements then check each element for valid value (positive int)
-(BOOL)validTimecode: (NSString *)tc
{
    //check 4 strings with separator
    NSArray *split1 = [[NSArray alloc]initWithArray:[tc componentsSeparatedByString:@":"]];
    NSArray *split2 = [[NSArray alloc]initWithArray:[[split1 lastObject] componentsSeparatedByString:@";"]];

    NSMutableArray *timeUnits = [[NSMutableArray alloc]init];
    for (int i=0; i<[split1 count]-1; i++){
        [timeUnits addObject:split1[i]];
    }
    [timeUnits addObjectsFromArray:split2];
    
    //Begin Validations tests with timeUnits array
    
        //if timeunits not 4 long, invalid timecode format
        if([timeUnits count]!=4) return NO;
        
        //check to make sure all strings are int-equivalent
        for (int i=0;i<4;i++){
            NSScanner *scanner = [NSScanner scannerWithString:timeUnits[i]];
            BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
            if (!isNumeric) return NO;
        }
        
        //check for negative values. None allowed. Returns no if found.
        for (int i=0; i<4; i++){
            if([timeUnits[i] intValue]<0) return NO;
        }

    return YES; //no violations. Valid timecode
}//validTimecode

//a valid framerate must be a positive numeric value
- (BOOL)validFrameRate: (NSString *)s
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:s];
    if (!!number){
        if([number intValue]>0)
            return YES;
    }
    //return !!number; // If the string is not numeric, number will be nil
    return NO;
}

@end
