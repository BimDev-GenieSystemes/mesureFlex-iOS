//
//  WebServiceManager.m
//  Weather
//
//  Created by Slaheddine on 23/10/13.
//  Copyright (c) 2013 Slaheddine. All rights reserved.
//

#import "WebServiceManager.h"
#import "WebServiceConfig.h"
#import "EGOCache.h"
#import <AFNetworking/AFNetworking.h>
#import "Reachability.h"
typedef void (^CallbackSuccess)(AFHTTPRequestOperation *operation, id responseObject) ;
typedef void (^CallbackFail)(AFHTTPRequestOperation *operation, NSError *error);


@implementation NSURLRequest (WebServiceManager)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

@implementation WebServiceManager
{
    //if you wanna add some parser models
}


-(NSString*) generateKeyForUrl:(NSString*)url andParams:(NSMutableDictionary *) attrVals
{
    NSArray *keys = [attrVals allKeys];
    NSArray *vals = [attrVals allValues];
    url = [url stringByAppendingString:@"?"];
    for (int i =0; i< [keys count]; i++)
        url = [url stringByAppendingFormat:@"%@=%@&",keys[i],vals[i]];
    
    return [self encodeURLKey:url];
}

-(bool) launchGetRequestWithWsUri: (NSString *) wsURI dictionnaryPostAttributesValues: (NSMutableDictionary *) attrVals;
{
    NSString* keyForShortPeriod = [self generateKeyForUrl:wsURI andParams:attrVals];
    NSString* keyForLongPeriod = [self encodeURLKey:keyForShortPeriod];
    
    
    
    CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"URLDescription %@",[error description]);
        NSString* cache= [[EGOCache globalCache] stringForKey:keyForLongPeriod];
        //[self.delegate errorReceived:cache FromUrlKey:wsURI];
        
        if([cache isEqualToString:@""])
        {
            //[AlertManager showAlertWithTitle:NSLocalizedString(@"alertMessage", nil) AndMessage:@"" AndButton:NSLocalizedString(@"ok",nil)];
            [self.delegate errorReceived:cache FromUrlKey:wsURI];
        }
        
    };
    CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
        
        //Caching for 3 minutes
        [[EGOCache globalCache] setString:operation.responseString forKey:keyForShortPeriod  withTimeoutInterval:60*3];
        //Caching for 1 month
        [[EGOCache globalCache] setString:operation.responseString forKey:keyForLongPeriod  withTimeoutInterval:60*60*24*30];
        
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
        
    };
    
    
    
    NSString* cache= [[EGOCache globalCache] stringForKey:keyForShortPeriod];
    
    if([wsURI rangeOfString:@"GetEvent"].location!=NSNotFound)
        cache=@"";
    
    if([cache isEqualToString:@""])
    {
        cache= [[EGOCache globalCache] stringForKey:keyForLongPeriod];
        //if(![cache isEqualToString:@""])
            //[self.delegate dataReceived:cache FromWSCallName:wsURI];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.securityPolicy.allowInvalidCertificates = YES;
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager GET:wsURI parameters:attrVals success:success failure:fail];
    }
    else
    {
        [self.delegate dataReceived:cache FromWSCallName:wsURI];
        return NO;
    }
    
    return YES;
    
}

-(bool) launchNOCASHEGetRequestWithWsUri: (NSString *) wsURI dictionnaryPostAttributesValues: (NSMutableDictionary *) attrVals
{
    
    CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"URLDescription %@",[error description]);
        /*
         if (![WebServiceConfig getMessageIsShowin]) {
         [AlertManager showAlertWithTitle:NSLocalizedString(@"alertMessage", nil) AndMessage:@"" AndButton:NSLocalizedString(@"ok",nil)];
         [WebServiceConfig setMessageIsShowin:YES];
         }
         */
        
    };
    CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
        
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
        //     [WebServiceConfig setMessageIsShowin:NO];
        
    };
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:wsURI parameters:attrVals success:success failure:fail];
    
    return YES;
    
}

