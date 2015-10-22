//
//  LocationAtHomePickerTF.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "LocationAtHomePickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtHome.h"

@implementation LocationAtHomePickerTF
#define debug 1

-(void)fetch{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storedIn" ascending:YES];
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
        LocationAtHome *selectedObject = (LocationAtHome *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtHome *locationAtHome, NSUInteger idx, BOOL *stop) {
            if ([locationAtHome.storedIn compare:selectedObject.storedIn] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectedObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    LocationAtHome *locationAtHome = [self.pickerData objectAtIndex:row];
    return locationAtHome.storedIn;
}

@end
