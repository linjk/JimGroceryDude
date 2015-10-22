//
//  LocationAtShopPickerTF.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "LocationAtShopPickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtShop.h"

@implementation LocationAtShopPickerTF
#define debug 1

-(void)fetch{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES];
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
        LocationAtShop *selectedObject = (LocationAtShop *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtShop *locationAtShop, NSUInteger idx, BOOL *stop) {
            if ([locationAtShop.aisle compare:selectedObject.aisle] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectedObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    LocationAtShop *locationAtShop = [self.pickerData objectAtIndex:row];
    return locationAtShop.aisle;
}

@end
