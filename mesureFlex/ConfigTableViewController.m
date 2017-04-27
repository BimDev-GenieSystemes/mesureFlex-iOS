//
//  ConfigTableViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 27/02/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "ConfigTableViewController.h"
#import <Google/Analytics.h>

@interface ConfigTableViewController ()
{
    NSString *link;
}
@end

@implementation ConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSLog(@"%@ : %@",version,build);
    self.versionLabel.text = version;
    self.buildLabel.text = build;
    self.dateLabel.text = [self GetBuildDate];
    self.badge.layer.cornerRadius = 15.0;
    link = [[NSUserDefaults standardUserDefaults]
            stringForKey:@"link"];
    
    NSInteger val = [[NSUserDefaults standardUserDefaults]
                     stringForKey:@"sync"].integerValue;
    
    if (!val) {
        
        val = 30;
        [[NSUserDefaults standardUserDefaults] setObject:@"30" forKey:@"sync"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    switch (val) {
        case 15:
            
            [_syncroSegment setSelectedSegmentIndex:0];
            
            break;
            
        case 30:
            
            [_syncroSegment setSelectedSegmentIndex:1];
            
            break;
            
        case 60:
            
            [_syncroSegment setSelectedSegmentIndex:2];
            
            break;
            
        default:
            break;
    }
    
    link = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"link"];
    self.badge.hidden = YES;
    self.updateMessage.text = @"Votre version est à jour";
    [self.updateCell setUserInteractionEnabled:NO];
    if (link.length > 0) {
        
        self.updateMessage.text = @"Mettre à jour";
        self.updateMessage.textColor = [UIColor redColor];
        self.badge.hidden = NO;
        [self.updateCell setUserInteractionEnabled:YES];
    }
    NSString *swip = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"swipe"];
    
    if ([swip isEqualToString:@"off"]) {
        
        [_switchButton setOn:NO animated:NO];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
    
- (NSString *)GetBuildDate {
    NSString *buildDate;
    
    // Get build date and time, format to 'yyMMddHHmm'
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@", [NSString stringWithUTF8String:__DATE__], [NSString stringWithUTF8String:__TIME__]];
    
    // Convert to date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"LLL d yyyy HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateStr];
   
    // Set output format and convert to string
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    buildDate = [dateFormat stringFromDate:date];
    
    
    return buildDate;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"ConfigTableViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
    
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0 &&  indexPath.row == 3 && link.length > 0) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        
    }
    
    
}

- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)swipe:(id)sender {
    
    UISwitch *t = (UISwitch*) sender;
    
    if (t.isOn) {
        NSLog(@"on");
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"swipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"off" forKey:@"swipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (IBAction)syncroChange:(id)sender {
    
    switch (self.syncroSegment.selectedSegmentIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:@"15" forKey:@"sync"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"30" forKey:@"sync"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:@"60" forKey:@"sync"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }
    
}
@end
