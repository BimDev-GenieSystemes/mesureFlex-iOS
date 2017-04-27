//
//  ViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 13/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "ViewController.h"
#import "PFUser.h"
#import "CSStickyHeaderFlowLayout.h"
#import "Inventaire.h"
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


@interface ViewController ()
{
    NSMutableArray<Inventaire*> *inventaires;
    NSMutableArray<Sector*> *sectors;
    Sector *selectedSector;
    UIStoryboard *sb;
    BOOL wait;
    NSTimer *myTimer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MFLogger put:@"ViewController"];
    __weak __typeof__(self) wself = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    wself.vc = (FlexViewController *)[sb instantiateViewControllerWithIdentifier:@"flexVC"];
    wait = NO;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reachabilityDidChange) userInfo:nil repeats:YES];
    [JDStatusBarNotification showWithStatus:@"Aucune connexion internet!" dismissAfter:0.0 styleName:JDStatusBarStyleError];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
        [self.changeList setEnabled:NO];
        [self.changeList setTintColor: [UIColor clearColor]];
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeModal:) name:@"CloseModal" object:nil];
    selectedSector = [[Sector alloc] init];
    sectors = [[NSMutableArray<Sector*> alloc] init];
    inventaires = [[NSMutableArray<Inventaire*> alloc] init];
    
    inventaires = [Inventaire selectInventaireFromLocalDataStore];
    
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [[inventaires objectAtIndex:section] getSectors].count;
    
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return inventaires.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    SectorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.layer.cornerRadius = 3.0;
    cell.layer.borderWidth = 1.0;
    cell.thumbPlan.contentMode = UIViewContentModeScaleAspectFit;
    cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    cell.sectorName.text = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].name;
    cell.historyButton.restorationIdentifier = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].sector_id;
    [cell.historyButton addTarget:self action:@selector(historyAction:) forControlEvents:UIControlEventTouchDown];
    if ([[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].thumbNail) {
        
        cell.thumbPlan.image = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].thumbNail;
        cell.thumbPlan.contentMode = UIViewContentModeScaleAspectFill;
        cell.thumbPlan.clipsToBounds = YES;
        cell.thumbPlan.layer.borderWidth = 1.0;
        cell.thumbPlan.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        cell.thumbPlan.layer.cornerRadius = 3.0;
    }
    
    else {
        cell.thumbPlan.image = [UIImage imageNamed:@"dwg_ic.png"];
        cell.thumbPlan.contentMode = UIViewContentModeScaleAspectFit;
        cell.thumbPlan.clipsToBounds = YES;
        cell.thumbPlan.layer.borderWidth = 0.0;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        float cellWidth = screenWidth / 4.5; //Replace the divisor with the column count requirement. Make sure to have it in float.
        CGSize size = CGSizeMake(cellWidth, cellWidth-50);
        
        return size;
        
    }
    else  {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        float cellWidth = screenWidth / 3.5; //Replace the divisor with the column count requirement. Make sure to have it in float.
        CGSize size = CGSizeMake(cellWidth, cellWidth-50);
        
        return size;
        
    }
    
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        footerview.inventaireName.text = [inventaires objectAtIndex:indexPath.section].CampFullName;
        reusableview = footerview;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (IBAction)listORgridAction:(id)sender {
    
    if ([[(UIBarButtonItem*)sender image] isEqual:[UIImage imageNamed:@"list"]]) {
        [(UIBarButtonItem*)sender setImage:[UIImage imageNamed:@"grid"]];
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
        
        
    }else{
        [(UIBarButtonItem*)sender setImage:[UIImage imageNamed:@"list"]];
        self.tableView.hidden = YES;
        self.collectionView.hidden = NO;
    }
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
     return [[inventaires objectAtIndex:section] getSectors].count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return inventaires.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.sectorName.text = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].name;
    cell.historyButton.restorationIdentifier = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row].sector_id;
    [cell.historyButton addTarget:self action:@selector(historyAction:) forControlEvents:UIControlEventTouchDown];
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //put your values, this is part of my code
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45.0f)];
    [view setBackgroundColor:self.tableView.backgroundColor];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50,view.center.y-10, 150, 20)];
    [lbl setFont:[UIFont systemFontOfSize:16]];
    [lbl setTextColor:[UIColor blackColor]];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(8,view.center.y-15, 30, 30)];
    img.image = [UIImage imageNamed:@"Folder-icon.png"];
    [view addSubview:img];
    [view addSubview:lbl];
    
    [lbl setText:[inventaires objectAtIndex:section].CampFullName];
    
    return view;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @autoreleasepool {
        selectedSector = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row];
        sectors = [[inventaires objectAtIndex:indexPath.section] getSectors];
        //[self performSegueWithIdentifier:@"flexView" sender:self];
        //if(!_vc)
        __weak __typeof__(FlexViewController*) vc = _vc;
        vc = (FlexViewController *)[sb instantiateViewControllerWithIdentifier:@"flexVC"];
        vc.sector = selectedSector;
        vc.sectors = [[NSMutableArray<Sector*> alloc] init];
        vc.sectors = sectors;
        __weak __typeof__(self) wself = self;
        [wself presentViewController:vc animated:YES completion:nil];
    }
    
    
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    @autoreleasepool {
        selectedSector = [[[inventaires objectAtIndex:indexPath.section] getSectors] objectAtIndex:indexPath.row];
        sectors = [[inventaires objectAtIndex:indexPath.section] getSectors];
        //[self performSegueWithIdentifier:@"flexView" sender:self];
        //if(!_vc)
        __weak __typeof__(FlexViewController*) vc = _vc;
        vc = (FlexViewController *)[sb instantiateViewControllerWithIdentifier:@"flexVC"];
        vc.sector = selectedSector;
        vc.sectors = [[NSMutableArray<Sector*> alloc] init];
        vc.sectors = sectors;
        __weak __typeof__(self) wself = self;
        [wself presentViewController:vc animated:YES completion:nil];
    }
    
    
}

