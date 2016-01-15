//
//  LoginViewController.m
//  2.SD.Home.Control-App
//
//  Created by Jake Dawkins on 11/16/14.
//  Copyright (c) 2014 Thunder Ducklings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerNewUserButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;



@end


@implementation LoginViewController
AppDelegate *loginAppDelegate;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    loginAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check to see if user defaults exist
    if(! [defaults objectForKey:@"username"] || ![defaults objectForKey:@"password"] || [[defaults objectForKey:@"username"] isEqualToString:@""] || [[defaults objectForKey:@"password"]isEqualToString:@""]) {
        //not logged in
        [defaults setObject:@"" forKey:@"username"];
        [defaults setObject:@"" forKey:@"password"];
        loginAppDelegate.isAdmin = false;
    } else {
        //defaults exist
        //check is user is admin
        NSString *strURL1 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/adminLogin.php?username=%@&password=%@", [defaults objectForKey:@"username"], [defaults objectForKey:@"password"]];
        NSError *error1 = nil;
        NSString *returnString1;
        returnString1 = [[NSString alloc] init];
        returnString1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL1]  encoding:NSUTF8StringEncoding error:&error1];
        
        int isAdmin = (int)[returnString1 integerValue];
        if (isAdmin == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in as Admin"
                                                            message:[NSString stringWithFormat:@"You have logged in as %@. You can now control the house.",[defaults objectForKey:@"username"] ]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            loginAppDelegate.isAdmin = true;
        }
        else if(isAdmin==0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful Login"
                                                            message:@"The account information was not found, or is not an admin."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            loginAppDelegate.isAdmin = false;
            [self clearTextFields];
        }
    }
    
    [defaults synchronize];
    
//    _usernameField.text = [defaults objectForKey:@"username"];
//    _passwordField.text = [defaults objectForKey:@"password"];
    
    //set text field delegates for returning the keyboard
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self showLogoutButton];

}

-(void)clearTextFields
{
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    [self showLogoutButton];
}

-(void)showLogoutButton
{
    if(loginAppDelegate.isAdmin)
    {
        self.registerNewUserButton.hidden = false;
        self.loginButton.hidden = true;
        self.logoutButton.hidden = false;
    } else {
        self.registerNewUserButton.hidden = true;
        self.loginButton.hidden = false;
        self.logoutButton.hidden = true;
    }
}


- (void)keyboardWasShown:(NSNotification *)notification
{
    /*
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
    }*/
}
- (IBAction)registerNewUser:(id)sender {
    bool registerUser = false;
    if (loginAppDelegate.isAdmin) {
            //you can add another user
        
        if(self.usernameField.text == NULL || self.passwordField.text== NULL)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to add user"
                                                            message:@"The username or password field is empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
                // first check to see if the user is already in the database
           
                ///////////////
            NSString *strURL = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/adminLogin.php?username=%@&password=%@", self.usernameField.text, self.passwordField.text];
            NSError *error = nil;
            NSString *returnString;
            returnString = [[NSString alloc] init];
            returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL]  encoding:NSUTF8StringEncoding error:&error];
            
            
                ///////////
            registerUser = true;
            
            
            if([returnString isEqual:@"1"]||[returnString isEqual:@"0"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate User"
                                                                message:@"The user already exists."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self clearTextFields];
                registerUser = false;
            }
            
            if(registerUser)
            {
                
                
                    ////////////
                
                NSString *strURL3 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/addAdmin.php?username=%@&password=%@", self.usernameField.text, self.passwordField.text];
                NSError *error3 = nil;
                NSString *returnString3;
                returnString3 = [[NSString alloc] init];
                returnString3 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL3]  encoding:NSUTF8StringEncoding error:&error3];
                
                    // NSLog(@"%@", returnString3);  // =)
                
                    ////////////
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succesful Admin Created"
                                                                message:@"The new account created will be able to now login to the app as admin."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self clearTextFields];
            }
            
        }
        
    }
    else
    {
            // because your not a admin you cannot add a admin
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to add user"
                                                        message:@"You must be signed into an admin account to add a new admin."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self clearTextFields];
    }
    
    

}
- (IBAction)loginButton:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strURL1 = [NSString stringWithFormat:@"http://people.cs.clemson.edu/~jacosta/adminLogin.php?username=%@&password=%@", self.usernameField.text, self.passwordField.text];
    NSError *error1 = nil;
    NSString *returnString1;
    returnString1 = [[NSString alloc] init];
    returnString1 = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL1]  encoding:NSUTF8StringEncoding error:&error1];
    
    int isAdmin = (int)[returnString1 integerValue];

    if(isAdmin==1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in as Admin"
                                                        message:@"You have logged in as an admin. You can now control the house."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
            // NSLog(@"YOU ARE THE ADMIN: %d", (bool)[strResult isEqual:@"1"]);
        loginAppDelegate.isAdmin = TRUE;
        
        [defaults setObject:self.usernameField.text forKey:@"username"];
        [defaults setObject:self.passwordField.text forKey:@"password"];
        
        [self clearTextFields];

    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful Login"
                                                        message:@"The account information was not found."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        loginAppDelegate.isAdmin = false;
        [self clearTextFields];
    }
    
    [self showLogoutButton];
}

-(IBAction)logoutButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //clear out prefs
    [defaults setObject:@"" forKey:@"username"];
    [defaults setObject:@"" forKey:@"password"];
    
    [self clearTextFields];
    
    loginAppDelegate.isAdmin = false;
    
    [self showLogoutButton];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    /*
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
    */
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



@end