//
//  WSMethodes.h
//  Thimble
//
//  Created by Fares Ben Ammar on 18/03/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceManager.h"

@interface WSMethodes : WebServiceManager

//USER WS

- (void) GetInventaires:(NSMutableDictionary *)Attributes_Values;
- (void) GetSectors:(NSMutableDictionary *)Attributes_Values;
- (void) GetSectors;
- (void) GetImages;
- (void) GetPastilles;
@end
