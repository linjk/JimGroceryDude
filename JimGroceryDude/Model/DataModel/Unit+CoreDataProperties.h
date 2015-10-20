//
//  Unit+CoreDataProperties.h
//  JimGroceryDude
//
//  Created by hodi on 10/20/15.
//  Copyright © 2015 LinJK. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Unit.h"

NS_ASSUME_NONNULL_BEGIN

@interface Unit (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
