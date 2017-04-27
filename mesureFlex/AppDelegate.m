//
//  AppDelegate.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 13/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "Parser.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceConfig.h"
#import "JDStatusBarNotification.h"
#import <Google/Analytics.h>
#import <CoreLocation/CoreLocation.h>
#import "MasterViewController.h"
#import "DetailViewController.h"



@interface AppDelegate () <UISplitViewControllerDelegate>
{
    NSTimer *myTimer;
    Parser *parser;
    BOOL wait;
    NSString *notif;
    UIBackgroundTaskIdentifier bgTask;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    [splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    splitViewController.delegate = self;
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    [self createWSObject];
    [self createParserObject];
    [MFLogger put:@"App lancée"];

    
    wait = NO;
    
     
    
    return YES;
}

-(void) applicationDidEnterBackground:(UIApplication *)application {
    
    [MFLogger put:@"App en veille"];
    [self saveContext];
    
    
    // bgTask is instance variable
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //[application endBackgroundTask:self->bgTask];
            //self->bgTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([application backgroundTimeRemaining] > 1.0) {
            // Start background service synchronously
            //[[BackgroundCleanupService getInstance] run];
            //[self reachabilityChange];
            notif = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"notif"];
            
            if (!notif) {
                
                notif = @"NO";
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"notif"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reachabilityChange) userInfo:nil repeats:YES];
            }
            
            
        }
        
        //[application endBackgroundTask:self->bgTask];
        //self->bgTask = UIBackgroundTaskInvalid;
        
    });
    
   /* UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertBody = @"Une mise est disponible";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];*/
}

-(void) applicationWillEnterForeground:(UIApplication *)application {
    
    [myTimer invalidate];
    
    @autoreleasepool {
        
        Reachability *reachability = [Reachability reachabilityWithHostname:@"google.com"];
        
        reachability.reachableBlock = ^(Reachability *reachability) {
            
            NSError *error2;
            NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
            NSString *url = [API_URL stringByAppendingString:@"/WSRV_GetBinUpdates.php"];
            NSMutableURLRequest *request2 = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:rus error:&error2];
            
            AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
            [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSError* error = NULL;
                NSData* data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
                
                NSArray* passage = [json copy];
                
                
                
                
                for (int i = 0; i < [passage count]; i++) {
                    NSError* err = nil;
                    
                    NSString *val = [NSString stringWithFormat:@"%d",i];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[passage valueForKey:val] options:NSJSONWritingPrettyPrinted error:&err];
                    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    _version = [[passage valueForKey:val] valueForKey:@"BinVersion"];
                    _build = [[passage valueForKey:val]valueForKey:@"BinBuild"];
                    _link = [[passage valueForKey:val] valueForKey:@"BinURL"];
                }
                
                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                NSLog(@"v: %@ b: %@ l: %@",_version,_build,_link);
                
                if (build.doubleValue < _build.doubleValue) {
                    
                    NSString *valueToSave = _link;
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"link"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                    
                    [MFLogger put:@"Mise a jour reçu"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"notif"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                
                else {
                    
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    NSString *valueToSave = @"";
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"link"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            [operation2 start];
            
            
        reachability.unreachableBlock = ^(Reachability *reachability) {
            
            
            
        };
        
        [reachability startNotifier];
        
    };
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MFLogger put:@"App terminée"];
    [self saveContext];
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]]
        && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
        
    }
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // When the application is successfully registered for push notifications, the phone's
    // PADInstallation must be updated with the device token.
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // This delegate is called when a push notification is received. We forward the notification
    // data and application state to a custom notification handling method.
    
    [self handleEventWithPayload:userInfo applicationState:application.applicationState];
}

- (void)handleEventWithPayload:(NSDictionary *)payload applicationState:(UIApplicationState)applicationState {
    // If the notification is not an event, do nothing.
    }
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.urbaprod.dragus.Tap2Check" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mesureFlexData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mesureFlexData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        return _managedObjectContext;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"core_data"
                                                                  action:@"save_context"
                                                                   label:[NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]]
                                                                   value:nil] build]];
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)createParserObject {
    parser = [[Parser alloc] init];
}

- (void)createWSObject {
    self.webServiceManager = [[WSMethodes alloc] init];
    self.webServiceManager.delegate = self;
}

- (void)errorReceived:(NSString *)cachedResponse FromUrlKey:(NSString *)urlKey {
    NSLog(@"%@ errrror", urlKey);
}

- (void)dataReceived:(NSString *)data FromWSCallName:(NSString *)WSCallName {
    
    // Your code to run on the main queue/thread
    
    
}

