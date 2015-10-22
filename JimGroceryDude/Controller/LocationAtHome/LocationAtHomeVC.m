//
//  LocationAtHomeVC.m
//  JimGroceryDude
//
//  Created by LinJK on 22/10/15.
//  Copyright (c) 2015 LinJK. All rights reserved.
//

#import "LocationAtHomeVC.h"
#import "LocationAtHome.h"
#import "AppDelegate.h"

@implementation LocationAtHomeVC
#define debug 1

#pragma mark - VIEW
- (void)refreshInterface {
    if (self.selectedObjectID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        LocationAtHome *locationAtHome = (LocationAtHome*)[cdh.context existingObjectWithID:self.selectedObjectID
                                                                                      error:nil];
        self.nameTextField.text = locationAtHome.storedIn;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [self refreshInterface];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark - TEXTFIELD
- (void)textFieldDidEndEditing:(UITextField *)textField {
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    LocationAtHome *locationAtHome = (LocationAtHome*)[cdh.context existingObjectWithID:self.selectedObjectID
                                                                                  error:nil];
    if (textField == self.nameTextField) {
        locationAtHome.storedIn = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                            object:nil];
    }
}

#pragma mark - INTERACTION
- (IBAction)done:(id)sender {
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)hideKeyboardWhenBackgroundIsTapped {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}
- (void)hideKeyboard {
    [self.view endEditing:YES];
}
@end