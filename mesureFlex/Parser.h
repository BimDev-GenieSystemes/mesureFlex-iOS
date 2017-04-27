//
//  Parser.h
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InventaireParser.h"
#import "SectorParser.h"
#import "ImageParser.h"
#import "PastilleParser.h"

@interface Parser : NSObject


@property(nonatomic, strong) InventaireParser *inventaireParser;
@property(nonatomic, strong) SectorParser *sectorParser;
@property(nonatomic, strong) ImageParser *imageParser;
@property(nonatomic, strong) PastilleParser *pastilleParser;
-(id)init;
@end
