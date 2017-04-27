//
//  MasterViewController.h
//  test
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlexViewController.h"
#import "GRRequestsManager.h"
@class DetailViewController;

@interface MasterViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GRRequestsManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString *version;
@property NSString *build;
@property NSString *link;
- (IBAction)OTAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeList;
@property (weak, nonatomic) IBOutlet UIImageView *emptyImg;

@end

