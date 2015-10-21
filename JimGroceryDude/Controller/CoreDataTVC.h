//
//  CoreDataTVC.h
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface CoreDataTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;

-(void)performFetch;

@end
