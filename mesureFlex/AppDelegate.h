//
//  AppDelegate.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 13/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WebServiceManager.h"
#import "WSMethodes.h"
#import "MFLogger.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property NSString *version;
@property NSString *build;
@property NSString *link;
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) WSMethodes *webServiceManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

