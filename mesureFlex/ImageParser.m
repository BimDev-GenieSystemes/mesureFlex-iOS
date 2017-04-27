//
//  ImageParser.m
//  Tap2Check
//
//  Created by Mohamed Mokrani on 21/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "ImageParser.h"

@implementation ImageParser

- (NSMutableArray*)getImagesListFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    return [self getImagesListFromNSArray:json];
}

- (NSMutableArray*)getImagesListFromNSArray:(NSDictionary*)listUsers
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSArray* passage = [[listUsers allValues] copy];
    
    passage=[passage sortedArrayUsingSelector:@selector(compare:)];
    
    for (int i = 0; i < [passage count]; i++) {
        
        //NSData* jsonData = [NSJSONSerialization dataWithJSONObject:passage[i] options:NSJSONWritingPrettyPrinted error:&err];
        //NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        PlanFragment* u = [[PlanFragment alloc] init];
        u.URL_PATH = [passage objectAtIndex:i];
        u.URL_PATH = [u.URL_PATH stringByReplacingOccurrencesOfString:@"../../" withString:@"http://mflex.geniesystemes.net/"];
        [list addObject:u];
    }
    return list;
}

- (PlanFragment*)getImageFromJsonString:(NSString*)jsonString
{
    NSError* error = NULL;
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:kNilOptions
                     error:&error];
    
    return [self GetImage:json];
    
    
}

- (PlanFragment*)GetImage:(NSArray*)listUsers
{
    NSArray* passage = [listUsers valueForKey:@"data"];
    if (!passage) {
        passage = [listUsers valueForKey:@"object"];
    }
    
    NSError* err = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:listUsers[0] options:NSJSONWritingPrettyPrinted error:&err];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    PlanFragment* u = [[PlanFragment alloc] initWithString:jsonString error:&err];
    
    
    //add names
    return u;
}


@end
