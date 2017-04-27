//
//  ProjectTableViewCell.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface ProjectTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *projectCapacity;
@property (weak, nonatomic) IBOutlet UILabel *projectDate;
@property (weak, nonatomic) IBOutlet UILabel *projectIndicator;

@end