-(void) launchPostRequestWithWsUri: (NSString *) wsURI dictionnaryPostAttributesValues: (NSMutableDictionary *) attrVals
{
    Reachability *reachability =
    [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if  (internetStatus == NotReachable){
        
    NSString* keyForShortPeriod = [self generateKeyForUrl:wsURI andParams:attrVals];
    NSString* keyForLongPeriod = [self encodeURLKey:keyForShortPeriod];

    CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([operation.responseString rangeOfString:@"Empty Chat"].location!=NSNotFound)
            [self.delegate errorReceived:operation.responseString FromUrlKey:wsURI];

        
        NSLog(@"URLDescription %@",[error description]);
        NSString* cache= [[EGOCache globalCache] stringForKey:keyForLongPeriod];
        [self.delegate errorReceived:cache FromUrlKey:wsURI];
        
        if(![cache isEqualToString:@""])
        {
            //[AlertManager showAlertWithTitle:NSLocalizedString(@"alertMessage", nil) AndMessage:@"" AndButton:NSLocalizedString(@"ok",nil)];
            [self.delegate dataReceived:cache FromWSCallName:wsURI];
        }
        else
            [self.delegate errorReceived:cache FromUrlKey:wsURI];
        
    };
    CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
        
        //Caching for 3 minutes
        [[EGOCache globalCache] setString:operation.responseString forKey:keyForShortPeriod  withTimeoutInterval:60*3];
        //Caching for 1 month
        [[EGOCache globalCache] setString:operation.responseString forKey:keyForLongPeriod  withTimeoutInterval:60*60*24*30];
        
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
       /* NSString* key = [self encodeURLKey:wsURI];
        
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];*/
        
    };
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:wsURI parameters:attrVals success:success failure:fail];
    }
    else
        
    {
        
        CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"URL%@",[self encodeURLKey:wsURI]);
            NSString* key = [self encodeURLKey:wsURI];
            NSLog(@"URLDescription %@", [error description]);
            NSLog(@"response %@ ", operation.responseString);
            
            NSString* cache= [[EGOCache globalCache] stringForKey:key];
            if([operation.responseString rangeOfString:@"Empty Chat"].location!=NSNotFound)
                [self.delegate errorReceived:operation.responseString FromUrlKey:wsURI];
            else
            [self.delegate errorReceived:cache FromUrlKey:wsURI];
            
            
            if ([operation.responseString rangeOfString:@"Invalid Token"].location != NSNotFound && [wsURI rangeOfString:@"LRgetNotif"].location == NSNotFound && [wsURI rangeOfString:@"logout"].location == NSNotFound)
                [self sessionLost];
            
            
        };
        CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
            
            NSLog(@"URL%@",[self encodeURLKey:wsURI]);
            NSString* key = [self encodeURLKey:wsURI];
            [[EGOCache globalCache] setString:operation.responseString forKey:key  withTimeoutInterval:60*3];
            [[EGOCache globalCache] setString:operation.responseString forKey:key  withTimeoutInterval:60*60*24*3];
            [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
            
        };
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:wsURI parameters:attrVals success:success failure:fail];
        
    }
}

- (void) sessionLost {
    
   /* UIAlertView *logOutAlertView =
    [[UIAlertView alloc] initWithTitle:@""
                               message:NSLocalizedString(@"session", nil)
                              delegate:self
                     cancelButtonTitle:NSLocalizedString(@"ok", nil)
                     otherButtonTitles:nil, nil];
    
    [logOutAlertView dismissWithClickedButtonIndex:1 animated:YES];
    [logOutAlertView show];*/
}

-(void) launchPUTRequestWithWsUri: (NSString *) wsURI dictionnaryPostAttributesValues: (NSMutableDictionary *) attrVals
{
    
    CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"URL%@",[self encodeURLKey:wsURI]);
        NSString* key = [self encodeURLKey:wsURI];
        NSString* cache= [[EGOCache globalCache] stringForKey:key];
        [self.delegate errorReceived:cache FromUrlKey:wsURI];
        
    };
    CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
        
        NSLog(@"URL%@",[self encodeURLKey:wsURI]);
        NSString* key = [self encodeURLKey:wsURI];
        [[EGOCache globalCache] setString:operation.responseString forKey:key  withTimeoutInterval:60*60*24*3];
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
        
    };
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager PUT:wsURI parameters:attrVals success:success failure:fail];
}
-(void) launchDELETERequestWithWsUri: (NSString *) wsURI dictionnaryPostAttributesValues: (NSMutableDictionary *) attrVals
{
    
    CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"URL%@",[self encodeURLKey:wsURI]);
        NSString* key = [self encodeURLKey:wsURI];
        NSString* cache= [[EGOCache globalCache] stringForKey:key];
        [self.delegate errorReceived:cache FromUrlKey:wsURI];
        
    };
    CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
        
        NSLog(@"URL%@",[self encodeURLKey:wsURI]);
        NSString* key = [self encodeURLKey:wsURI];
        [[EGOCache globalCache] setString:operation.responseString forKey:key  withTimeoutInterval:60*60*24*3];
        [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
        
    };
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager DELETE:wsURI parameters:attrVals success:success failure:fail];
}


