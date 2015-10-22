//
//  UnitPickerTF.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "UnitPickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit.h"

@implementation UnitPickerTF
#define debug 1

-(void)fetch{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setFetchBatchSize:50];
    
    NSError *error = nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error populating okcier: %@, %@", error, error.localizedDescription);
    }
    [self selectDefaultRow];
}

-(void)selectDefaultRow{
    if (self.selectedObjectID && [self.pickerData count]>0) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Unit *selectedObject = (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(Unit *unit, NSUInteger idx, BOOL *stop) {
            if ([unit.name compare:selectedObject.name] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectedObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    Unit *unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}

@end
