//
//  TableViewController.m
//  MesureFlex
//
//  Created by UrbaProd1 on 24/11/2016.
//  Copyright © 2016 URBAPROD. All rights reserved.
//

#import "TableViewController.h"
#import "Sector.h"
#import "HistoryTableViewCell.h"
#import <UIKit/UIKit.h>
#import <Google/Analytics.h>

@interface TableViewController ()
{
    NSMutableArray<PastilleButton*> *pbuttons;
    NSTimer *myTimer;
}
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pbuttons = [[NSMutableArray<PastilleButton*> alloc] init];
    [self fetchData];
    NSDate *today = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *tod = [format stringFromDate:today];
    self.navigationItem.title = [NSString stringWithFormat:@"Historique du %@ (%@)",_pastilleClicked.name,tod];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _pastillesButton = [[NSMutableArray<PastilleState*> alloc] init];
    if (_pastilleClicked.capacity.intValue == 1){
        _pastillesButton = [PastilleState selectSectorFromLocalDataStore:@"S":_pastilleClicked.inventaire_id];
    }
    else{
        _pastillesButton = [PastilleState selectSectorFromLocalDataStore:@"M":_pastilleClicked.inventaire_id];    }
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTable) userInfo:nil repeats:YES];

}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"TableViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateTable {
    
    [self.tableView reloadData];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSMutableArray<PastilleState*> *ps = [[NSMutableArray<PastilleState*> alloc] init];
    ps = [PastilleState selectSectorFromLocalDataStore];
    
    NSMutableArray<NSNumber*> *pss = [[NSMutableArray<NSNumber*> alloc] init];
    
    for (int i = 0; i < ps.count ; i++) {
        
        NSNumber *n = [[NSNumber alloc] initWithInt:0];
        [pss addObject:n];
    }
    
    for (int i = 0; i < pbuttons.count ; i++) {
        
        PastilleButton *pb1 = [pbuttons objectAtIndex:i];
        
        NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat:@"hh:mm:ss"];
        NSDate *date = [dateF dateFromString:pb1.chronoValue];
        NSString *min = @"00:00:00";
        NSDate *minD = [dateF dateFromString:min];
        
        NSTimeInterval timeInterval = [date timeIntervalSinceDate:minD];
        
        
        
        
        for (int i = 0; i < ps.count ; i++) {
            
            if ([[ps objectAtIndex:i].UsageDisplayText isEqualToString:pb1.state.UsageDisplayText]) {
                
                NSNumber *newVal = [[NSNumber alloc] initWithInt:[pss objectAtIndex:i].intValue+timeInterval];
                [pss setObject:newVal atIndexedSubscript:i];
                
            }
        }
        
        
        
        
    }
    
    
    for (int i = 0; i < ps.count ; i++) {
        
        if ([pss objectAtIndex:i].intValue > 0)
        [items addObject:[PNPieChartDataItem dataItemWithValue:[pss objectAtIndex:i].intValue color:[self colorFromHexString:[ps objectAtIndex:i].UsageHexColor] description:[ps objectAtIndex:i].UsageDisplayText]];
    }
    
    if (items.count > 0) {
        
        _pieChart.items = [[NSArray alloc] initWithArray:items.copy];
        _pieChart.descriptionTextColor = [UIColor whiteColor];
        _pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:10.0];
        [_pieChart strokeChart];
        _pieChart.displayAnimated = NO;
        
        self.pieChart.legendStyle = PNLegendItemStyleStacked;
        UIView *legend = [self.pieChart getLegendWithMaxWidth:200];
        
        //Move legend to the desired position and add to view
        [legend setFrame:CGRectMake(10, 10, legend.frame.size.width, legend.frame.size.height)];
        [self.view addSubview:legend];
        
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return @"En cours";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pbuttons.count;
}

