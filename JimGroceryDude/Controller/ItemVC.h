//
//  ItemVC.h
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface ItemVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectID *selectedID;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;

@end
