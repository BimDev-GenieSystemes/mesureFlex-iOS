//
//  SectorParser.m
//  Tap2Check
//
//  Created by Mohamed Mokrani on 17/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "SectorParser.h"
#import "WebServiceConfig.h"

@implementation SectorParser
- (NSMutableArray*)getSectorsListFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    return [self getSectorsListFromNSArray:json];
}

- (NSMutableArray*)getSectorsListFromNSArray:(NSDictionary*)listUsers
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSArray* passage = [listUsers copy];
    
    for (int i = 0; i < [passage count]; i++) {
        NSError* err = nil;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:passage[i] options:NSJSONWritingPrettyPrinted error:&err];
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        Sector* u = [[Sector alloc] initWithString:jsonString error:&err];
        if (!u) {
            u = [[Sector alloc] init];
            u.sector_id = [passage[i] valueForKey:@"id"];
            u.level = [passage[i] valueForKey:@"level"];
            u.inventaire_id = [passage[i] valueForKey:@"inventaire_id"];
            u.name = [passage[i] valueForKey:@"name"];
            u.wpFile = [API_URL stringByAppendingString:[passage[i] valueForKey:@"wp"]];
            
            
            
        }
        // add names
        
        [list addObject:u];
    }
    return list;
}

- (Sector*)getSectorFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:kNilOptions
                     error:&error];
    
    return [self GetSector:json];
    
    
}

- (Sector*)GetSector:(NSArray*)listUsers
{
    NSArray* passage = [listUsers valueForKey:@"data"];
    if (!passage) {
        passage = [listUsers valueForKey:@"object"];
    }
    
    NSError* err = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:listUsers[0] options:NSJSONWritingPrettyPrinted error:&err];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Sector* u = [[Sector alloc] initWithString:jsonString error:&err];
    
    
    //add names
    return u;
}

@end
