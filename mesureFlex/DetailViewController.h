//
//  DetailViewController.h
//  test
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inventaire.h"
#import "FlexViewController.h"


@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) Inventaire *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) FlexViewController *vc;
@end

