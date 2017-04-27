//
//  SectorTableViewController.m
//  Tap2Check
//
//  Created by Mohamed Mokrani on 22/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "SectorTableViewController.h"
#import "SectorTableViewCell.h"
#import "Sector.h"
#import <Google/Analytics.h>

@interface SectorTableViewController ()

@end

@implementation SectorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
    [_tapBehindGesture setNumberOfTapsRequired:1];
    [_tapBehindGesture setCancelsTouchesInView:NO]; //So the user can still interact with controls in the modal view
    [self.parentViewController.view.window  addGestureRecognizer:_tapBehindGesture];
    self.tapBehindGesture.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"SectorTableViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88.0;}


-(BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sectors.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Sector *obj = [_sectors objectAtIndex:indexPath.row];
    cell.sectorName.text = obj.name;
    if ([obj.sector_id isEqualToString:_selectedSector.sector_id]) {
        
        cell.sectorName.textColor = [UIColor redColor];
        
        
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Sector *obj = [_sectors objectAtIndex:indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (![obj.sector_id isEqualToString:_selectedSector.sector_id]) {
                
                NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:@"sector"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseList" object:self userInfo:dict];
                
            }
        
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        
    });
        
        
    
    
    
    
    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)tapBehindDetected:(UITapGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.view];
        
        if (![self.view pointInside:location withEvent:nil]) {
            [self.view.window removeGestureRecognizer:self.tapBehindGesture];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
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
@end
