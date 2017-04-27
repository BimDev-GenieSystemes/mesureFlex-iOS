//
//  Parser.m
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import "Parser.h"
#import "InventaireParser.h"
@implementation Parser
- (id)init {
    
    self.inventaireParser = [[InventaireParser alloc] init];
    self.sectorParser = [[SectorParser alloc] init];
    self.imageParser = [[ImageParser alloc] init];
    self.pastilleParser = [[PastilleParser alloc] init];
    return self;
}

@end
