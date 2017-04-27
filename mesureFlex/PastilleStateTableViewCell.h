//
//  PastilleStateTableViewCell.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 17/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastilleStateTableViewCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pastilleStateButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pastilleStateText;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *pastilleStateIcon;
@end
