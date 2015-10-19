//
//  AppDelegate.h
//  JimGroceryDude
//
//  Created by hodi on 10/19/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;


@end