-(void)historyAction:(UIButton*)sender
{
    [MFLogger put:@"Historique click"];
    
    for (Sector *sector in [Sector selectSectorFromLocalDataStore]) {
        
        if ([sector.sector_id isEqualToString:sender.restorationIdentifier]) {
            selectedSector = sector;
            break;
        }
        
    }
    [self performSegueWithIdentifier:@"history" sender:self];
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"ViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    inventaires = [[NSMutableArray<Inventaire*> alloc] init];
    inventaires = [Inventaire selectInventaireFromLocalDataStore];
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
    
    if (inventaires.count == 0) {
        
        
        self.tableView.hidden = YES;
        self.collectionView.hidden = YES;
        
        
    }
    
    else {
        
        self.tableView.hidden = YES;
        self.collectionView.hidden = NO;
        
        if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        {
            self.tableView.hidden = NO;
            self.collectionView.hidden = YES;
        }
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"flexView"]) {
        
        FlexViewController *destination = (FlexViewController*) segue.destinationViewController;
        destination.sector = selectedSector;
        destination.sectors = [[NSMutableArray<Sector*> alloc] init];
        destination.sectors = sectors;
        
    }
    
    else if ([segue.identifier isEqualToString:@"history"]) {
         DumpViewController *destination = (DumpViewController*) [[segue destinationViewController] topViewController];
        destination.sector = selectedSector;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

void report_memory(void)
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %llu", info.resident_size);
        [MFLogger put:[NSString stringWithFormat:@"Memory in use (in bytes): %llu", info.resident_size]];
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
        [MFLogger put:[NSString stringWithFormat:@"Error with task_info(): %s", mach_error_string(kerr)]];
    }
}

