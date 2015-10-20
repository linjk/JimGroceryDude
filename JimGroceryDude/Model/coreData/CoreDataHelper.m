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
    
    BOOL useMigrationManager = YES;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }
    else{
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@NO,
                                  @"journal_mode":@"DELETE"};
        NSError *error = nil;
        
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
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

#pragma mark - MIGRATION MANAGER
-(BOOL)isMigrationNecessaryForStore:(NSURL *)storeUrl{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION: source database missing.");
        }
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl options:nil error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetaData]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION: Source is already compatible.");
        }
        return NO;
    }
    
    return YES;
}

-(BOOL)migrateStore:(NSURL *)sourceStore{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    BOOL success   = NO;
    NSError *error = nil;
    
    //STEP 1 - Gather the source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore options:nil error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
    NSManagedObjectModel *destinModel = _model;
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    //STEP2 - Perform migration, assuming the mapping model isn't null
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        if (success) {
            //STEP3 - Replace the old store with the new migrated store
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                if (debug == 1) {
                    NSLog(@"Successfully migrate %@ to the current model.", sourceStore.path);
                }
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        }
        else{
            if (debug == 1) {
                NSLog(@"Failed migration. Error: %@", error);
            }
        }
    }
    else{
        if (debug == 1) {
            NSLog(@"Failed migration. Mapping model is null.");
        }
    }
    
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress*100;
            NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
            NSLog(@"%@", string);
            self.migrationVC.label.text = string;
        });
    }
}

-(BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new{
    BOOL success = NO;
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager]moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }
        else{
            if (debug == 1) {
                NSLog(@"Failed To re-home new store. Error: %@", error);
            }
        }
    }
    else{
        if (debug == 1) {
            NSLog(@"Failed To remove old store %@. Error: %@", old, error);
        }
    }
    
    return success;
}

-(void)performBackgroundManagedMigrationForStore:(NSURL *)storeURL{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    //Show migration progess view preventing the user from using the app
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController *)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:YES completion:nil];
    //Perform mifration in the background, so it doesn't freeze the UI.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
        BOOL done = [self migrateStore:storeURL];
        if (done) {
            //when migration finishes, add the newly migrated store
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                if (!_store) {
                    NSLog(@"Failed to add a migrated store. Error: %@", error);
                    abort();
                }
                else{
                    NSLog(@"Successfully added a migrated store: %@", _store);
                }
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
        }
    });
}

@end
