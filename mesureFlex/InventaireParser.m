//
//  UserParser.m
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import "InventaireParser.h"
#import "Inventaire.h"
@implementation InventaireParser

- (NSMutableArray*)getInventairesListFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    return [self getInventairesListFromNSArray:json];
}

- (NSMutableArray*)getInventairesListFromNSArray:(NSDictionary*)listUsers
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSMutableArray* passage = [listUsers copy];
    for (int i = 0; i < [passage count]; i++) {
        NSError* err = nil;
        
        NSString *val = [NSString stringWithFormat:@"%d",i];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[passage valueForKey:val] options:NSJSONWritingPrettyPrinted error:&err];
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        Inventaire* u = [[Inventaire alloc] initWithString:jsonString error:&err];
        //u.inventaire_id = [passage[i] valueForKey:@"id"];
        
        [list addObject:u];
    }
    return list;
}

- (Inventaire*)getInventaireFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    return [self GetInventaire:json];
    
    
}

- (Inventaire*)GetInventaire:(NSArray*)listUsers
{
    NSArray* passage = [listUsers valueForKey:@"data"];
    if (!passage) {
        passage = [listUsers valueForKey:@"object"];
    }
    
    NSError* err = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:listUsers[0] options:NSJSONWritingPrettyPrinted error:&err];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    Inventaire* u = [[Inventaire alloc] initWithString:jsonString error:&err];
    

    //add names
    return u;
}



@end
