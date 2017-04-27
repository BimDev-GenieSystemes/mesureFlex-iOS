//
//  UserParser.h
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inventaire.h"
@interface InventaireParser : NSObject

- (NSMutableArray*)getInventairesListFromJsonString:(NSString*)jsonstring;
- (Inventaire*)getInventaireFromJsonString:(NSString*)jsonString;



@end
