//
//  AppDelegate.m
//  JimGroceryDude
//
//  Created by hodi on 10/19/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "AppDelegate.h"

#import "Item.h"
#import "Unit.h"

#define debug 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self cdh];
    [self demo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self cdh] saveContext];
}

-(void)demo{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    //
}

-(void)showUnitAndItemCount{
    //List how many items there are in the database
    NSFetchRequest *items = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError *itemsError = nil;
    NSArray *fecthItems = [[[self cdh] context] executeFetchRequest:items error:&itemsError];
    if (!fecthItems) {
        NSLog(@"itemsError: %@", itemsError);
    }
    else{
        NSLog(@"Found %lu item(s).", (unsigned long)[fecthItems count]);
    }
    
    //List how many units there are in the database
    NSFetchRequest *units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError *unitsError = nil;
    NSArray * fetchedUnits = [[[self cdh] context] executeFetchRequest:units error:&unitsError];
    if (!fetchedUnits) {
        NSLog(@"itemsError: %@", unitsError);
    }
    else{
        NSLog(@"Found %lu item(s).", (unsigned long)[fetchedUnits count]);
    }
}

-(CoreDataHelper *)cdh{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    if (!_coreDataHelper) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    
    return _coreDataHelper;
}

@end