- (void)reachabilityDidChange {
    
    @autoreleasepool {
        //report_memory();
        Reachability *reachability = [Reachability reachabilityWithHostname:@"google.com"];
        
        reachability.reachableBlock = ^(Reachability *reachability) {
            
            NSError *error2;
            NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
            NSString *url = [API_URL stringByAppendingString:@"/update.php"];
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
                    
                    _version = [passage[i] valueForKey:@"version"];
                    _build = [passage[i] valueForKey:@"build"];
                    _link = [passage[i] valueForKey:@"link"];
                    
                }
                
                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                NSLog(@"v: %@ b: %@ l: %@",_version,_build,_link);
                
                if (version.doubleValue < _version.doubleValue && build.doubleValue < _build.doubleValue) {
                    
                    [self.navigationItem.leftBarButtonItems objectAtIndex:1].badgeValue = @"1";
                    NSString *valueToSave = _link;
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"link"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [MFLogger put:@"Mise a jour reçu"];
                    
                }
                
                else {
                    
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
                    NSString *wpcomment2 = [[items objectAtIndex:i] valueForKey:@"wpcomment2"];
                    NSString *wpcritical = [[items objectAtIndex:i] valueForKey:@"wpcritical"];
                    NSString *wpbookable = [[items objectAtIndex:i] valueForKey:@"wpbookable"];
                    NSString *wpcapcity = [[items objectAtIndex:i] valueForKey:@"wpcapcity"];
                    NSString *wpoptdata1 = [[items objectAtIndex:i] valueForKey:@"wpoptdata1"];
                    NSString *wpoptdata2 = [[items objectAtIndex:i] valueForKey:@"wpoptdata2"];
                    NSString *wpoptdata3 = [[items objectAtIndex:i] valueForKey:@"wpoptdata3"];
                    NSString *latlng = [[items objectAtIndex:i] valueForKey:@"latlng"];
                    NSString *state_id=@"-1";
                    NSString *wpstate =@"";
                    NSString *inventaire_id=@"";
                    
                    if ([state.lowercaseString isEqualToString:@"libre"]) {
                        
                        state_id = @"0";
                        
                    }
                    
                    else if ([state.lowercaseString isEqualToString:@"indetermine"] || [state.lowercaseString isEqualToString:@"indeterminé"]) {
                        
                        state_id = @"-1";
                        
                    }
                    
                    else if ([state.lowercaseString isEqualToString:@"trace"]) {
                        
                        state_id = @"2";
                        
                    }
                    
                    else {
                        
                        state_id = @"1";
                        
                    }
                    
                    
                    
                    NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
                    [rus setValue:b_id forKey:@"pastilleName"];
                    [rus setValue:capacity forKey:@"capacity"];
                    [rus setValue:person forKey:@"personNbr"];
                    [rus setValue:state forKey:@"state"];
                    [rus setValue:device forKey:@"device_id"];
                    [rus setValue:sector forKey:@"sector"];
                    [rus setValue:timestamp forKey:@"timestamp"];
                    NSString *url = [API_URL stringByAppendingString:@"/WSRV_PutCampRawData.php?"];
                    url = [NSString stringWithFormat:@"%@pastilleName=%@&capacity=%@&personNbr=%@&state=%@&device_id=%@&sector=%@&timestamp=%@&wphandle=%@&wpdatetime=%@&wpshape=%@&wpradius=%@&wpsite=%@&wpbuild=%@&wpfloor=%@&wpzone=%@&wpcluster=%@&wpplace=%@&wppt=%@&wpcomment=%@&wpclass=%@&wptype=%@&wpdir=%@&wpcommentt=%@&wpcritical=%@&wpbookable=%@&wpcapcity=%@&wpoptdata1=%@&wpoptdata2=%@&wpoptdata3=%@&latlng=%@&state_id=%@&wpState=%@&inventaire_id=%@",url,b_id,capacity,person,state,device,sector,timestamp,wphandle,wpdatetime,wpshape,wpradius,wpsite,wpbuild,wpfloor,wpzone,wpcluster,wpplace,wppt,wpcomment,wpclass,wptype,wpdir,wpcomment2,wpcritical,wpbookable,wpcapcity,wpoptdata1,wpoptdata2,wpoptdata3,latlng,state_id,wpstate,inventaire_id];
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
                [JDStatusBarNotification showWithStatus:msg dismissAfter:2.0 styleName:JDStatusBarStyleError];
                
            });
            
            
            
        };
        
        [reachability startNotifier];
        
    }
    
    
}



@end
