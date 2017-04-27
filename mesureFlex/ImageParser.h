//
//  ImageParser.h
//  Tap2Check
//
//  Created by Mohamed Mokrani on 21/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlanFragment.h"

@interface ImageParser : NSObject

- (NSMutableArray*)getImagesListFromJsonString:(NSString*)jsonstring;
- (PlanFragment*)getImageFromJsonString:(NSString*)jsonString;

@end
