//
//  WSMethodes.m
//  Thimble
//
//  Created by Fares Ben Ammar on 18/03/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import "WSMethodes.h"
#import "WebServiceConfig.h"

@implementation WSMethodes

#pragma mark - USER WS

- (void)GetInventaires:(NSMutableDictionary *)Attributes_Values {
    
    self.Attributes_Values =
    [[NSMutableDictionary alloc] init];
    NSString *t=@"/WSRV_GetCampaigns.php";
    self.webserviceURI = [API_URL stringByAppendingString:t];
    [self launchPostRequestWithWsUri:self.webserviceURI dictionnaryPostAttributesValues:self.Attributes_Values];
}

- (void)GetSectors:(NSMutableDictionary *)Attributes_Values {
    
    self.Attributes_Values =
    [[NSMutableDictionary alloc] init];
    NSString *t=@"/sectors/%@";
    t=[NSString stringWithFormat:t,[Attributes_Values objectForKey:@"id"]];
    self.webserviceURI = [API_URL stringByAppendingString:t];
[self launchPostRequestWithWsUri:self.webserviceURI dictionnaryPostAttributesValues:self.Attributes_Values];}

- (void)GetSectors {
    
    self.Attributes_Values =
    [[NSMutableDictionary alloc] init];
    NSString *t=@"/sectors.php";
    self.webserviceURI = [API_URL stringByAppendingString:t];
[self launchPostRequestWithWsUri:self.webserviceURI dictionnaryPostAttributesValues:self.Attributes_Values];}

- (void)GetImages {
    
    self.Attributes_Values =
    [[NSMutableDictionary alloc] init];
    NSString *t=@"/images.php";
    self.webserviceURI = [API_URL stringByAppendingString:t];
[self launchPostRequestWithWsUri:self.webserviceURI dictionnaryPostAttributesValues:self.Attributes_Values];}

- (void)GetPastilles {
    
    self.Attributes_Values =
    [[NSMutableDictionary alloc] init];
    NSString *t=@"/WSRV_GetUsagesDef.php";
    self.webserviceURI = [API_URL stringByAppendingString:t];
[self launchPostRequestWithWsUri:self.webserviceURI dictionnaryPostAttributesValues:self.Attributes_Values];}


@end
