//
//  CoreDataHelper.m
//  JimGroceryDude
//
//  Created by hodi on 10/19/15.
//  Copyright © 2015 LinJK. All rights reserved.

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString *storeFilename = @"JimGroceryDude.sqlite";

#pragma mark - PATHS
-(NSString *)applicationDocumentsDirectory{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(NSURL *)applicationStoresDirectory{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManeger = [NSFileManager defaultManager];
    if (![fileManeger fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManeger createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (debug == 1) {
                NSLog(@"Successfully created Stores directory.");
            }
        }
        else{
            NSLog(@"Failed to create Stores directory: %@", error);
        }
    }
    return storesDirectory;
}

-(NSURL *)storeURL{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP
-(id)init{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _model       = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context     = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_context setPersistentStoreCoordinator:_coordinator];
    
    return self;
}

-(void)loadStore{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    
    NSError *error = nil;

    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
    if (!_store) {
        NSLog(@"Failed to add store. Error: %@", error);
        abort();
    }
    else{
        if (debug == 1) {
            NSLog(@"Successfully added store: %@", _store);
        }
    }
}

-(void)setupCoreData{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    [self loadStore];
}

#pragma mark - SAVING

-(void)saveContext{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store.");
        }
        else{
            NSLog(@"Failed to save _context: %@", error);
        }
    }
    else{
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
}

@end
