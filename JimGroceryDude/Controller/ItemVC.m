//
//  ItemVC.m
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "ItemVC.h"
#import "Item.h"
#import "Unit.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"
#import "AppDelegate.h"

@interface ItemVC ()

@end

@implementation ItemVC
#define debug 1

#pragma mark INTERACTION
-(IBAction)done:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    [self hideKeyborad];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)hideKeyboardWhenBackgroundIsTapped{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyborad)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

-(void)hideKeyborad{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    [self.view endEditing:YES];
}

#pragma mark DELEGATE:UITextField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isEqualToString:@"New Item"]) {
            self.nameTextField.text = @"";
        }
    }
    
    if (textField == self.unitPickerTextField && _unitPickerTextField.picker) {
        [_unitPickerTextField fetch];
        [_unitPickerTextField.picker reloadAllComponents];
    }
    
    else if (textField == self.homeLocationPickerTextField && _homeLocationPickerTextField.picker){
        [_homeLocationPickerTextField fetch];
        [_homeLocationPickerTextField.picker reloadAllComponents];
    }
    else if (textField == self.shopLocationPickerTextField && _shopLocationPickerTextField){
        [_shopLocationPickerTextField fetch];
        [_shopLocationPickerTextField.picker reloadAllComponents];
    }
    
    _activeField = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
    
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        item.name = self.nameTextField.text;
    }
    else if (textField == self.quantityTextField){
        item.quantity = [NSNumber numberWithFloat:self.quantityTextField.text.floatValue];
    }
    _activeField = nil;
}
#pragma mark VIEW
-(void)refreshInterface{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
        self.nameTextField.text = item.name;
        self.quantityTextField.text = item.quantity.stringValue;
        
        self.unitPickerTextField.text = item.unit.name;
        self.unitPickerTextField.selectedObjectID = item.unit.objectID;
        
        self.homeLocationPickerTextField.text = item.locationAtHome.storedIn;
        self.homeLocationPickerTextField.selectedObjectID = item.locationAtHome.objectID;
        
        self.shopLocationPickerTextField.text = item.locationAtShop.aisle;
        self.shopLocationPickerTextField.selectedObjectID = item.locationAtShop.objectID;
    }
}

- (void)viewDidLoad {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    //
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
    self.quantityTextField.delegate = self;
    
    self.unitPickerTextField.delegate = self;
    self.unitPickerTextField.pickerDelegate = self;
    
    self.homeLocationPickerTextField.delegate = self;
    self.homeLocationPickerTextField.pickerDelegate = self;
    
    self.shopLocationPickerTextField.delegate = self;
    self.shopLocationPickerTextField.pickerDelegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    //
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    [self refreshInterface];
    if ([self.nameTextField.text isEqualToString:@"New Item"]) {
        self.nameTextField.text = @"";
        [self.nameTextField becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark DATA
-(void)ensureItemHomeLocationIsNotNull{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
        
        if (!item.locationAtHome) {
            NSFetchRequest *request = [[cdh model] fetchRequestTemplateForName:@"UnknownLocationAtHome" ];
            NSArray *fetchedObjects = [cdh.context executeFetchRequest:request error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtHome = [fetchedObjects objectAtIndex:0];
            }
            else{
                LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:locationAtHome] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtHome.storedIn = @"..UnknownLocation..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}

-(void)ensureItemShopLocationIsNotNull{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
        
        if (!item.locationAtShop) {
            NSFetchRequest *request = [[cdh model] fetchRequestTemplateForName:@"UnknownLocationAtShop" ];
            NSArray *fetchedObjects = [cdh.context executeFetchRequest:request error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtShop = [fetchedObjects objectAtIndex:0];
            }
            else{
                LocationAtShop *locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:locationAtShop] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtShop.aisle = @"..UnknownLocation..";
                item.locationAtShop = locationAtShop;
            }
        }
    }
}

#pragma mark PICKERS
-(void)selectedObjectID:(NSManagedObjectID *)objectID changedForPickerTF:(CoreDataPickerTF *)pickerTF{
    if (self.selectedID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
        
        NSError *error = nil;
        if (pickerTF == self.unitPickerTextField) {
            Unit *unit = (Unit *)[cdh.context existingObjectWithID:objectID error:&error];
            item.unit = unit;
            self.unitPickerTextField.text = item.unit.name;
        }
        else if (pickerTF == self.homeLocationPickerTextField){
            LocationAtHome *locationAtHome = (LocationAtHome *)[cdh.context existingObjectWithID:objectID error:&error];
            item.locationAtHome = locationAtHome;
            self.homeLocationPickerTextField.text = item.locationAtHome.storedIn;
        }
        else if (pickerTF == self.shopLocationPickerTextField){
            LocationAtShop *locationAtShop = (LocationAtShop *)[cdh.context existingObjectWithID:objectID error:&error];
            item.locationAtShop = locationAtShop;
            self.shopLocationPickerTextField.text = item.locationAtShop.aisle;
        }
        
        [self refreshInterface];
        if (error) {
            NSLog(@"Error selecting object on picker: %@, %@", error, error.localizedDescription);
        }
    }
}

-(void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF{
    if (self.selectedID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedID error:nil];
        
        if (pickerTF == self.unitPickerTextField) {
            item.unit = nil;
            self.unitPickerTextField.text = @"";
        }
        else if (pickerTF == self.homeLocationPickerTextField){
            item.locationAtHome = nil;
            self.homeLocationPickerTextField.text = @"";
        }
        else if (pickerTF == self.shopLocationPickerTextField){
            item.locationAtShop = nil;
            self.shopLocationPickerTextField.text = @"";
        }
        
        [self refreshInterface];
    }
}

//处理picker出现时界面元素被挡住
-(void)keyboradDidShow:(NSNotification *)n{
    //Find top of keyboard input view
    CGRect keyboardRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    //Resize scroll view
    CGRect newScrollViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, keyboardTop);
    newScrollViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    [self.scrollView setFrame:newScrollViewFrame];
    
    //Scroll to the active Text-Field
    [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
}

-(void)keyboardWillHide:(NSNotification *)n{
    CGRect defaultFrame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    //Reset ScrollView to the same size as the containing view
    [self.scrollView setFrame:defaultFrame];
    
    //Scroll to the top again
    [self.scrollView scrollRectToVisible:self.nameTextField.frame animated:YES];
}

@end
