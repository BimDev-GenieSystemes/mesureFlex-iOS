//
//  PastilleParser.m
//  Tap2Check
//
//  Created by Mohamed Mokrani on 27/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "PastilleParser.h"

@implementation PastilleParser

- (NSMutableArray*)getPastillesListFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    return [self getPastillesListFromNSArray:json];
}

- (NSMutableArray*)getPastillesListFromNSArray:(NSDictionary*)listUsers
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSMutableArray* passage = [listUsers copy];
    for (int i = 0; i < [passage count]; i++) {
        NSError* err = nil;
        
        NSString *val = [NSString stringWithFormat:@"%d",i];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[passage valueForKey:val] options:NSJSONWritingPrettyPrinted error:&err];
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        PastilleState* u = [[PastilleState alloc] initWithString:jsonString error:&err];
        [list addObject:u];
    }
    return list;
}

- (PastilleState*)getPastilleFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:kNilOptions
                     error:&error];
    
    return [self GetPastille:json];
    
    
}

- (PastilleState*)GetPastille:(NSArray*)listUsers
{
    NSArray* passage = [listUsers valueForKey:@"data"];
    if (!passage) {
        passage = [listUsers valueForKey:@"object"];
    }
    
    NSError* err = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:listUsers[0] options:NSJSONWritingPrettyPrinted error:&err];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    PastilleState* u = [[PastilleState alloc] initWithString:jsonString error:&err];
    
    
    //add names
    return u;
}

@end