- (void) reachabilityChange {
    
    @autoreleasepool {
        //report_memory();
        notif = [[NSUserDefaults standardUserDefaults]
                 stringForKey:@"notif"];
        
        if ([notif isEqualToString:@"YES"]) {
            
            [myTimer invalidate];
            
        }
        
        Reachability *reachability = [Reachability reachabilityWithHostname:@"google.com"];
        
        reachability.reachableBlock = ^(Reachability *reachability) {
            
            NSError *error2;
            NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
            NSString *url = [API_URL stringByAppendingString:@"/WSRV_GetBinUpdates.php"];
            NSMutableURLRequest *request2 = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:rus error:&error2];
            
            AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
            [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSError* error = NULL;
                NSData* data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
                
                NSArray* passage = [json copy];
                
                
                
                
                for (int i = 0; i < [passage count]; i++) {
                    NSError* err = nil;
                    
                    NSString *val = [NSString stringWithFormat:@"%d",i];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[passage valueForKey:val] options:NSJSONWritingPrettyPrinted error:&err];
                    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    _version = [[passage valueForKey:val] valueForKey:@"BinVersion"];
                    _build = [[passage valueForKey:val]valueForKey:@"BinBuild"];
                    _link = [[passage valueForKey:val] valueForKey:@"BinURL"];
                }
                
                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                NSLog(@"v: %@ b: %@ l: %@",_version,_build,_link);
                
                if (build.doubleValue < _build.doubleValue && [notif isEqualToString:@"NO"]) {
                    
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                    localNotification.alertBody = @"Une mise est disponible";
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    NSString *valueToSave = _link;
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"link"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                    
                    [MFLogger put:@"Mise a jour reçu"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"notif"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    notif = @"YES";
                    
                }
                
                else {
                    
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    NSString *valueToSave = @"";
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"link"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            [operation2 start];
            
            if (wait == NO) {
                
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:[self managedObjectContext]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = %@", @"FALSE"];
                [fetchRequest setPredicate:predicate];
                [fetchRequest setEntity:entity];
                
                NSError *error;
                @try {
                    
                    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
                    
                    for (int i = 0; i < items.count; i++) {
                        wait = YES;
                        [MFLogger put:@"Load data for server"];
                        NSString *b_id = [[items objectAtIndex:i] valueForKey:@"id"];
                        NSString *person = [[items objectAtIndex:i] valueForKey:@"person"];
                        NSString *capacity = [[items objectAtIndex:i] valueForKey:@"capacity"];
                        NSString *state = [[items objectAtIndex:i] valueForKey:@"state"];
                        NSString *sector = [[items objectAtIndex:i] valueForKey:@"sector"];
                        NSString *device = [[items objectAtIndex:i] valueForKey:@"device_id"];
                        NSString *timestamp = [[items objectAtIndex:i] valueForKey:@"timestamp"];
                        NSString *wphandle = [[items objectAtIndex:i] valueForKey:@"wphandle"];
                        NSString *wpdatetime = [[items objectAtIndex:i] valueForKey:@"wpdatetime"];
                        NSString *wpshape = [[items objectAtIndex:i] valueForKey:@"wpshape"];
                        NSString *wpradius = [[items objectAtIndex:i] valueForKey:@"wpradius"];
                        NSString *wpsite = [[items objectAtIndex:i] valueForKey:@"wpsite"];
                        NSString *wpbuild = [[items objectAtIndex:i] valueForKey:@"wpbuild"];
                        NSString *wpfloor = [[items objectAtIndex:i] valueForKey:@"wpfloor"];
                        NSString *wpzone = [[items objectAtIndex:i] valueForKey:@"wpzone"];
                        NSString *wpcluster = [[items objectAtIndex:i] valueForKey:@"wpcluster"];
                        NSString *wpplace = [[items objectAtIndex:i] valueForKey:@"wpplace"];
                        NSString *wppt = [[items objectAtIndex:i] valueForKey:@"wppt"];
                        NSString *wpcomment = [[items objectAtIndex:i] valueForKey:@"wpcomment"];
                        NSString *wpclass = [[items objectAtIndex:i] valueForKey:@"wpclass"];
                        NSString *wptype = [[items objectAtIndex:i] valueForKey:@"wptype"];
                        NSString *wpdir = [[items objectAtIndex:i] valueForKey:@"wpdir"];
                        NSString *wpcritical = [[items objectAtIndex:i] valueForKey:@"wpcritical"];
                        NSString *wpbookable = [[items objectAtIndex:i] valueForKey:@"wpbookable"];
                        NSString *wpcapcity = [[items objectAtIndex:i] valueForKey:@"wpcapcity"];
                        NSString *wpoptdata1 = [[items objectAtIndex:i] valueForKey:@"wpoptdata1"];
                        NSString *wpoptdata2 = [[items objectAtIndex:i] valueForKey:@"wpoptdata2"];
                        NSString *wpoptdata3 = [[items objectAtIndex:i] valueForKey:@"wpoptdata3"];
                        NSString *latlng = [[items objectAtIndex:i] valueForKey:@"latlng"];
                        NSString *state_id = [[items objectAtIndex:i] valueForKey:@"state_id"];
                        NSString *wpstate = [[items objectAtIndex:i] valueForKey:@"wpstate"];
                        NSString *inventaire_id = [[items objectAtIndex:i] valueForKey:@"inventaire_id"];
                        
                        NSString *wpcountable = [[items objectAtIndex:i] valueForKey:@"wpcountable"];
                        
                        NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
                        [rus setValue:b_id forKey:@"pastilleName"];
                        [rus setValue:capacity forKey:@"capacity"];
                        [rus setValue:person forKey:@"personNbr"];
                        [rus setValue:state forKey:@"state"];
                        [rus setValue:device forKey:@"device_id"];
                        [rus setValue:sector forKey:@"sector"];
                        [rus setValue:timestamp forKey:@"timestamp"];
                        NSString *url = [API_URL stringByAppendingString:@"/WSRV_PutCampRawData.php?"];
                        url = [NSString stringWithFormat:@"%@pastilleName=%@&capacity=%@&personNbr=%@&state=%@&device_id=%@&sector=%@&timestamp=%@&wphandle=%@&wpdatetime=%@&wpshape=%@&wpradius=%@&wpsite=%@&wpbuild=%@&wpfloor=%@&wpzone=%@&wpcluster=%@&wpplace=%@&wppt=%@&wpcomment=%@&wpcommentt=%@&wpclass=%@&wptype=%@&wpdir=%@&wpcritical=%@&wpbookable=%@&wpcapacity=%@&wpoptdata1=%@&wpoptdata2=%@&wpoptdata3=%@&latlng=%@&state_id=%@&wpState=%@&inventaire_id=%@&wpcountable=%@",url,b_id,capacity,person,state,device,sector,timestamp,wphandle,wpdatetime,wpshape,wpradius,wpsite,wpbuild,wpfloor,wpzone,wpcluster,wpplace,wppt,wpcomment,wpcomment,wpclass,wptype,wpdir,wpcritical,wpbookable,wpcapcity,wpoptdata1,wpoptdata2,wpoptdata3,latlng,state_id,wpstate,inventaire_id,wpcountable];
                        NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        encoded = [encoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:encoded parameters:rus error:&error];
                        
                        [[items objectAtIndex:i] setValue:@"TRUE" forKey:@"saved"];
                        [MFLogger put:url];
                        
                        if (![[self managedObjectContext] save:nil]) {
                            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                        }
                        
                        else {
                            NSLog(@"Save! %@ %@", error, [error localizedDescription]);
                        }
                        [request setTimeoutInterval:0.6*1];
                        
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            // Code for success
                            NSLog(@" yeaaah %@",operation.responseString);
                            
                            
                            /*NSError* error = NULL;
                             NSData* data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                             
                             NSDictionary* json = [NSJSONSerialization
                             JSONObjectWithData:data
                             options:kNilOptions
                             error:&error];
                             
                             NSArray* passage = [json copy];*/
                            [MFLogger put:@"Push to server succes"];
                            
                            
                            
                            
                            wait = NO;
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"nooo %@",operation.responseString);
                            
                            wait = NO;
                            [MFLogger put:@"Push to server error"];
                            [[items objectAtIndex:i] setValue:@"FALSE" forKey:@"saved"];
                            if (![[self managedObjectContext] save:nil]) {
                                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                            }
                            
                            else {
                                NSLog(@"Save! %@ %@", error, [error localizedDescription]);
                            }
                            [MFLogger put:@"update local data"];
                        }];
                        [operation start];
                        
                    }
                    
                } @catch (NSException *exception) {
                    
                    [MFLogger put:exception.description];
                    
                } @finally {
                    
                }
                
                
            }
            
            
            
            
            
            //[[items firstObject] setValue:self.name forKey:@"name"];
            
            // Save the object to persistent store
            
            
        };
        
        reachability.unreachableBlock = ^(Reachability *reachability) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                NSString *currentTime = [dateFormatter stringFromDate:today];
                NSLog(@"User's current time in their preference format:%@",currentTime);
                NSString *msg = [NSString stringWithFormat:@"%@    Aucune connexion internet!",currentTime];
                
            });
            
            
            
        };
        
        [reachability startNotifier];
        
    }
    
    
}



void onUncaughtException(NSException* exception)
{
    NSLog(@"uncaught exception: %@", @"jj");
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder
                    createExceptionWithDescription:exception.description  // Exception description. May be truncated to 100 chars.
                    withFatal:@YES] build]];
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    NSString *msg = [NSString stringWithFormat:@"erreur : %@",exception.description];
    [MFLogger put:msg];
}


@end
