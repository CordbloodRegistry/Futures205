//
//  cbrContactsViewController.h
//  fieldMobile
//
//  Created by Hai Tran on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cbrListTableViewCell.h"

@interface cbrContactsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)tapFavoriteButton:(UIButton*)button;
@end
