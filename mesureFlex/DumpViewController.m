//
//  DumpViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 16/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "DumpViewController.h"
#import "PastilleButton.h"
#import <CoreData/CoreData.h>
#import <Google/Analytics.h>

@interface DumpViewController ()
{
    NSMutableArray <PastilleButton*> *pbuttons;
    NSMutableArray <NSString*> *dates;
    NSMutableArray *historybyDate;
}
@end

@implementation DumpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pbuttons = [[NSMutableArray<PastilleButton*> alloc] init];
    dates = [[NSMutableArray<NSString*> alloc] init];
    historybyDate = [[NSMutableArray alloc] init];
    [self fetchData];
    if (historybyDate.count == 0)
        self.tableView.hidden = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"DumpViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return historybyDate.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[historybyDate objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *s = [NSString stringWithFormat:@"%@ (%lu)",[dates objectAtIndex:section],(unsigned long)[[historybyDate objectAtIndex:section] count]];
    return s;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dumpC" forIndexPath:indexPath];
    PastilleButton *pb = [[historybyDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *data = [NSString stringWithFormat:@"%@   %@  (%@)  %@",pb.timerValue,pb.name,pb.personNumber,pb.state.UsageDisplayText];
    cell.textLabel.text = data;
    return cell;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

-(void) fetchData {
    
    
    
    
    NSMutableArray<NSString*> *temp = [[NSMutableArray<NSString*> alloc] init];

    
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSMutableArray *datas2 = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity2];
    
    NSArray *fetchedObjects2 = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas2 = [[NSMutableArray alloc] initWithArray:fetchedObjects2];
    
    for (int i = 0 ; i < datas.count ; i++) {
        
        NSString *b_id = [[datas objectAtIndex:i] valueForKey:@"id"];
        NSString *person = [[datas objectAtIndex:i] valueForKey:@"person"];
        NSString *capacity = [[datas objectAtIndex:i] valueForKey:@"capacity"];
        NSString *state = [[datas objectAtIndex:i] valueForKey:@"state"];
        NSString *timestamp = [[datas objectAtIndex:i] valueForKey:@"timestamp"];
        
        PastilleButton *pb = [[PastilleButton alloc] init];
        pb.name = b_id;
        pb.state = [[PastilleState alloc] init];
        pb.state.UsageDisplayText = state;
        pb.timerValue = timestamp;
        pb.personNumber = [NSString stringWithFormat:@"%@/%@",person,capacity];
        NSLog(@"%@ : %@",[[datas objectAtIndex:i] valueForKey:@"sector_id"],_sector.sector_id);
        if ([[[datas objectAtIndex:i] valueForKey:@"sector_id"] isEqualToString:_sector.sector_id] && [[[datas objectAtIndex:i] valueForKey:@"inventaire_id"] isEqualToString:_sector.inventaire_id]) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *pDate = [dateFormatter dateFromString:timestamp];
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            NSString *pdateS = [dateFormatter stringFromDate:pDate];
            [dates addObject:pdateS];
            [pbuttons addObject:pb];
        }
        
        
        
    }
    
    pbuttons = [[pbuttons reverseObjectEnumerator] allObjects].copy;
    dates = [[dates reverseObjectEnumerator] allObjects].copy;
    
    
    for (int i = 0; i < dates.count ;i++) {
        
        if (![temp containsObject:[dates objectAtIndex:i]]) {
            
            [temp addObject:[dates objectAtIndex:i]];
            
        }
        
    }
    
    dates = [[NSMutableArray<NSString*> alloc] initWithArray:temp];
    
    for (int i = 0 ; i < dates.count ; i++) {
        NSMutableArray <PastilleButton*> *pbuttonsByDate = [[NSMutableArray <PastilleButton*> alloc] init];
        for (int j = 0; j < pbuttons.count ; j++) {
            NSString *timestamp = [pbuttons objectAtIndex:j].timerValue;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *pDate = [dateFormatter dateFromString:timestamp];
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            NSString *pdateS = [dateFormatter stringFromDate:pDate];
            
            if ([pdateS isEqualToString:[dates objectAtIndex:i]]) {
                
                [pbuttonsByDate addObject:[pbuttons objectAtIndex:j]];
                
            }
            
        }
        [historybyDate addObject:pbuttonsByDate];
    }

    
    [self.tableView reloadData];
}


- (IBAction)dumpAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
