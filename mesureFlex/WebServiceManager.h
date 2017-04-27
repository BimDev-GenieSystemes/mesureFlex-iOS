//
//  WebServiceManager.h
//  Weather
//
//  Created by Slaheddine on 23/10/13.
//  Copyright (c) 2013 Slaheddine. All rights reserved.
//

#import <Foundation/Foundation.h>

// Delegate à implémenter dans le controlleur
@protocol WebServiceDelegate <NSObject>
@required
- (void)dataReceived:(NSString *)data FromWSCallName:(NSString *)WSCallName;
- (void)errorReceived:(NSString *)cachedResponse FromUrlKey:(NSString *)urlKey;

@end

@interface WebServiceManager : NSObject <NSURLConnectionDelegate> {
  NSMutableData *responseData;
}

@property(strong) id delegate;
@property(nonatomic, strong) NSString *webserviceURI;
@property(nonatomic, strong) NSMutableDictionary *Attributes_Values;

// lancer une requete http

- (void)launchPostRequestWithWsUri:(NSString *)wsURI
    dictionnaryPostAttributesValues:(NSMutableDictionary *)attrVals;

- (bool)launchGetRequestWithWsUri:(NSString *)wsURI
    dictionnaryPostAttributesValues:(NSMutableDictionary *)attrVals;
- (bool)launchNOCASHEGetRequestWithWsUri:(NSString *)wsURI
         dictionnaryPostAttributesValues:(NSMutableDictionary *)attrVals;
- (void)launchPostRequestWithData:(NSData *)data
    dictionnaryPostAttributesValues:(NSDictionary *)attrVals
                            withuri:(NSString *)wsURI;
- (void)launchPUTRequestWithWsUri:(NSString *)wsURI
    dictionnaryPostAttributesValues:(NSMutableDictionary *)attrVals;
- (void)launchDELETERequestWithWsUri:(NSString *)wsURI
     dictionnaryPostAttributesValues:(NSMutableDictionary *)attrVals;



@end