-(void) fetchData {
    
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSMutableArray *datas2 = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id LIKE %@", _pastilleClicked.name];
    [fetchRequest setPredicate:predicate];
    
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
        NSString *state = [[datas objectAtIndex:i] valueForKey:@"state"];
        NSString *timestamp = [[datas objectAtIndex:i] valueForKey:@"timestamp"];
        
        PastilleButton *pb = [[PastilleButton alloc] init];
        pb.name = b_id;
        pb.state = [[PastilleState alloc] init];
        pb.state.UsageDisplayText = state;
        pb.timerValue = timestamp;
        pb.personNumber = person;
        pb.done = @"0";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date  = [NSDate date];
        NSString *today = [dateFormatter stringFromDate:date];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *pDate = [dateFormatter dateFromString:timestamp];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *pdateS = [dateFormatter stringFromDate:pDate];
        
        if ([today isEqualToString:pdateS] && [[[datas objectAtIndex:i] valueForKey:@"sector_id"] isEqualToString:_sector.sector_id] && [[[datas objectAtIndex:i] valueForKey:@"inventaire_id"] isEqualToString:_sector.inventaire_id])
        [pbuttons addObject:pb];


    }
    BOOL notYet = YES;
    
    if (pbuttons.count == 0)
        notYet = NO;
    
    while (notYet) {
       
        for (int i = 0 ; i < pbuttons.count ; i++) {
            
            if (i <= pbuttons.count-2 && pbuttons.count > 1) {
                PastilleButton *pb1 = [pbuttons objectAtIndex:i];
                PastilleButton *pb2 = [pbuttons objectAtIndex:i+1];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *pDate1 = [dateFormatter dateFromString:pb1.timerValue];
                NSDate *pDate2 = [dateFormatter dateFromString:pb2.timerValue];
                NSTimeInterval distanceBetweenDates = [pDate2 timeIntervalSinceDate:pDate1];
                NSInteger hoursBetweenDates = distanceBetweenDates;
                
                if (hoursBetweenDates <= 5) {
                    
                    [pbuttons removeObjectAtIndex:i];
                    notYet = YES;
                    break;
                }
                
            }
            
            else if (i == pbuttons.count-1)
                notYet = NO;
            
            
        }
        
        
    }
    
    notYet = YES;
    
    if (pbuttons.count == 0)
        notYet = NO;
    
    while (notYet) {
        
        for (int i = 0; i < pbuttons.count ;i++) {
            
            if (i< pbuttons.count-1) {
                
                if ([[pbuttons objectAtIndex:i].state.UsageDisplayText isEqualToString:[pbuttons objectAtIndex:i+1].state.UsageDisplayText]) {
                    [pbuttons removeObjectAtIndex:i];
                    notYet = YES;
                    break;
                }
                
            }
            
            else if (pbuttons.count-1==i)
                notYet = NO;
            
        }
        
    }
    
    
    
    NSMutableArray<PastilleButton*> *pbuttons2 = [[NSMutableArray<PastilleButton*> alloc] init];
    
    for (int i = 0; i < pbuttons.count ;i++) {
        
        if (![pbuttons2 containsObject:[pbuttons objectAtIndex:i]]) {
            
            [pbuttons2 addObject:[pbuttons objectAtIndex:i]];
            
        }
        
    }
    
    [pbuttons removeAllObjects];
    if (pbuttons2.count > 0)
    pbuttons = [[NSMutableArray<PastilleButton*> alloc] initWithArray:[pbuttons2 reverseObjectEnumerator].allObjects];
    
    [self.tableView reloadData];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tbcell" forIndexPath:indexPath];
    cell.state.text = [pbuttons objectAtIndex:indexPath.row].state.UsageDisplayText;
    cell.pastilleView.layer.cornerRadius = 15.0;
    cell.date.text = [pbuttons objectAtIndex:indexPath.row].timerValue;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *pDate1 = [dateFormatter dateFromString:[pbuttons objectAtIndex:indexPath.row].timerValue];
    NSDate *pDate2;
    if (indexPath.row > 0)
    pDate2 = [dateFormatter dateFromString:[pbuttons objectAtIndex:indexPath.row-1].timerValue];
    else
         pDate2 = [NSDate date];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *date = [dateFormatter stringFromDate:pDate1];
    NSString *date2 = [dateFormatter stringFromDate:pDate2];
    
    cell.date.text = [NSString stringWithFormat:@"%@ ]",date2];
    cell.date2.text = [NSString stringWithFormat:@"[ %@",date];
    NSTimeInterval timeInterval = [pDate2
                                   timeIntervalSinceDate:pDate1];
    NSLog(@"time interval %f",timeInterval);
    
    //300 seconds count down
    NSTimeInterval timeIntervalCountDown = timeInterval;
    
    NSDate *timerDate = [NSDate
                         dateWithTimeIntervalSince1970:timeIntervalCountDown];
    
    // Create a date formatter
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    cell.timerValue.text = timeString;
    [pbuttons objectAtIndex:indexPath.row].chronoValue = timeString;
    for (int i = 0; i < _pastillesButton.count; i++) {
        
        PastilleState *pastille = [_pastillesButton objectAtIndex:i];
        if([[pbuttons objectAtIndex:indexPath.row].state.UsageDisplayText.lowercaseString isEqualToString:pastille.UsageDisplayText.lowercaseString]) {
            
                cell.pastilleView.backgroundColor = [self colorFromHexString:[_pastillesButton objectAtIndex:i].UsageHexColor];
                [cell.pastilleView setImage:[_pastillesButton objectAtIndex:i].iconImage forState:UIControlStateNormal];
                [cell.pastilleView setImageEdgeInsets:UIEdgeInsetsMake(cell.pastilleView.frame.size.height/4, cell.pastilleView.frame.size.height/4, cell.pastilleView.frame.size.height/4, cell.pastilleView.frame.size.height/4)];
                
            
            break;
        }
        
        
    }
    
    return cell;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(BOOL) shouldAutorotate {
    return YES;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)updateTableContentInset {
    NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat contentInsetTop = self.tableView.bounds.size.height;
    for (NSInteger i = 0; i < numRows; i++) {
        contentInsetTop -= [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (contentInsetTop <= 0) {
            contentInsetTop = 0;
            break;
        }
    }
    self.tableView.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0);
}

@end
