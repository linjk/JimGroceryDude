//
//  UnitVC.h
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface UnitVC : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectID *selectedObjectID;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;

@end
