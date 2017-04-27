//
//  ProjectTableViewCell.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "ProjectTableViewCell.h"

@implementation ProjectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:NO];
    self.projectIndicator.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:135.0/255.0 blue:202.0/255.0 alpha:1.0];
    // Configure the view for the selected state
}

@end
