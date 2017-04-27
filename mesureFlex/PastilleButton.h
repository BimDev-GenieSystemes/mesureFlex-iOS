//
//  PastilleButton.h
//  MesureFlex
//
//  Created by UrbaProd1 on 19/11/2016.
//  Copyright © 2016 URBAPROD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZUILabel.h"
#import "PastilleState.h"
#import "Sector.h"
#import <CoreLocation/CoreLocation.h>
#import <Google/Analytics.h>

@interface PastilleButton : NSObject <CLLocationManagerDelegate>

@property NSString *pastille_id;
@property NSString *inventaire_id;
@property NSString *name;
@property NSString *sector_id;
@property NSString *sector_name;
@property NSString *personNumber;
@property NSString *capacity;
@property NSString *done;
@property NSString *timeStamp;
@property NSString *WPHandle;
@property NSString *WPDateTime;
@property NSString *WPShape;
@property NSString *WPRadius;
@property NSString *WPSITE;
@property NSString *WPBUILD;
@property NSString *WPFLOOR;
@property NSString *WPZONE;
@property NSString *WPCLUSTER;
@property NSString *WPPLACE;
@property NSString *WPPt;
@property NSString *WPComment;
@property NSString *WPClass;
@property NSString *WPTYPE;
@property NSString *WPDir;
@property NSString *WPCritical;
@property NSString *WPBookable;
@property NSString *WPCAPCITY;
@property NSString *WPOptData1;
@property NSString *WPOptData2;
@property NSString *WPOptData3;
@property NSString *WPState;
@property NSString *LatLng;
@property NSString *wpcountable;
@property PastilleState *state;
@property UIButton *button;
@property ZUILabel *label;
@property NSTimer *timer;
@property UIImageView *disabled;
- (void)startTimer;
- (void)stopTimer;
@property NSString *timerValue;
@property NSString *chronoValue;
@property NSDate *startDate;
- (void) insertIntoLocalDataStore;
- (void) setPastilleState : (PastilleState*) state;
+ (NSMutableArray*) selectFromLocalDataStore : (Sector*) sector;
- (void) initPastilleState;
- (void) restorePastilleStateTo : (PastilleState*) state;
- (void) makeItDisabled;
+ (void) deleteFromLocalDataStore;
- (NSString*) toString;
@end
