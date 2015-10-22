//
//  LocationAtShopVC.h
//  JimGroceryDude
//
//  Created by LinJK on 22/10/15.
//  Copyright (c) 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface LocationAtShopVC : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectID *selectedObjectID;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end

