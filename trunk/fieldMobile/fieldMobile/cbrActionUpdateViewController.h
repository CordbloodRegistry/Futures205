//
//  cbrActionUpdateViewController.h
//  fieldMobile
//
//  Created by Hai Tran on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cbrActionUpdateViewController : UITableViewController<UIAlertViewDelegate>
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) CLLocationManager *locationManager;
- (IBAction)doneCheckIn:(id)sender;
- (IBAction)saveCheckIn:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *activityDueDate;
@property (strong, nonatomic) IBOutlet UILabel *activityDescType;
@property (strong, nonatomic) IBOutlet UITextView *activityComments;
@property (strong, nonatomic) IBOutlet UILabel *entityName;
@property (strong, nonatomic) IBOutlet UILabel *actId;
@property (strong, nonatomic) NSString *missingComment;
@property (strong, nonatomic) NSString *completedComment;

@property (strong, nonatomic) NSString *activityStatus;

@end
