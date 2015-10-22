//
//  ItemVC.h
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "UnitPickerTF.h"
#import "LocationAtHomePickerTF.h"
#import "LocationAtShopPickerTF.h"

@interface ItemVC : UIViewController <UITextFieldDelegate, CoreDataPickerTFDelegate>

@property (nonatomic, strong) NSManagedObjectID *selectedID;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;

@property (strong, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtHomePickerTF *homeLocationPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtShopPickerTF *shopLocationPickerTextField;

@property (nonatomic, strong) IBOutlet UITextField *activeField;

@end
