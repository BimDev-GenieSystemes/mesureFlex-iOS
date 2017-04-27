//
//  PastilleParser.h
//  Tap2Check
//
//  Created by Mohamed Mokrani on 27/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PastilleState.h"

@interface PastilleParser : NSObject

- (NSMutableArray*)getPastillesListFromJsonString:(NSString*)jsonstring;
- (PastilleState*)getPastilleFromJsonString:(NSString*)jsonString;

@end
