//
//  UnitVC.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "UnitVC.h"
#import "Unit.h"
#import "AppDelegate.h"

@interface UnitVC ()

@end

@implementation UnitVC
#define debug 1

#pragma mark VIEW
-(void)refreshInterface{
    if (self.selectedObjectID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Unit *unit = (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        self.nameTextField.text = unit.name;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    [self hideKeyboardWhenBackgroundIsTapped];
    [self.nameTextField becomeFirstResponder];
    self.nameTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshInterface];
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TEXTFIELD
-(void)textFieldDidEndEditing:(UITextField *)textField{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Unit *unit = (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
    if (textField == self.nameTextField) {
        unit.name = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }
}
#pragma mark INTERACTION
-(IBAction)done:(id)sender{
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboardWhenBackgroundIsTapped{
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

@end
