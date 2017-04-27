//
//  PastilleStateTableViewCell.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 17/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "PastilleStateTableViewCell.h"

@implementation PastilleStateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pastilleStateButton.layer.cornerRadius = 25.0;
    self.pastilleStateButton.layer.borderWidth = 1.0;
    self.pastilleStateButton.layer.borderColor = self.pastilleStateText.textColor.CGColor;
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *color = self.pastilleStateButton.backgroundColor;
    [super setSelected:selected animated:animated];
    
    if (selected){
        self.pastilleStateButton.backgroundColor = color;
        self.pastilleStateButton.layer.borderWidth = 1.0;
        self.pastilleStateButton.layer.borderColor = self.pastilleStateText.textColor.CGColor;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    UIColor *color = self.pastilleStateButton.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        self.pastilleStateButton.backgroundColor = color;
        self.pastilleStateButton.layer.borderWidth = 1.0;
        self.pastilleStateButton.layer.borderColor = self.pastilleStateText.textColor.CGColor;
    }
}

@end
