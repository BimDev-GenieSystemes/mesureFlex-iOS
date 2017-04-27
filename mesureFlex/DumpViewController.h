//
//  DumpViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 16/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sector.h"

@interface DumpViewController : UIViewController
- (IBAction)dumpAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Sector *sector;
@end
