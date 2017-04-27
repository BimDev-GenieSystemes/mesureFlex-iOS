//
//  PastilleState.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 15/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <UIKit/UIKit.h>
#import "Inventaire.h"

@interface PastilleState : JSONModel

@property NSString <Optional>*UsageID;
@property NSString <Optional>*UsageStatus;
@property NSString <Optional>*UsageContext;
@property NSString <Optional>*UsageAbsoluteValue;
@property NSString <Optional>*UsageAlwaysExists;
@property NSString <Optional>*UsageDisplayText;
@property NSString <Optional>*UsageDisplayIcon;
@property NSString <Optional>*UsageHexColor;
@property UIImage <Optional>*iconImage;
@property UIButton <Optional>*btn;


- (void) insertIntoLocalDataStore;
- (void) updateInLocalDataStore;
- (void) deleteFromLocalDataStore;
+ (NSMutableArray<PastilleState*>*) selectSectorFromLocalDataStore : (NSString*) stateType : (NSString*) inv;
+ (NSMutableArray<PastilleState*>*) selectSectorFromLocalDataStore;
+ (void) deleteAllFromLocalDataStore;

@end
