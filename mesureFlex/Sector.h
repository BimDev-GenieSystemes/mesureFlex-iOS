//
//  Sector.h
//  Tap2Check
//
//  Created by Mohamed Mokrani on 17/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <UIKit/UIKit.h>
#import "PlanFragment.h"

@interface Sector : JSONModel

@property NSString <Optional>*sector_id;
@property NSString <Optional>*name;
@property NSString <Optional>*level;
@property NSString <Optional>*inventaire_id;
@property NSMutableArray<PlanFragment*><Optional> *planFragments;
@property NSString<Optional> *wpFile;
@property UIImage<Optional> *planImage;
@property UIImage<Optional> *thumbNail;
@property int lineNumber;
@property int columnNumber;

- (void) getcolumnNumber;
- (void) insertIntoLocalDataStore;
- (void) updateInLocalDataStore;
- (void) deleteFromLocalDataStore;
+ (NSMutableArray<Sector*>*) selectSectorFromLocalDataStore : (NSString*) inventaire_id ;
+ (void) deleteAllFromLocalDataStore;
+ (NSMutableArray<Sector*>*) selectSectorFromLocalDataStore;
@end
