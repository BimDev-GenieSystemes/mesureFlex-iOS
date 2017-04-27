//
//  MasterViewController.m
//  test
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Inventaire.h"
#import "ProjectTableViewCell.h"
#import "MFLogger.h"
#import "Sector.h"
#import "SectorTableViewCell.h"
#import "HeaderCollectionReusableView.h"
#import "SectorCollectionViewCell.h"
#import "FlexViewController.h"
#import "DumpViewController.h"
#import "Reachability.h"
#import <CoreData/CoreData.h>
#import "Reachability.h"
#import "Parser.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceConfig.h"
#import "JDStatusBarNotification.h"
#import "UIBarButtonItem+Badge.h"
#import <Google/Analytics.h>
#import <mach/mach.h>
#import "AppDelegate.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "PastilleButton.h"

@interface MasterViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>{
    
    UIStoryboard *sb;
    BOOL wait;
    NSTimer *myTimer;
    NSMutableArray<Inventaire*> *inventaires;
    NSIndexPath *selecteIndex;
    int timeEx;

    
}
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.emptyDataSetSource = self;
    //self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    selecteIndex = [[NSIndexPath alloc] init];
    inventaires = [[NSMutableArray<Inventaire*> alloc] init];
    inventaires = [Inventaire selectInventaireFromLocalDataStore];
    [self.tableView reloadData];
    JDStatusBarNotification *statusBar = [[JDStatusBarNotification alloc] init];
    timeEx = 30;
    if ([[NSUserDefaults standardUserDefaults]
         stringForKey:@"sync"])
    timeEx = [[NSUserDefaults standardUserDefaults]
              stringForKey:@"sync"].intValue;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [MFLogger put:@"ViewController"];
    
    wait = NO;
    [self reachabilityDidChange];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:timeEx target:self selector:@selector(reachabilityDidChange) userInfo:nil repeats:YES];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
        
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                NSLog(@"Reachable");
                [JDStatusBarNotification dismiss];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                // -- Not reachable -- //
            {
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                NSString *currentTime = [dateFormatter stringFromDate:today];
                NSLog(@"User's current time in their preference format:%@",currentTime);
                NSString *msg = [NSString stringWithFormat:@"%@    Aucune connexion internet!",currentTime];
                [JDStatusBarNotification showWithStatus:msg styleName:JDStatusBarStyleError];
                break;
            }
                
        }
        
    }];
    
    
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor groupTableViewBackgroundColor];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"nodata.png"];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"This allows you to share photos from your library and save photos to your camera roll.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Please Allow Photo Access";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeModal:) name:@"CloseModal" object:nil];
    inventaires = [[NSMutableArray<Inventaire*> alloc] init];
    inventaires = [Inventaire selectInventaireFromLocalDataStore];
    
}

-(void)closeModal:(NSNotification *)notification{
    UIViewController *controller=(UIViewController *)notification.object;
    [MFLogger put:@"Telechargement done"];
    [controller dismissViewControllerAnimated:YES completion:^ {
        inventaires = [Inventaire selectInventaireFromLocalDataStore];
        [self.tableView reloadData];
        if (inventaires.count >0) {
            
            self.emptyImg.hidden = YES;

                
            self.tableView.hidden = NO;
            [self.changeList setEnabled:NO];
            [self.changeList setTintColor: [UIColor clearColor]];
        }
        
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Inventaire *object = inventaires[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return inventaires.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *name = [NSString stringWithFormat:@"%@ | %@ | %@",[inventaires objectAtIndex:indexPath.row].CampCustomer,[inventaires objectAtIndex:indexPath.row].CampSite,[inventaires objectAtIndex:indexPath.row].CampFullName];
    ProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.projectName.text = name;
    cell.projectIndicator.hidden = YES;
    NSString *poscap = [NSString stringWithFormat:@"%@/%@",[inventaires objectAtIndex:indexPath.row].CampPosNbr,[inventaires objectAtIndex:indexPath.row].CampTotalCount];
    cell.projectCapacity.text = poscap;
    
    
    //[09/04/17->12/04/17]
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *CampDateStart = [df dateFromString:[inventaires objectAtIndex:indexPath.row].CampDateStart];
    NSDate *CampDateEnd = [df dateFromString:[inventaires objectAtIndex:indexPath.row].CampDateEnd];
    [df setDateFormat:@"dd/MM/yy"];
    NSString *date = [NSString stringWithFormat:@"[%@ -> %@]",[df stringFromDate:CampDateStart],[df stringFromDate:CampDateEnd]];
    cell.projectDate.text = date;
    
    
    NSDate *today = [NSDate date];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *todayS = [df stringFromDate:today];
    NSDate *now = [df dateFromString:todayS];
    NSLog(@"%@     %@",[df stringFromDate:today],date);
    if ([self date:now isBetweenDate:[df dateFromString:[inventaires objectAtIndex:indexPath.row].CampDateStart] andDate:[df dateFromString:[inventaires objectAtIndex:indexPath.row].CampDateEnd]]) {
        
        cell.projectDate.textColor = [UIColor colorWithRed:97.0/255.0 green:188.0/255.0 blue:95.0/255.0 alpha:1.0];
    }
    



    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ((ProjectTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).projectIndicator.hidden = NO;
    
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ((ProjectTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).projectIndicator.hidden = YES;
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));

}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"MasterViewcontroller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    /*inventaires = [[NSMutableArray<Inventaire*> alloc] init];
    inventaires = [Inventaire selectInventaireFromLocalDataStore];
    [self.tableView reloadData];
    
    
    if (inventaires.count == 0) {
        
        
        self.tableView.hidden = YES;
        
        
    }
    
    else {
        
        self.tableView.hidden = NO;
        
    }*/
    
}

- (IBAction)OTAction:(id)sender {
    
    [MFLogger put:@"OTA"];
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reachability.reachableBlock = ^(Reachability *reachability) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Souhaitez-vous télécharger les données du serveur?"
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Oui"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self performSegueWithIdentifier:@"downdata" sender:nil];
                                 [reachability stopNotifier];
                                 
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Non"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [reachability stopNotifier];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    reachability.unreachableBlock = ^(Reachability *reachability) {
        [reachability stopNotifier];
    };
    [reachability startNotifier];
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}


- (void)reachabilityDidChange {
    
    @autoreleasepool {
        //report_memory();
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
                    
                    [self.navigationItem.rightBarButtonItems objectAtIndex:0].badgeValue = @"1";
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
                    [self.navigationItem.leftBarButtonItems objectAtIndex:1].badgeValue = @"0";
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
                        [request setTimeoutInterval:0.6*timeEx];
                        
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
                
                
                
            });
            
            
            
        };
        
        [reachability startNotifier];
        
    }
    
    
}




@end
