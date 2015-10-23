//
//  CoreDataHelper.m
//  JimGroceryDude
//
//  Created by hodi on 10/19/15.
//  Copyright © 2015 LinJK. All rights reserved.

#import "CoreDataHelper.h"
#import "CoreDataImporter.h"

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
    
    //导入默认数据的上下文
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setPersistentStoreCoordinator:_coordinator];
        [_importContext setUndoManager:nil];//default on iOS
    }];
    
    return self;
}

-(void)loadStore{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }
    else{
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@YES,
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

-(void)setDefaultDataStoreAsInitialStore{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.storeURL.path]) {
        NSURL *defaultDataURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"sqlite"]];
        NSError *error = nil;
        if (![fileManager copyItemAtURL:defaultDataURL toURL:self.storeURL error:&error]) {
            NSLog(@"DefaultData.sqlite copy FAIL: %@", error.localizedDescription);
        }
        else{
            NSLog(@"A copy of DefaultData.sqlite was set as the initial store for %@", self.storeURL.path);
        }
    }
}

-(void)setupCoreData{
    if (debug == 1){
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    [self setDefaultDataStoreAsInitialStore];
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];
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
            [self showValidationError:error];
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
    //Perform migration in the background, so it doesn't freeze the UI.
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

#pragma mark - VALIDATION ERROR HANDLING
-(void)showValidationError:(NSError *)anError{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil; //holds all errors
        NSString *txt = @"";   //The error message text of the alert
        
        //populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }
        else{
            errors = [NSArray arrayWithObject:anError];
        }
        //Display the error(s)
        if (errors && errors.count>0) {
            //Build error message text based on errors.
            for (NSError *error in errors) {
                NSString *entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString *property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error code %li)\n\n", entity, property, (long)error.code];
                        break;
                    
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:@"the '%@' relationShip count is too small (Code %li)", property, (long)error.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:@"Unhandled error code %li in showValidationError methos.", (long)error.code];
                        break;
                }
            }
            //display alert message
            [[[UIAlertView alloc] initWithTitle:@"Validation Error" message:txt delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }
}

#pragma mark DEFAULT DATA IMPORT
-(BOOL)isDefaultDataAlreadyImpotedForStoreWithURL:(NSURL *)url ofType:(NSString *)type{
    NSError *error;
    NSDictionary *dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:url error:&error];
    
    if (error) {
        NSLog(@"Error reading persistent store metadata: %@", error.localizedDescription);
    }
    else{
        NSNumber *defaultDataAlreadyImported = [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been imported.");
            return NO;
        }
    }
    if (debug == 1) {
        NSLog(@"Default Data HAS already been imported.");
    }
    return YES;
}

-(void)checkIfDefaultDataNeedsImporting{
    if (![self isDefaultDataAlreadyImpotedForStoreWithURL:[self storeURL] ofType:NSSQLiteStoreType]) {
        self.importAlertView = [[UIAlertView alloc] initWithTitle:@"Import Default Data?" message:@"If you've never used JimGroceryDude before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap 'Cancel' to skip the import, especially if you've done this before on other devices." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil];
        [self.importAlertView show];
    }
}

-(void)importFromXML:(NSURL *)url{
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"*** Start Parse OF %@ ***", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"*** End Parse OF %@   ***", url.path);
}
/**
 *  防止重复导入数据处理
 */
-(void)setDefaultDataAsImportedForStore:(NSPersistentStore *)aStore{
    //get metadata dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    if (debug == 1) {
        NSLog(@"__Store MetaData BEFORE changes__ \n %@", dictionary);
    }
    //edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    //set metadata dictionary
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    
    if (debug == 1) {
        NSLog(@"__Store MetaData AFTER changes__ \n %@", dictionary);
    }
}
#pragma mark DELEGATE: UIAlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == self.importAlertView) {
        if (buttonIndex == 1) {
            NSLog(@"Default data imported approved by user.");
            [_importContext performBlock:^{
                //XML import
                [self importFromXML:[[NSBundle mainBundle] URLForResource:@"DefaultData" withExtension:@"xml"]];
            }];
        }
        else{
            NSLog(@"Default DAta Import Cancelled bu User.");
        }
        [self setDefaultDataAsImportedForStore:_store];
    }
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION
-(NSDictionary *)selectedUniqueAttributes{
    NSMutableArray *entities = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    //Select an attributes in each entity for uniqueness
    [entities addObject:@"Item"];   [attributes addObject:@"name"];
    [entities addObject:@"Unit"];   [attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"];  [attributes addObject:@"storedIn"];
    [entities addObject:@"LocationAtShop"];  [attributes addObject:@"aisle"];
    
    NSDictionary *dicrtionary = [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
    
    return dicrtionary;
}

#pragma mark DELEGATE: NSXMLParser
-(void)parser:(NSXMLParser *)parser parserErrorOccured:(NSError *)parserError{
    if (debug == 1) {
        NSLog(@"Parser Error: %@", parserError.localizedDescription);
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    [self.importContext performBlockAndWait:^{
        //STEP 1: Process only the 'item' element in the XML file
        if ([elementName isEqualToString:@"item"]) {
            //STEP 2: Prepare the Core Data Importer
            CoreDataImporter *impoter = [[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
            
            //STEP 3a: Insert a unique 'Item' object
            NSManagedObject *item = [impoter insertBasicObjectInTargetEntity:@"Item" targetEntityAttribute:@"name" sourceXMLAttribute:@"name" attributeDict:attributeDict context:_importContext];
            //STEP 3b: Insert a unique 'Unit' object
            NSManagedObject *unit = [impoter insertBasicObjectInTargetEntity:@"Unit" targetEntityAttribute:@"name" sourceXMLAttribute:@"unit" attributeDict:attributeDict context:_importContext];
            //STEP 3c: Insert a unique 'LocationAtHome' object
            NSManagedObject *locationAtHome = [impoter insertBasicObjectInTargetEntity:@"LocationAtHome" targetEntityAttribute:@"storedIn" sourceXMLAttribute:@"locationathome" attributeDict:attributeDict context:_importContext];
            //STEP 3d: Insert a unique 'LocationAtShop' object
            NSManagedObject *locationAtShop = [impoter insertBasicObjectInTargetEntity:@"LocationAtShop" targetEntityAttribute:@"aisle" sourceXMLAttribute:@"locationatshop" attributeDict:attributeDict context:_importContext];
            //STEP 4: Manally add extra attribute values.
            [item setValue:@NO forKey:@"listed"];
            //STEP 5: Create relationShips
            [item setValue:unit forKey:@"unit"];
            [item setValue:locationAtHome forKey:@"locationAtHome"];
            [item setValue:locationAtShop forKey:@"locationAtShop"];
            
            //STEP 6: Save new objects to the persistent store
            [CoreDataImporter saveContext:_importContext];
            
            //STEP 7: Turn objects into faults to save memory.
            [_importContext refreshObject:item mergeChanges:NO];
            [_importContext refreshObject:unit mergeChanges:NO];
            [_importContext refreshObject:locationAtHome mergeChanges:NO];
            [_importContext refreshObject:locationAtShop mergeChanges:NO];
        }
    }];
}
@end
