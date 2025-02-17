//
//  cbrProviderViewController.m
//  fieldDevice
//
//  Created by Hai Tran on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cbrAppDelegate.h"
#import "cbrProviderViewController.h"
#import "cbrProviderAddViewController.h"
#import "cbrProviderDetailViewController.h"
#import "cbrProviderMapViewController.h"
#import "cbrTableViewCell.h"
#import "cbrProviderFilterViewController.h"

@interface cbrProviderViewController ()
- (void)configureCell:(cbrTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath UpdateType:(NSString *)type;
- (void)clearForm; 
@end

@implementation cbrProviderViewController

@synthesize fetchResultsArray = _fetchResultsArray;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize mapView, tableView;
@synthesize myObject = _myObject;
@synthesize segmentedControl = _segmentedControl;
@synthesize myLocation = _myLocation;
@synthesize sortSegmentIndex = _sortSegmentIndex;
@synthesize distanceSegmentIndex = _distanceSegmentIndex;
@synthesize momentumSegmentIndex = _momentumSegmentIndex;
@synthesize kitStockingSegmentIndex = _kitStockingSegmentIndex;
@synthesize mouSegmentIndex = _mouSegmentIndex;
@synthesize kolSegmentIndex = _kolSegmentIndex;
@synthesize searchFirstNameString = _searchFirstNameString;
@synthesize searchLastNameString = _searchLastNameString;
@synthesize searchFacilityString = _searchFacilityString;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.myLocation == nil)
    {
        self.myLocation = [(cbrAppDelegate *)[[UIApplication sharedApplication] delegate] locationManager];
    }
   
    // set up views and override default uitableview view class behavior
    if (!tableView && [self.view isKindOfClass:[UITableView class]]) {
        tableView = (UITableView *)self.view;
    }
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    if (!mapView) 
        mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    
    self.mapView.frame = self.view.bounds;
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    // end set up
    

    if (self.managedObjectContext == nil)
	{
        self.managedObjectContext = [(cbrAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    [self.segmentedControl setSelectedSegmentIndex:-1];  
    
    [self clearForm];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (cbrTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    cbrTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath UpdateType:@"new"];
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
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
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
    return self.editing;
}

- (void)backButton:(cbrProviderFilterViewController *)controller
{
    [self.tableView reloadData];
    
    if (!self.mapView.isHidden){
        [self configureMapView];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissModalViewControllerAnimated:YES];

}
- (void)searchSelected:(cbrProviderFilterViewController *)controller
{
    self.sortSegmentIndex = [NSNumber numberWithInt:controller.sortSegment.selectedSegmentIndex];
    self.distanceSegmentIndex = [NSNumber numberWithInt:controller.distanceSegment.selectedSegmentIndex];
    self.momentumSegmentIndex = [NSNumber numberWithInt:controller.momentumSegment.selectedSegmentIndex];
    self.kitStockingSegmentIndex = [NSNumber numberWithInt:controller.kitStockingSegment.selectedSegmentIndex];
    self.mouSegmentIndex = [NSNumber numberWithInt:controller.mouSegment.selectedSegmentIndex];
    self.kolSegmentIndex = [NSNumber numberWithInt:controller.kolSegment.selectedSegmentIndex];
    self.searchFirstNameString = controller.searchFirstNameField.text;
    self.searchLastNameString = controller.searchLastNameField.text;
    self.searchFacilityString = controller.searchFacilityField.text;
    
    NSError *error = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Providers" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *theRequest = [[NSFetchRequest alloc] init];
    [theRequest setEntity:entityDescription];
    
    NSString *predicateString = [self buildPredicate];
    
    //NSString *predicateString =  @"(momentumRating = 'D1')";

    
    // Edit the predicate as appropriate
    NSPredicate *predicateClosed = [NSPredicate predicateWithFormat:predicateString];
    [theRequest setPredicate:predicateClosed];

    if (self.mouSegmentIndex.integerValue == 1)
    {
        NSPredicate *overDuePredicate = [NSPredicate predicateWithFormat:@"(nextFUDate <= %@)",[NSDate date]];
        
        NSPredicate *newPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicateClosed, overDuePredicate, nil]];
        [theRequest setPredicate:newPredicate];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [theRequest setSortDescriptors:sortDescriptors];
    
    // re-initialize the FRC
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:theRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    self.fetchedResultsController = nil;
    [self sortMyResults];
    
    [self.tableView reloadData];
    
    if (!self.mapView.isHidden){
        [self configureMapView];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissModalViewControllerAnimated:YES];
}



- (void)sortMyResults {
    NSArray *recordSet = [self.fetchedResultsController.managedObjectContext executeFetchRequest:self.fetchedResultsController.fetchRequest error:NULL];
    
    if ([self.sortSegmentIndex integerValue] == 0)
    {
        self.fetchResultsArray = 
        [recordSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {       
            CLLocation *aLoc = [[CLLocation alloc] initWithLatitude:[[[a valueForKey:@"latitude"] description] floatValue] longitude:[[[a valueForKey:@"longitude"] description] floatValue]];
            CLLocation *bLoc = [[CLLocation alloc] initWithLatitude:[[[b valueForKey:@"latitude"] description] floatValue] longitude:[[[b valueForKey:@"longitude"] description] floatValue]];
            int distance = [self.myLocation.location distanceFromLocation:aLoc];
            int otherDistance = [self.myLocation.location distanceFromLocation:bLoc];
            if(distance > otherDistance){
                return NSOrderedDescending;
            } else if(distance < otherDistance){
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    else if([self.sortSegmentIndex integerValue] == 1)
    {
        // momentum: do nothing -- already pre-sorted by Momentum
        self.fetchResultsArray = 
        [recordSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *momentum = [[a valueForKey:@"rating"] description];
            NSString *otherMomentum = [[b valueForKey:@"rating"] description];
            
            if ([momentum length] == 0) {
                momentum = @"P6";}
            if ([otherMomentum length] == 0) {
                otherMomentum = @"P6";}

            return [momentum compare:otherMomentum options:NSCaseInsensitiveSearch];
        }];
    } 
    else if ([self.sortSegmentIndex integerValue] == 2)
    {
        self.fetchResultsArray = 
        [recordSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {       
            
            int turn = [[a valueForKey:@"numEnrollments"] integerValue];
            int otherTurn = [[b valueForKey:@"numEnrollments"] integerValue];
            if(turn < otherTurn){
                return NSOrderedDescending;
            } else if(turn > otherTurn){
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    else if ([self.sortSegmentIndex integerValue] == 3)  //ascending
    {
        self.fetchResultsArray = 
        [recordSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {       
            
            int turn = [[a valueForKey:@"turn"] integerValue];
            int otherTurn = [[b valueForKey:@"turn"] integerValue];
            if(turn > otherTurn){
                return NSOrderedDescending;
            } else if(turn < otherTurn){
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    else if ([self.sortSegmentIndex integerValue] == -1)
    {
        self.fetchResultsArray = 
        [recordSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            if (([a valueForKey:@"nextFUDate"] == NULL) && ([b valueForKey:@"nextFUDate"] == NULL))
                return NSOrderedSame;
            else if (([a valueForKey:@"nextFUDate"] == NULL) && ([b valueForKey:@"nextFUDate"] != NULL))
                return NSOrderedDescending;
            else if (([a valueForKey:@"nextFUDate"] != NULL) && ([b valueForKey:@"nextFUDate"] == NULL))
                return NSOrderedAscending;
            else {
                
                NSDate *aDate = [a valueForKey:@"nextFUDate"];
                NSDate *bDate = [b valueForKey:@"nextFUDate"];
                return [aDate compare:bDate];
            }
        }];
    }
    else {
        self.fetchResultsArray = recordSet;
    }
}

- (NSString *)buildPredicate {
    NSString *searchName = @"";
    NSString *outPredicate =  @"(personUID <> NULL)";
    switch([self.momentumSegmentIndex integerValue])
    {
        case 0:
            outPredicate = [[NSString alloc] initWithFormat:@"(rating = 'P1' or rating = 'P2') and %@",outPredicate];
            break;
        case 1:
            //outPredicate = [[NSString alloc] initWithFormat:@"(rating = 'P3' or rating = 'P4' or rating = 'P5' or rating = 'N' or rating = NULL) and %@",outPredicate];
            outPredicate = [[NSString alloc] initWithFormat:@"(rating != 'P1' AND rating != 'P2') and %@",outPredicate];
            break;
            /*
        case 2:
            outPredicate = [[NSString alloc] initWithFormat:@"(momentumRating = 'D3') and %@",outPredicate];
            break;
        case 3:
            outPredicate = [[NSString alloc] initWithFormat:@"(momentumRating = 'D4') and %@",outPredicate];
            break;
        case 4:
            outPredicate = [[NSString alloc] initWithFormat:@"(momentumRating = 'D5') and %@",outPredicate];
            break;
        case 5:
            outPredicate = [[NSString alloc] initWithFormat:@"(momentumRating = 'D6' or momentumRating = 'N' or momentumRating = NULL) and %@",outPredicate];
            break;
        */
        default:
            break;
    }
    
    switch([self.kitStockingSegmentIndex integerValue])
    {
        case 0:
            outPredicate = [[NSString alloc] initWithFormat:@"(stockingDoc = 'Y') and %@",outPredicate];
            break;
        case 1:
            outPredicate = [[NSString alloc] initWithFormat:@"(stockingDoc = 'N' or stockingDoc = NULL) and %@",outPredicate];
            break;
        default:
            break;
    }
    
    switch([self.mouSegmentIndex integerValue])
    {
        case 0:
            outPredicate = [[NSString alloc] initWithFormat:@"(nextFUDate != NULL) && %@",outPredicate];
            break;
        case 1:
        {
            break;
        }
        default:
            break;
    }

    switch([self.kolSegmentIndex integerValue])
    {
        case 0:
            outPredicate = [[NSString alloc] initWithFormat:@"(keyAccountMarker = 'Y') && %@",outPredicate];
            break;
        case 1:
        {
            outPredicate = [[NSString alloc] initWithFormat:@"(keyAccountMarker <> 'Y') && %@",outPredicate];
            break;
        }
        default:
            break;
    }
    
    if ([self.searchFirstNameString length] > 0)
    {
        searchName = self.searchFirstNameString;
        searchName = [[searchName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@"?"];
        outPredicate = [[NSString alloc] initWithFormat:@"(firstName like [c] '*%@*') && %@", searchName, outPredicate];
        
        //outPredicate = [[NSString alloc] initWithFormat:@"(firstName CONTAINS[c] '%@') and %@",self.searchFirstNameString, outPredicate];
    }
    if ([self.searchLastNameString length] > 0)
    {
        searchName = self.searchLastNameString;
        searchName = [[searchName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@"?"];
        outPredicate = [[NSString alloc] initWithFormat:@"(lastName like [c] '*%@*') && %@", searchName, outPredicate];
        //outPredicate = [[NSString alloc] initWithFormat:@"(lastName CONTAINS[c] '%@') and %@",self.searchLastNameString, outPredicate];
        
    }
    if ([self.searchFacilityString length] > 0)
    {
        searchName = self.searchFacilityString;
        searchName = [[searchName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@"?"];
        outPredicate = [[NSString alloc] initWithFormat:@"(facilityName like [c] '*%@*') && %@", searchName, outPredicate];
        //outPredicate = [[NSString alloc] initWithFormat:@"(facilityName CONTAINS[c] '%@') and %@",self.searchFacilityString, outPredicate];
        
    }

    return outPredicate;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"providerDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *selectedObject = [self.fetchResultsArray objectAtIndex:indexPath.row];
        if (!self.mapView.isHidden)
        {
            [[segue destinationViewController] setDetailItem:self.myObject];
            
        }
        else {
            [[segue destinationViewController] setDetailItem:selectedObject];
            
        }
    }
    
    
    if ([[segue identifier] isEqualToString:@"addProvider"]) { 
        [[segue destinationViewController] setDetailItem:self.managedObjectContext];
    }
    if ([[segue identifier] isEqualToString:@"seeMap"]) {
        [[segue destinationViewController] setDetailItem:self.fetchResultsArray];
    }    
    if ([[segue identifier] isEqualToString:@"filterProvider"]) {
        cbrProviderFilterViewController *filterController = (cbrProviderFilterViewController *)[segue destinationViewController];
        filterController.distanceSegmentIndex = self.distanceSegmentIndex;
        filterController.momentumSegmentIndex = self.momentumSegmentIndex;
        filterController.kitStockingSegmentIndex = self.kitStockingSegmentIndex;
        filterController.mouSegmentIndex = self.mouSegmentIndex;
        filterController.kolSegmentIndex = self.kolSegmentIndex;
        filterController.sortSegmentIndex = self.sortSegmentIndex;
        filterController.searchFirstNameString = self.searchFirstNameString;
        filterController.searchLastNameString = self.searchLastNameString;
        filterController.searchFacilityString = self.searchFacilityString;
        
        
       // searchFirstNameString = self.searchNameString;
        filterController.delegate = self;
    }

}

- (void)configureCell:(cbrTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath UpdateType:(NSString *)type {
    NSManagedObject *managedObject;
    
    //if ([type isEqualToString:@"update"])
    //    managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //else
        managedObject = [self.fetchResultsArray objectAtIndex:indexPath.row];
   
    NSString *labelText;
    if ([[[managedObject valueForKey:@"providerType"] description] isEqualToString:@"Resident"])
        labelText = [[NSString alloc] initWithFormat:@"%@ %@ - Resident", [[managedObject valueForKey:@"firstName"] description], [[managedObject valueForKey:@"lastName"] description]];
    else
        labelText = [[NSString alloc] initWithFormat:@"%@ %@", [[managedObject valueForKey:@"firstName"] description], [[managedObject valueForKey:@"lastName"] description]];
    cell.nameLabel.text = labelText;    
    
    CLLocation *aLoc = [[CLLocation alloc] initWithLatitude:[[[managedObject valueForKey:@"latitude"] description] floatValue] longitude:[[[managedObject valueForKey:@"longitude"] description] floatValue]];
    
    int distance = [self.myLocation.location distanceFromLocation:aLoc];
    NSNumber *miles = [NSNumber numberWithDouble:((double)distance) / 1609.344];
    labelText = [[NSString alloc] initWithFormat:@"%.2f mi",[miles doubleValue]];

    cell.distanceLabel.text = labelText;
    cell.subtitleLabel.text = [[managedObject valueForKey:@"facilityName"] description];
    if ([[managedObject valueForKey:@"facilityAddr2"] description].length > 0)
        labelText = [[NSString alloc] initWithFormat:@"%@, %@, %@", [[managedObject valueForKey:@"facilityAddr"] description], [[managedObject valueForKey:@"facilityAddr2"] description], [[managedObject valueForKey:@"facilityCity"] description]];
    else
        labelText = [[NSString alloc] initWithFormat:@"%@, %@", [[managedObject valueForKey:@"facilityAddr"] description], [[managedObject valueForKey:@"facilityCity"] description]];
    cell.addressLabel.text = labelText;
    cell.favoriteButton.tag = indexPath.row;
     if ([[[managedObject  valueForKey:@"keyAccountMarker"] description] isEqualToString:@"Y"])
         cell.favoriteButton.selected = TRUE;
     else
         cell.favoriteButton.selected = FALSE;
    

    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:[NSEntityDescription entityForName:@"Kits" inManagedObjectContext:moc]];
    [fr setPredicate:[NSPredicate predicateWithFormat: @"(assignedOfficeId = %@) && (status != %@ || status == nil)",[managedObject valueForKey:@"facilityId"],@"Inactive/Lost"]];
    NSArray *kits = [moc executeFetchRequest:fr error:nil];
    
    int kitCount = [kits count];
    
    cell.numberCollections.text = [NSString stringWithFormat:@"%@ enrs | %@ vel | %@ kits",[managedObject valueForKey:@"numEnrollments"],[managedObject valueForKey:@"turn"],[NSNumber numberWithInt:kitCount]];
    NSString *momentum = [[NSString alloc] initWithString:[[managedObject valueForKey:@"rating"] description]];
    
    if ([momentum isEqualToString:@"P1"]) {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_1.png"]];}
    else if ([momentum isEqualToString:@"P2"]) {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_2.png"]];}
    else if ([momentum isEqualToString:@"P3"]) {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_3.png"]];}
    else if ([momentum isEqualToString:@"P4"]) {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_4.png"]];}
    else if ([momentum isEqualToString:@"P5"]) {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_5.png"]];}
    else {
        [cell.momentumImage setImage:[UIImage imageNamed:@"MOMENTUMS_6.png"]];}


    if (!([managedObject valueForKey:@"nextFUDate"] == nil))
    {
        [cell.nameLabel setTextColor:[UIColor colorWithRed:155/255.0 green:0/255.0 blue:46/255.0 alpha:1]];
    }
    else {
        [cell.nameLabel setTextColor:[UIColor darkTextColor]];
    }

    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }

    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Providers" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSString *predicateString = [self buildPredicate];
    
    // Set filter
    NSPredicate *myPredicate = [NSPredicate predicateWithFormat:predicateString];
    [fetchRequest setPredicate:myPredicate];
    
    if (self.mouSegmentIndex.integerValue == 1)
    {
        NSPredicate *overDuePredicate = [NSPredicate predicateWithFormat:@"(nextFUDate <= %@)",[NSDate date]];
        
        NSPredicate *newPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:myPredicate, overDuePredicate, nil]];
        [fetchRequest setPredicate:newPredicate];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
    //self.fetchResultsArray = [self.fetchedResultsController.managedObjectContext executeFetchRequest:self.fetchedResultsController.fetchRequest error:NULL];

    
    [self sortMyResults];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
//    [self.tableView reloadData];
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self sortMyResults];
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
            
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    //UITableView *myTableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(cbrTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath UpdateType:@"update"];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark -Map Functions
-(void)configureMapView {
    // remove existing annotations
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.showsUserLocation = NO;
    self.mapView.showsUserLocation = YES;
    [self.mapView addAnnotations:self.fetchResultsArray];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    //annView.animatesDrop=TRUE;
    if (annotation == [self.mapView userLocation] ){
        return nil; //default to blue dot
    }
    
    if ([(NSManagedObject *)annotation valueForKey:@"nextFUDate"] != nil)
        annView.pinColor = MKPinAnnotationColorRed;
    else 
        annView.pinColor = MKPinAnnotationColorPurple;
    annView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annView.canShowCallout = YES;
    annView.enabled = YES;
    return annView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    self.myObject = view.annotation;
    [self performSegueWithIdentifier:@"providerDetail" sender:self];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.mapView.centerCoordinate = userLocation.location.coordinate;
} 

#pragma mark -customActions
- (IBAction)toggleView:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:(self.mapView == nil ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft)
                           forView:self.view cache:NO];
    [UIView commitAnimations];
    
    if (self.mapView == nil)
    {
        self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.hidden = YES;
        self.mapView.delegate = self;
    }
    // map visible? show or hide it
    if (self.mapView.isHidden)
    {
        // get on with setting up the region
        CLLocationManager *myLocation = [(cbrAppDelegate *)[[UIApplication sharedApplication] delegate] locationManager];
        CLLocationCoordinate2D coord = myLocation.location.coordinate;
        MKCoordinateSpan span;
        span.latitudeDelta = .1;
        span.longitudeDelta =  .1;
        MKCoordinateRegion region;
        region.span = span;
        region.center = coord;
        [self.mapView setRegion:region animated:YES];
        [self.segmentedControl setTitle:@"List" forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
        self.tableView.hidden = YES;
        self.mapView.hidden = NO;
        [self configureMapView];
        
    } else {
        [self.segmentedControl setTitle:@"Map" forSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
        self.mapView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (IBAction)clickSegmentControl:(id)sender {
    
    NSString *choice;    
    choice = [self.segmentedControl titleForSegmentAtIndex: self.segmentedControl.selectedSegmentIndex];
    if ([choice isEqualToString:@"Map"] || ([choice isEqualToString:@"List"]))
    {
        [self toggleView:sender];
    
    } else if ([choice isEqualToString:@"Search"])
    {
        [self filterProvider:sender];
    }
    else if (([choice isEqualToString:@"Add"])) {
        [self addProvider:sender];
        
    }
}

- (void)addProvider:(id)sender {
    [self performSegueWithIdentifier:@"addProvider" sender:self];
}

- (void)filterProvider:(id)sender {
    [self performSegueWithIdentifier:@"filterProvider" sender:self];
}

- (void)recordTransaction:(NSManagedObject *) obj
{
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
   NSManagedObject *newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transactions" inManagedObjectContext:self.managedObjectContext];
    
    NSDate *today = [NSDate date];
    
    //current location
    CLLocationManager *clm = [[CLLocationManager alloc] init];
    
    //self.locationManager.delegate = self;
    clm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    // Set a movement threshold for new events.
    clm.distanceFilter = 500;
    
    [clm startUpdatingLocation];
    
    CLLocation *myLocation = [clm location];
    
    [newTransaction setValue:[[obj valueForKey:@"rowId"] description] forKey:@"entityId"];
    [newTransaction setValue:@"Provider" forKey:@"entityType"];
    [newTransaction setValue:[NSNumber numberWithFloat:myLocation.coordinate.latitude] forKey:@"latitude"];
    [newTransaction setValue:[NSNumber numberWithFloat:myLocation.coordinate.longitude] forKey:@"longitude"];
    [newTransaction setValue:today forKey:@"transactionDate"];
    [newTransaction setValue:@"Update" forKey:@"transactionType"];
    
    [clm stopUpdatingLocation];
    
    
    NSMutableSet *transactionRelation = [obj mutableSetValueForKey:@"transactions"];
    [transactionRelation addObject:newTransaction];    
}

- (void)clearForm {
    
    self.sortSegmentIndex = [NSNumber numberWithInt:-1];
    self.distanceSegmentIndex = [NSNumber numberWithInt:-1];
    self.momentumSegmentIndex = [NSNumber numberWithInt:-1];
    self.kitStockingSegmentIndex = [NSNumber numberWithInt:-1];
    self.mouSegmentIndex = [NSNumber numberWithInt:-1];
    self.kolSegmentIndex = [NSNumber numberWithInt:-1];
    self.searchFirstNameString = @"";
    self.searchLastNameString = @"";
    self.searchFacilityString = @"";
    
}
-(IBAction)tapFavoriteButton:(UIButton*)button
{
    NSManagedObject *managedObject;
    
    managedObject = [self.fetchResultsArray objectAtIndex:button.tag];
    if (button.selected)
        [managedObject setValue:@"N" forKey:@"keyAccountMarker"];
    else
        [managedObject setValue:@"Y" forKey:@"keyAccountMarker"];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:[NSEntityDescription entityForName:@"Providers" inManagedObjectContext:self.managedObjectContext]];

    NSPredicate *officePredicate = [NSPredicate predicateWithFormat: @"(rowId = %@)", [[managedObject  valueForKey:@"rowId"] description]];
    [fr setPredicate:officePredicate];
    NSArray *provArray = [moc executeFetchRequest:fr error:nil];
    for (int ctr = 0; ctr < [provArray count]; ctr++)
        [[provArray objectAtIndex:ctr] setValue:[managedObject valueForKey:@"keyAccountMarker"] forKey:@"keyAccountMarker"];
    
    [self recordTransaction:[provArray objectAtIndex:0]];
    if (![[managedObject managedObjectContext] save:nil]) {
        NSLog(@"Unresolved error %@, %@", nil, nil);
        abort();
    }
}

@end
