//
//  VTKLoginViewController.m
//  jacksod.a4
//
//  Created by Jake Dawkins on 10/24/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTKLoginViewController.h" 

@interface VTKLoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *registerNewUsrButton;
@property (weak, nonatomic) IBOutlet UIButton *existingUserButton;


@end



@implementation VTKLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //check to see if user defaults exist
    if(! [defaults objectForKey:@"username"] || ! [defaults objectForKey:@"password"] || [[defaults objectForKey:@"username"] isEqualToString:@""] || [[defaults objectForKey:@"password"]isEqualToString:@""])
    {
        [defaults setObject:@"" forKey:@"username"];
        [defaults setObject:@"" forKey:@"password"];
        self.logoutButton.enabled = NO;
    }
    else
    {
        self.registerNewUsrButton.enabled = NO;
        self.existingUserButton.enabled = NO;
    }

    
    [defaults synchronize];

    _usernameField.text = [defaults objectForKey:@"username"];
    _passwordField.text = [defaults objectForKey:@"password"];
    
    
    //fix keyboard mess...
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
}

//upon background touches, resign keyboard.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

//calling back the keyboard with done.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField){
        [textField resignFirstResponder];
    }
    return YES;
}


-(IBAction)logoutButtonPressed:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //clear out prefs
    [defaults setObject:@"" forKey:@"username"];
    [defaults setObject:@"" forKey:@"password"];
    
    //set text fields back to blank
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    
    [defaults synchronize];
    
    //flip enable states
    //change bg colors?
    self.logoutButton.enabled = NO;
    self.registerNewUsrButton.enabled = YES;
    self.existingUserButton.enabled = YES;
    
    
}//logoutButtonPressed


-(IBAction)registerNewUser:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.usernameField.text forKey:@"username"];
    [defaults setObject:self.passwordField.text forKey:@"password"];
    
    if([self.usernameField.text isEqualToString: @""] || [self.passwordField.text isEqualToString:@""]){
        UIAlertView *emptyFieldAlert = [[UIAlertView alloc]initWithTitle:@"Empty Field!"
                                                                 message:@"The Username and Password fields cannot be left blank."
                                                                delegate:nil
                                                       cancelButtonTitle:@"Okay"
                                                       otherButtonTitles:nil];
        [emptyFieldAlert show];
    }
    else {
        [defaults synchronize]; //add username & password to prefs
        [self.navigationController popViewControllerAnimated:YES]; //return to previous screen.
    }

}//registerNewUser

//sign in existing user
-(IBAction)existingUser:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.usernameField.text forKey:@"username"];
    [defaults setObject:self.passwordField.text forKey:@"password"];
    
    if([self.usernameField.text isEqualToString: @""] || [self.passwordField.text isEqualToString:@""]){
        UIAlertView *emptyFieldAlert = [[UIAlertView alloc]initWithTitle:@"Empty Field!"
                                                                 message:@"The Username and Password fields cannot be left blank."
                                                                delegate:nil
                                                       cancelButtonTitle:@"Okay"
                                                       otherButtonTitles:nil];
        [emptyFieldAlert show];
    }
    else {
        [defaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];

    }//else
}//existingUser

@end