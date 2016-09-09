//
//  ListBookTableViewController.m
//  DemoCloudKit
//
//  Created by HuyTCM1 on 9/9/16.
//  Copyright © 2016 HuyTCM1. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "Constants.h"
#import "BookDetailViewController.h"
#import "ListBookTableViewController.h"

@interface ListBookTableViewController ()

@property (strong, nonatomic) NSMutableArray *listBook;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ListBookTableViewController
@dynamic refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
}

- (void)loadData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container publicCloudDatabase];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Book" predicate:predicate];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *result, NSError *error) {
        if (!error) {
            self.listBook = [[NSMutableArray alloc] initWithArray:result];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
                // End the refreshing
                if (self.refreshControl) {
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, h:mm a"];
                    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                                forKey:NSForegroundColorAttributeName];
                    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                    self.refreshControl.attributedTitle = attributedTitle;
                    
                    [self.refreshControl endRefreshing];
                }
            });
        } else {
            NSLog(@"%s -- %@", __func__, error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listBook count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookItem" forIndexPath:indexPath];
    
    CKRecord *record = [self.listBook objectAtIndex:indexPath.row];
    cell.textLabel.text = record[kBookTitle];
    cell.detailTextLabel.text = record[kBookAuthor];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *database = [container publicCloudDatabase];
        CKRecord *deleteRecord = [self.listBook objectAtIndex:indexPath.row];
        [database deleteRecordWithID:deleteRecord.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [self.listBook removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Deleted!" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:alertAction];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"bookDetail"]) {
        BookDetailViewController *destViewController = [segue destinationViewController];
        destViewController.book = [self.listBook objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

@end
