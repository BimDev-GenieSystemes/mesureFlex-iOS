//
//  HistoryTableViewCell.h
//  MesureFlex
//
//  Created by UrbaProd1 on 24/11/2016.
//  Copyright © 2016 URBAPROD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pastilleView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *state;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timerValue;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *date;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *date2;

@end
