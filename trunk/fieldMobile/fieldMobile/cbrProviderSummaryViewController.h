//
//  cbrProviderSummaryViewController.h
//  fieldMobile
//
//  Created by Hai Tran on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cbrProviderSummaryViewController : UITableViewController<UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) id detailItem;
//@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UISwitch *status;
@property (weak, nonatomic) IBOutlet UITextField *reasonText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UISwitch *noEmailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *noFaxSwitch;
@property (weak, nonatomic) IBOutlet UITextField *monthlyBirthText;
@property (weak, nonatomic) IBOutlet UITextField *drBirthYear;
@property (weak, nonatomic) IBOutlet UITextField *continuum;
@property (strong, nonatomic) NSMutableArray *pickerYearArray;
@property (weak, nonatomic) IBOutlet UILabel *monthlyBirthLabel;
@property (strong, nonatomic) NSMutableArray *pickerReasonArray;
@property (strong, nonatomic) NSMutableArray *pickerContinuumArray;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UISwitch *sendInviteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *resetPasswordSwitch;


//- (IBAction)valueChanged:(UIStepper *)sender;
- (IBAction)saveChanges:(id)sender;

@end
