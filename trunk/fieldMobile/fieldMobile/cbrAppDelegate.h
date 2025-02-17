//
//  cbrAppDelegate.h
//  fieldDevice
//
//  Created by Hai Tran on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// test

#import <UIKit/UIKit.h>

@interface cbrAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
