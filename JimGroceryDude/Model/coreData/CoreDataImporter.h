//
//  CoreDataImporter.h
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataImporter : NSObject

@property (nonatomic, retain) NSDictionary *entitiesWithUniqueAttributes;

+(void)saveContext:(NSManagedObjectContext *)context;

-(CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes;
-(NSString *)uniqueAttributesForEntity:(NSString *)entity;

-(NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeValue:(NSString *)uniqueAttributeValue attributeValues:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;
-(NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity targetEntityAttribute:(NSString *)targetEntityAttribute sourceXMLAttribute:(NSString *)sourceXMLAttribute attributeDict:(NSDictionary *)attributeDict context:(NSManagedObjectContext *)context;

@end
