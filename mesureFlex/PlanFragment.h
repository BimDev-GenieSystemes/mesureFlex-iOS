//
//  PlanFragment.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 15/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <UIKit/UIKit.h>

@interface PlanFragment : JSONModel

@property (strong, nonatomic) NSString<Optional>* planFragment_id;
@property (strong, nonatomic) NSString<Optional>* inv_id;
@property (strong, nonatomic) NSString<Optional>* URL_PATH;
@property (strong, nonatomic) NSString<Optional>* sector_id;
@property (strong, nonatomic) NSData<Optional>* planFragmentData;
@property (strong, nonatomic) UIImage<Optional>* planFragmentImage;

- (void) insertIntoLocalDataStore;
- (void) updateInLocalDataStore;
- (void) deleteFromLocalDataStore;
+ (NSMutableArray<PlanFragment*>*) selectPlanFragmentFromLocalDataStore:(NSString*) sector_id :(NSString*) inv_id;
+ (void) deleteAllFromLocalDataStore;
@end