- (NSString*) encodeURLKey:(NSString*) string
{
    
    NSString *urlToSave = string;
    
    NSData *plainData = [urlToSave dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *encoded = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    return base64String;
}

- (void)launchPostRequestWithData:(NSData *)data
  dictionnaryPostAttributesValues:(NSDictionary *)attrVals
                          withuri:(NSString *)wsURI {
    
    Reachability *reachability =
    [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if  (internetStatus == NotReachable){
        
        NSString* keyForShortPeriod = [self generateKeyForUrl:wsURI andParams:[attrVals copy]];
        NSString* keyForLongPeriod = [self encodeURLKey:keyForShortPeriod];
        
        CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if([operation.responseString rangeOfString:@"Empty Chat"].location!=NSNotFound)
                [self.delegate errorReceived:operation.responseString FromUrlKey:wsURI];
            
            
            NSLog(@"URLDescription %@",[error description]);
            NSString* cache= [[EGOCache globalCache] stringForKey:keyForLongPeriod];
            //[self.delegate errorReceived:cache FromUrlKey:wsURI];
            
            if(![cache isEqualToString:@""])
            {
                //[AlertManager showAlertWithTitle:NSLocalizedString(@"alertMessage", nil) AndMessage:@"" AndButton:NSLocalizedString(@"ok",nil)];
                [self.delegate dataReceived:cache FromWSCallName:wsURI];
            }
            else
                [self.delegate errorReceived:cache FromUrlKey:wsURI];
            
        };
        CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
            
            NSLog(@"URL%@",[self encodeURLKey:wsURI]);
            /*NSString* key = [self encodeURLKey:wsURI];
            //Caching for 3 minutes
            //Caching for 1 month*/
            [[EGOCache globalCache] setString:operation.responseString forKey:keyForLongPeriod  withTimeoutInterval:60*60*24*30];
            
            [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
            
        };
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        // [manager POST:wsURI parameters:attrVals success:success failure:fail];
        [manager POST:wsURI parameters:attrVals constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //do not put image inside parameters dictionary as I did, but append it!
            [formData appendPartWithFileData:data name:@"upload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
        } success:success failure:fail];
    }
    else
        
    {
        
        CallbackFail fail=^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"URL%@",[self encodeURLKey:wsURI]);
            NSString* key = [self encodeURLKey:wsURI];
            NSLog(@"URLDescription %@", [error description]);
            NSLog(@"response %@ ", operation.responseString);
            
            NSString* cache= [[EGOCache globalCache] stringForKey:key];
            [self.delegate errorReceived:cache FromUrlKey:wsURI];
            
        };
        CallbackSuccess success=^(AFHTTPRequestOperation *operation, id responseObject)  {
            
            NSLog(@"URL%@",[self encodeURLKey:wsURI]);
            NSString* key = [self encodeURLKey:wsURI];
            [[EGOCache globalCache] setString:operation.responseString forKey:key  withTimeoutInterval:60*60*24*3];
            [self.delegate dataReceived:operation.responseString FromWSCallName:[[[operation response] URL] absoluteString]];
            
        };
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:wsURI parameters:attrVals constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //do not put image inside parameters dictionary as I did, but append it!
            if ([[attrVals objectForKey:@"type"] isEqualToString:@"image"])
            [formData appendPartWithFileData:data name:@"upload" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            else
                [formData appendPartWithFileData:data name:@"upload" fileName:@"video.mp4" mimeType:@"video/mp4"];

        } success:success failure:fail];
    }
    
    
}



@end
