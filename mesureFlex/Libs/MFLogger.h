//
//  MFLogger.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFLogger : NSObject

+ (void) put : (NSString*) message;
+ (NSString*) get;
@end
