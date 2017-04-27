//
//  ZUILabel.m
//  Dragus
//
//  Created by Mohamed Mokrani on 17/05/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "ZUILabel.h"

@implementation ZUILabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (Class) layerClass
{
    return [CATiledLayer class];
}

@end
