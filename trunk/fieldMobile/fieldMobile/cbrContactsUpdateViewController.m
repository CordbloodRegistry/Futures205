//
//  cbrContactsUpdateViewController.m
//  fieldMobile
//
//  Created by Hai Tran on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cbrContactsUpdateViewController.h"

@interface cbrContactsUpdateViewController ()
- (void)pickerDoneClicked;
@end

@implementation cbrContactsUpdateViewController
@synthesize status = _status;

@synthesize detailItem = _detailItem;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize role = _role;
@synthesize pickerArray = _pickerArray;
@synthesize stockingFlag = _stockingFlag;

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.detailItem != nil) {
        NSString *entityName = [[self.detailItem entity] name];
        if ([entityName isEqualToString:@"Contacts"]) {	
            self.firstName.text = [self.detailItem valueForKey:@"firstName"];
            self.lastName.text =  [self.detailItem valueForKey:@"lastName"];
            self.email.text =  [self.detailItem valueForKey:@"email"];
            self.role.text =  [self.detailItem valueForKey:@"role"];
            self.continuum.text =  [self.detailItem valueForKey:@"continuum"];
            self.officeHours.text =  [self.detailItem valueForKey:@"officeHours"];
            NSString *ofcId = [self.detailItem valueForKey:@"officeId"];
            
            //if Facility is not Kit Stocking, disable the PF kit stocking 
            NSManagedObjectContext *moc = [self.detailItem managedObjectContext];
            NSFetchRequest *fr = [[NSFetchRequest alloc] init];
            NSEntityDescription *ofcEntity = [NSEntityDescription entityForName:@"Offices" inManagedObjectContext:moc];
            [fr setEntity:ofcEntity];
            
            NSPredicate *ofcPredicate = [NSPredicate predicateWithFormat: @"(rowId = %@)",ofcId];
            [fr setPredicate:ofcPredicate];
            
            NSArray *ofcArray = [moc executeFetchRequest:fr error:nil];
            for (NSManagedObject *office in ofcArray)
                if ([[office valueForKey:@"stockingOffice"] isEqualToString:@"N"])
                    [self.stockingFlag setEnabled:NO];
                else
                    [self.stockingFlag setEnabled:YES];

            
            if ([[self.detailItem valueForKey:@"status"] isEqualToString:@"Active"])
            {
                [self.status setOn:YES];
            }
            else {
                [self.status setOn:NO];
            }
            if ([[self.detailItem valueForKey:@"kitStockingFlag"] isEqualToString:@"Y"])
            {
                [self.stockingFlag setOn:YES];
            }
            else {
                [self.stockingFlag setOn:NO];
            }
            if ([[self.detailItem valueForKey:@"role"] isEqualToString:@"Provider"])
            {
                self.firstName.enabled = NO;
                self.lastName.enabled = NO;
                self.email.enabled = NO;
                self.role.enabled = NO;
                self.continuum.enabled = NO;
            }
        }
    }
    self.pickerArray = [[NSMutableArray alloc] init];
    [self.pickerArray addObject:@""];
    [self.pickerArray addObject:@"Primary Kit Contact"];    
    [self.pickerArray addObject:@"Admin"];
    [self.pickerArray addObject:@"BMT Coordinator"];
    [self.pickerArray addObject:@"Billing Manager"];
    [self.pickerArray addObject:@"Chief of OB"];
    [self.pickerArray addObject:@"Child Birth Educator"];
    [self.pickerArray addObject:@"Clinical Nurse Educator"];
    [self.pickerArray addObject:@"Director Womens & Children"];
    [self.pickerArray addObject:@"Director"];
    [self.pickerArray addObject:@"Genetic Counselor"];
    [self.pickerArray addObject:@"L&D Director"];
    [self.pickerArray addObject:@"L&D Hospitalist"];
    [self.pickerArray addObject:@"L&D Manager"];
    [self.pickerArray addObject:@"L&D Medical Assistant"];
    [self.pickerArray addObject:@"L&D Nurse"];
    [self.pickerArray addObject:@"Maternal Fetal Med Specialist"];
    [self.pickerArray addObject:@"Medical Assistant"];
    [self.pickerArray addObject:@"Neonatologist"];
    [self.pickerArray addObject:@"Nurse"];
    [self.pickerArray addObject:@"Nurse Office"];
    [self.pickerArray addObject:@"Nurse Practitioner"];
    [self.pickerArray addObject:@"Office Manager"];
    [self.pickerArray addObject:@"Physician Assistant"];
    [self.pickerArray addObject:@"Receptionist"];
    [self.pickerArray addObject:@"Resident"];
    [self.pickerArray addObject:@"Staff Billing"];
    [self.pickerArray addObject:@"Staff Other"];
    [self.pickerArray addObject:@"Ultrasound Technician"];
    
    UIPickerView *myPickerView = [[UIPickerView alloc] init];
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = 100;
    myPickerView.delegate = self;
    self.role.inputView = myPickerView;
    
    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view...
    // Prepare done button
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    //keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    //keyboardDoneButtonView.translucent = YES;
    //keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(pickerDoneClicked)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer,doneButton, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    self.role.inputAccessoryView = keyboardDoneButtonView;
    
    self.pickerContinuum = [[NSMutableArray alloc] init];
    [self.pickerContinuum addObject:@""];
    [self.pickerContinuum addObject:@"Skeptic"];
    [self.pickerContinuum addObject:@"Facilitator"];
    [self.pickerContinuum addObject:@"CB Advocate"];
    [self.pickerContinuum addObject:@"CBR Advocate"];
    
    UIPickerView *continuumPickerView = [[UIPickerView alloc] init];
    continuumPickerView.showsSelectionIndicator = YES;
    continuumPickerView.delegate = self;
    continuumPickerView.tag = 200;
    self.continuum.inputView = continuumPickerView;
    self.continuum.inputAccessoryView = keyboardDoneButtonView;

}
- (void)pickerDoneClicked
{
    [self.role resignFirstResponder];
    [self.continuum resignFirstResponder];
}
- (void)viewDidUnload
{
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setEmail:nil];
    [self setRole:nil];
    [self setStatus:nil];
    [super viewDidUnload];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == self.officeHours)
        return (textField.text.length < 250);
    else
        return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.firstName || theTextField == self.lastName || theTextField == self.email || theTextField == self.role || theTextField == self.continuum ){
        [theTextField resignFirstResponder];
    }
    return NO;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { 
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component { 
    if (thePickerView.tag == 100)
        return [self.pickerArray count];
    else if (thePickerView.tag == 200)
        return [self.pickerContinuum count];
    else
        return 0;
    
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { 
    if (thePickerView.tag == 100)
        return [self.pickerArray objectAtIndex:row];
    else if (thePickerView.tag == 200)
        return [self.pickerContinuum objectAtIndex:row];
    else 
        return 0;
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (thePickerView.tag == 100)
        [self.role setText:[self.pickerArray objectAtIndex:row]];
    else if (thePickerView.tag == 200)
        [self.continuum setText:[self.pickerContinuum objectAtIndex:row]];
}

- (IBAction)cancelRecord:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveRecord:(id)sender {
    NSString *errorMsg = @"";
    if([self.firstName.text length] == 0)
    {
        errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"First Name is required"];
    }
    if([self.lastName.text length] == 0)
    {
        errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"Last Name is required"];
    }
    if([self.role.text length] == 0 && self.status.isOn)
    {
        errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"Role is required"];
    }
    if([self.continuum.text length] == 0 && self.status.isOn && ![[self.detailItem valueForKey:@"role"] isEqualToString:@"Provider"])
    {
        errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"Continuum is required"];
    }
    if([self.role.text isEqualToString:@"Primary Kit Contact"] && self.status.isOn)
    {
        // ensure kit stocking contact does not already exist to facility prior
        NSManagedObjectContext *moc = [self.detailItem managedObjectContext];
        
        NSFetchRequest *fr = [[NSFetchRequest alloc] init];
        [fr setEntity:[NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:moc]];
        if ([[[self.detailItem entity] name] isEqualToString:@"Contacts"])
        {
            [fr setPredicate:[NSPredicate predicateWithFormat: @"(status = %@) && (officeId = %@) && (role = %@) && (SELF != %@)", @"Active",[self.detailItem valueForKey:@"officeId"],@"Primary Kit Contact",self.detailItem]];
        }
        else {
            [fr setPredicate:[NSPredicate predicateWithFormat: @"(status = %@) && (officeId = %@) && (role = %@)", @"Active",[self.detailItem valueForKey:@"rowId"],@"Primary Kit Contact"]];
        }
        NSArray *contactArray = [moc executeFetchRequest:fr error:nil];
        
        if ([contactArray count] >= 1) {
            errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"An active Primary Kit Contact already exists"];
        }
    }
    if ([self.email.text length] > 0)
    {
        self.email.text = [self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSError *error = NULL;
        NSString *expression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSTextCheckingResult *match = [regex firstMatchInString:self.email.text options:0 range:NSMakeRange(0, [self.email.text length])];
        
        if (!match){
            errorMsg = [NSString stringWithFormat:@"%@%@\n",errorMsg,@"Valid Email is required"];
        }
        
    }

    if ([errorMsg length] > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else 
    {
    
    
    NSManagedObjectContext *context = [self.detailItem managedObjectContext];
    
    if ([[[self.detailItem entity] name] isEqualToString:@"Contacts"])
    {
        [self.detailItem setValue:self.firstName.text forKey:@"firstName"];
        [self.detailItem setValue:self.lastName.text forKey:@"lastName"];
        [self.detailItem setValue:self.email.text forKey:@"email"];
        [self.detailItem setValue:self.role.text forKey:@"role"];
        [self.detailItem setValue:self.continuum.text forKey:@"continuum"];
        [self.detailItem setValue:self.officeHours.text forKey:@"officeHours"];
        if (self.status.isOn) {
            [self.detailItem setValue:@"Active" forKey:@"status"];
        }
        else {
            [self.detailItem setValue:@"Inactive" forKey:@"status"];
        }
        if (self.stockingFlag.isOn) {
            [self.detailItem setValue:@"Y" forKey:@"kitStockingFlag"];
        }
        else {
            [self.detailItem setValue:@"N" forKey:@"kitStockingFlag"];
        }
        if ([self.detailItem valueForKey:@"officeId"] != NULL)
        {
            NSEntityDescription *officeEntity = [NSEntityDescription entityForName:@"Offices" inManagedObjectContext:context];
            NSFetchRequest *fr = [[NSFetchRequest alloc] init];
            [fr setEntity:officeEntity];
            
            // Set example predicate and sort orderings..
            NSPredicate *actionPredicate = [NSPredicate predicateWithFormat: @"(rowId = %@)", [self.detailItem valueForKey:@"officeId"]];
            [fr setPredicate:actionPredicate];
            
            NSSortDescriptor *SortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowId" ascending:YES];
            [fr setSortDescriptors:[NSArray arrayWithObject:SortDescriptor]];
            
            NSArray *officeArray = [context executeFetchRequest:fr error:nil];
            
            for (NSManagedObject *office in officeArray)
            {
                [self.detailItem setValue:office forKey:@"contactOffice"];
                [office setValue:[self.detailItem valueForKey:@"rowId"] forKey:@"kitContactId"];
                [office setValue:[self.detailItem valueForKey:@"firstName"] forKey:@"kitContactFirstName"];
                [office setValue:[self.detailItem valueForKey:@"lastName"] forKey:@"kitContactLastName"];
            }
        }
        

        [self recordTransaction:self.detailItem transactionType:@"Update"];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    
    }
    else {
        NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
        [newContact setValue:self.firstName.text forKey:@"firstName"];
        [newContact setValue:self.lastName.text forKey:@"lastName"];
        [newContact setValue:self.email.text forKey:@"email"];
        [newContact setValue:self.role.text forKey:@"role"];
        [newContact setValue:self.officeHours.text forKey:@"officeHours"];
        [newContact setValue:[[NSString alloc] initWithFormat:@"%@", [[self.detailItem  valueForKey:@"rowId"] description]] forKey:
         @"officeId"];
        if (self.status.isOn) {
            [newContact setValue:@"Active" forKey:@"status"];
        }
        else {
            [newContact setValue:@"Inactive" forKey:@"status"];
        }
        if (self.stockingFlag.isOn) {
            [newContact setValue:@"Y" forKey:@"kitStockingFlag"];
        }
        else {
            [newContact setValue:@"N" forKey:@"kitStockingFlag"];
        }
        //[newContact setValue:@"" forKey:@"rowId"];
        
        if (self.detailItem != nil) {
            NSString *relationshipName;
            NSString *entityName = [[self.detailItem entity] name];
            
            if ([entityName isEqualToString:@"Offices"]) {	
                relationshipName = @"officeContacts";
            }
            if ([entityName isEqualToString:@"Providers"]) {
                relationshipName = @"provContacts";
            }
            
            NSMutableSet *contactRelation = [[self detailItem] mutableSetValueForKey:relationshipName];
            [contactRelation addObject:newContact];
        }    
        
        [self recordTransaction:newContact transactionType:@"Create"];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    //[self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)recordTransaction:(NSManagedObject *)obj transactionType:(NSString *)sType 
{
    NSManagedObjectContext *context = [self.detailItem managedObjectContext];;
    NSManagedObject *newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transactions" inManagedObjectContext:context];
    
    NSDate *today = [NSDate date];
    
    //current location
    CLLocationManager *clm = [[CLLocationManager alloc] init];
    
    //self.locationManager.delegate = self;
    clm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    // Set a movement threshold for new events.
    clm.distanceFilter = 500;
    
    [clm startUpdatingLocation];
    
    CLLocation *myLocation = [clm location];
    
    [newTransaction setValue:@"Contact" forKey:@"entityType"];
    [newTransaction setValue:[NSNumber numberWithFloat:myLocation.coordinate.latitude] forKey:@"latitude"];
    [newTransaction setValue:[NSNumber numberWithFloat:myLocation.coordinate.longitude] forKey:@"longitude"];
    [newTransaction setValue:today forKey:@"transactionDate"];
    [newTransaction setValue:sType forKey:@"transactionType"];
    
    [clm stopUpdatingLocation];
    
    
    NSMutableSet *transactionRelation = [obj mutableSetValueForKey:@"transactions"];
    [transactionRelation addObject:newTransaction];
    
    //[context save:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[self.detailItem valueForKey:@"role"] isEqualToString:@"Provider"])
        return 8;
    else 
        return 6;
}

@end
