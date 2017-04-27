//
//  ConfigTableViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 27/02/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigTableViewController : UITableViewController
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *badge;
@property (weak, nonatomic) IBOutlet UILabel *updateMessage;
- (IBAction)swipe:(id)sender;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateCell;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
- (IBAction)syncroChange:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *syncroSegment;

@end
