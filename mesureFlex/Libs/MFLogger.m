//
//  MFLogger.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "MFLogger.h"

@implementation MFLogger

+ (void) put : (NSString*) message {
    
    NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-LOG.mfl",device_id];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    NSString *logMessage = [NSString stringWithFormat:@"%@ ===> %@\n",timestamp,message];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[logMessage dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:logMessage];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:NO];
    }

    
}

+ (NSString*) get {
    
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-LOG.mfl",device_id];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if ([fileManager fileExistsAtPath:path]) {
       
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        return stringFromFile;
        
    }
    
    return @"LOG VIDE";
    

    
    
}

@end
