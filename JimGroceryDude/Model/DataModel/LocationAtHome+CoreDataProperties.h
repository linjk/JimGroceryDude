//
//  LocationAtHome+CoreDataProperties.h
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LocationAtHome.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationAtHome (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *storedIn;
@property (nullable, nonatomic, retain) NSSet<Item *> *items;

@end

@interface LocationAtHome (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet<Item *> *)values;
- (void)removeItems:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END
