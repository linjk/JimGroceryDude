//
//  Item+CoreDataProperties.h
//  JimGroceryDude
//
//  Created by hodi on 10/20/15.
//  Copyright © 2015 LinJK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *collected;
@property (nullable, nonatomic, retain) NSNumber *listed;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) Unit *unit;

@end

NS_ASSUME_NONNULL_END
