//
//  SectorParser.h
//  Tap2Check
//
//  Created by Mohamed Mokrani on 17/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sector.h"

@interface SectorParser : NSObject

- (NSMutableArray*)getSectorsListFromJsonString:(NSString*)jsonstring;
- (Sector*)getSectorFromJsonString:(NSString*)jsonString;

@end
