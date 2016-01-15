//
//  SwagOMeterViewController.m
//  Swag O'Meter
//
//  Created by Jake Dawkins on 9/4/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//


#import "SwagOMeterViewController.h"
#import "SwagLevel.h"
#import "SwagResultsViewController.h"


@interface SwagOMeterViewController ()
@property (weak, nonatomic) IBOutlet UIButton *swagButton;
@property (weak, nonatomic) IBOutlet UITextField *fName;
@property (weak, nonatomic) IBOutlet UITextField *lName;
@property (strong) NSNumber *swagLevelPassValue;

@end

@implementation SwagOMeterViewController

- (IBAction)touchSwagButton:(id)sender
{
    //names must be over 2 characters. Show alert box if too short.
    if([[_fName text] length]<2 || [[_lName text]length]<2){
    UIAlertView *namesTooShortAlert = [[UIAlertView alloc]initWithTitle:@"Name too Short!"
                                                                message:@"All names  (first and last) must be 2 characters or longer"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Aw, Okay"
                                                      otherButtonTitles:nil];
    [namesTooShortAlert show];
    return;
    }
    
    NSString *string = [NSString stringWithFormat:@"%@%@",_fName.text,_lName.text];
    _swagLevelPassValue = [NSNumber numberWithFloat:[[SwagLevel getSwagLevel:string] floatValue] * 10];
}

//method called before segue happens. Use to pass info to next VC
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToSwagResults"]) {
        SwagResultsViewController *destination = [segue destinationViewController];
        destination.swagLevelValue =_swagLevelPassValue;
    }
}

//calling back the keyboard with done.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _fName || textField == _lName){
        [textField resignFirstResponder];
    }
    return YES;
}

//----------------------- Keyboard Sliding ------------------------------

 
 /*
 // Call this method somewhere in your view controller setup code.
 - (void)registerForKeyboardNotifications
 {
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWasShown:)
 name:UIKeyboardDidShowNotification object:nil];
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillBeHidden:)
 name:UIKeyboardWillHideNotification object:nil];
 
 }
 
 // Called when the UIKeyboardDidShowNotification is sent.
 - (void)keyboardWasShown:(NSNotification*)aNotification
 {
 NSDictionary* info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
 UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
 scrollView.contentInset = contentInsets;
 scrollView.scrollIndicatorInsets = contentInsets;
 
 // If active text field is hidden by keyboard, scroll it so it's visible
 // Your app might not need or want this behavior.
 CGRect aRect = self.view.frame;
 aRect.size.height -= kbSize.height;
 if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
 [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
 }
 }
 
 // Called when the UIKeyboardWillHideNotification is sent
 - (void)keyboardWillBeHidden:(NSNotification*)aNotification
 {
 UIEdgeInsets contentInsets = UIEdgeInsetsZero;
 scrollView.contentInset = contentInsets;
 scrollView.scrollIndicatorInsets = contentInsets;
 }
 
 */



//------------------------VC Lifecycle Methods---------------------------

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];   //it hides
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

@end
