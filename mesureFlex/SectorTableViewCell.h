//
//  SectorTableViewCell.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 15/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbPlan;
@property (weak, nonatomic) IBOutlet UILabel *sectorName;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@end
