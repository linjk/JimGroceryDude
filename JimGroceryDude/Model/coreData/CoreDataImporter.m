//
//  CoreDataImporter.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "CoreDataImporter.h"

@implementation CoreDataImporter
#define debug 1

+(void)saveContext:(NSManagedObjectContext *)context{
    [context performBlockAndWait:^{
        if ([context hasChanges]) {
            NSError *error = nil;
            if ([context save:&error]) {
                NSLog(@"CoreDataImporter SAVED changes from context ro persistent store.");
            }
            else{
                NSLog(@"CoreDataImporter Failed to save changes from context ro persistent store: %@", error);
            }
        }
        else{
            NSLog(@"CoreDataImporter SKIPPED saving context as there are no changes.");
        }
    }];
}

-(CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes{
    if (self = [super init]) {
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        
        if (self.entitiesWithUniqueAttributes) {
            return self;
        }
        else{
            NSLog(@"Failed to initialize CoreDataImporter: entitiesWithUniqueAttributes is nil");
            return nil;
        }
    }
    
    return nil;
}

-(NSString *)uniqueAttributesForEntity:(NSString *)entity{
    return [self.entitiesWithUniqueAttributes valueForKey:entity];
    
    return nil;
}

-(NSManagedObject *)existingObjectInContext:(NSManagedObjectContext *)context forEntity:(NSString *)entity withUniqueAttributeValue:(NSString *)uniqueAttributeValue{
    NSString *uniqueAttribute = [self uniqueAttributesForEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttribute, uniqueAttributeValue];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSError *error = nil;
    NSArray *fetchRequestResults = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    if (fetchRequestResults.count == 0) {
        return nil;
    }
    
    return fetchRequestResults.lastObject;
}

-(NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeValue:(NSString *)uniqueAttributeValue attributeValues:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context{
    NSString *uniqqueAttribute = [self uniqueAttributesForEntity:entity];
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject = [self existingObjectInContext:context forEntity:entity withUniqueAttributeValue:uniqueAttributeValue];
        if (existingObject) {
            NSLog(@"%@ object with %@ value '%@' already exists", entity, uniqqueAttribute, uniqueAttributeValue);
        }
        else{
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributes];
            NSLog(@"Created %@ object woth %@ '%@'", entity, uniqqueAttribute, uniqueAttributeValue);
            return newObject;
        }
    }
    else{
        NSLog(@"Skipped %@ object creation: unique attribute value is 0 length", entity);
    }
    
    return nil;
}

-(NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity targetEntityAttribute:(NSString *)targetEntityAttribute sourceXMLAttribute:(NSString *)sourceXMLAttribute attributeDict:(NSDictionary *)attributeDict context:(NSManagedObjectContext *)context{
    NSArray *attributes = [NSArray arrayWithObject:targetEntityAttribute];
    NSArray *values = [NSArray arrayWithObject:[attributeDict valueForKey:sourceXMLAttribute]];
    
    NSDictionary *attributeValues = [NSDictionary dictionaryWithObjects:values forKeys:attributes];
    
    return [self insertUniqueObjectInTargetEntity:entity uniqueAttributeValue:[attributeDict valueForKey:sourceXMLAttribute] attributeValues:attributeValues inContext:context];
}

@end
