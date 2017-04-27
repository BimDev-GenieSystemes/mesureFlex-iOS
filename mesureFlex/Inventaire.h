//
//  Org.h
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//



#import "JSONModel.h"
#import "Sector.h"
#import <UIKit/UIKit.h>

@interface Inventaire : JSONModel

@property (strong, nonatomic) NSString<Optional>* CampID;
@property (strong, nonatomic) NSString<Optional>* CampFullName;
@property (strong, nonatomic) NSString<Optional>* CampStatus;
@property (strong, nonatomic) NSString<Optional>* CampIssuer;
@property (strong, nonatomic) NSString<Optional>* CampCreDateTime;
@property (strong, nonatomic) NSString<Optional>* CampModDateTime;
@property (strong, nonatomic) NSString<Optional>* CampCustomer;
@property (strong, nonatomic) NSString<Optional>* CampSite;
@property (strong, nonatomic) NSString<Optional>* CampPosNbr;
@property (strong, nonatomic) NSString<Optional>* CampTotalCount;
@property (strong, nonatomic) NSString<Optional>* CampSectorNames;
@property (strong, nonatomic) NSString<Optional>* CampAllowedUsersIDs;
@property (strong, nonatomic) NSString<Optional>* CampUsageSinglePosIDs;
@property (strong, nonatomic) NSString<Optional>* CampUsageMultiplePosIDs;
@property (strong, nonatomic) NSString<Optional>* CampDateStart;
@property (strong, nonatomic) NSString<Optional>* CampDateEnd;


- (void) insertIntoLocalDataStore;
- (void) updateInLocalDataStore;
- (void) deleteFromLocalDataStore;
- (NSMutableArray<Sector*>*) getSectors;
+ (NSMutableArray<Inventaire*>*) selectInventaireFromLocalDataStore;
+ (Inventaire*) selectInventaireFromLocalDataStore:(NSString*) inv;
+ (void) deleteAllFromLocalDataStore;
@end
