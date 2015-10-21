//
//  ShopTVC.m
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "ShopTVC.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "Unit.h"
#import "AppDelegate.h"

@interface ShopTVC ()

@end

@implementation ShopTVC
#define debug 1

#pragma mark DATA
-(void)configureFetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [[cdh.model fetchRequestTemplateForName:@"ShoppingList"] copy];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"locationAtShop.aisle" ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    [request setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtShop.aisle" cacheName:nil];
    self.frc.delegate = self;
}
#pragma mark VIEW
- (void)viewDidLoad {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    //
    [self configureFetch];
    [self performFetch];
    
    //Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    static NSString *cellIdentifier = @"Shop Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity, item.unit.name, item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, [title length])];
    cell.textLabel.text = title;
    
    //make collected items green
    if (item.collected.boolValue) {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetace Neue" size:16]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.368627450 green:0.741176470 blue:0.349019607 alpha:1.0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetace Neue" size:18]];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    
    return nil;//do not need a section index.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    Item *item = [self.frc objectAtIndexPath:indexPath];
    if (item.collected.boolValue) {
        item.collected = [NSNumber numberWithBool:NO];
    }
    else{
        item.collected = [NSNumber numberWithBool:YES];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark INTERACTION
-(IBAction)clear:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'...", self.class, NSStringFromSelector(_cmd));
    }
    if ([self.frc.fetchedObjects count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to clear" message:@"Add items using the Prepare tab." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    BOOL nothingCleared = YES;
    for (Item *item  in self.frc.fetchedObjects) {
        if (item.collected.boolValue) {
            item.listed = [NSNumber numberWithBool:NO];
            item.collected = [NSNumber numberWithBool:NO];
            nothingCleared = NO;
        }
    }
    if (nothingCleared) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Selecte items to be removed from the list before pressing Clear." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
