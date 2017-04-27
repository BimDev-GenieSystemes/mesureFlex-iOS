//
//  FlexViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "FlexViewController.h"
#import "Inventaire.h"
#import "Sector.h"
#import "PastilleState.h"
#import "PastilleStateTableViewCell.h"
#import "FLAnimatedImage.h"
#import "PastilleButton.h"
#import "M13BadgeView.h"
#import "SectorTableViewController.h"
#import "DumpViewController.h"
#import "TableViewController.h"
#import <Google/Analytics.h>
#import "MFLogger.h"
#include <math.h>
#include <stdio.h>
#import "UIView+Toast.h"
typedef void (^MyFunc)(void);

@interface FlexViewController ()
{
    NSMutableArray<PastilleState*> *pastilleStateTable;
    NSMutableArray<UIImage*> *images;
    PastilleButton *pastilleClicked;
    NSMutableArray<PastilleButton*> *buttons;
    float _currRotation;
    NSTimer *myTimer;
    CLLocationManager *locationManager;
    float latitude;
    float longitude;
    NSString *LatLng;
}
@end

@implementation FlexViewController




-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    latitude = manager.location.coordinate.latitude;
    longitude = manager.location.coordinate.longitude;
    LatLng = [NSString stringWithFormat:@"%f,%f",latitude,longitude];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [MFLogger put:@"FlexView open"];
    [MFLogger put:_sector.name];
    locationManager = [[CLLocationManager alloc] init];
    #define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    
    
    if(IS_OS_8_OR_LATER)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    
    latitude = locationManager.location.coordinate.latitude;
    longitude = locationManager.location.coordinate.longitude;
    
    LatLng = [NSString stringWithFormat:@"%f,%f",latitude,longitude];
    
    @autoreleasepool {
        __weak __typeof__(self) wself = self;
            [[NSNotificationCenter defaultCenter] addObserver:wself selector:@selector(closeModal2:) name:@"CloseList" object:nil];
            _currRotation = 0.0;
            pastilleClicked = [[PastilleButton alloc] init];
            buttons = [[NSMutableArray<PastilleButton*> alloc] init];
            pastilleStateTable = [[NSMutableArray<PastilleState*> alloc] init];
            images = [[NSMutableArray<UIImage*> alloc] init];
            pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"S":self.sector.inventaire_id];
            [wself setGraphicSetup];
            wself.scrollView.delegate = wself;
            wself.scrollView.scrollEnabled = YES;
            wself.scrollView.maximumZoomScale = 10;
            wself.scrollView.zoomScale = 0;
            wself.rotationButton.tag = 0;
            wself.selectionButton.tag = 0;
            wself.commentButton.tag = 0;
            wself.selectionButton.tag = 0;
    }
    
    NSString *swip = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"swipe"];
    if(!swip) {
        swip = @"on";
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"swipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([swip isEqualToString:@"on"]) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        [swipe setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.trackPadView addGestureRecognizer:swipe];
        
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.trackPadView addGestureRecognizer:swipe];
        
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.trackPadView addGestureRecognizer:swipe];
        
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.trackPadView addGestureRecognizer:swipe];
    }
    
    
    [self.trackPadView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.trackPadView addGestureRecognizer:tap];
    
}

-(void) tapAction {
    
    __weak __typeof__(self) wself = self;
    UIButton *button = pastilleClicked.button;
    if (![button isEqual:pastilleClicked.button] || wself.stateTableView.hidden == YES)
        [wself selectPastilleButton:button];
    
    else {
        NSLog(@"%d",pastilleClicked.state.UsageID.intValue);
        int index = 0;
        
        for (int i = 0; i < pastilleStateTable.count ; i++ ) {
            
            if ([pastilleClicked.state.UsageID isEqualToString:[pastilleStateTable objectAtIndex:i].UsageID]) {
                
                index = i;
                break;
                
            }
            
        }
        if (index < pastilleStateTable.count-1) {
            pastilleClicked.LatLng = LatLng;
            [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:(index+1)]];
            
        }
        
        else {
            pastilleClicked.LatLng = LatLng;
            [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:0]];
            
        }
        [UIView setAnimationsEnabled:NO];
        [wself.pastilleNameButton setTitle:[wself pastilleFromButton:button].name forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        wself.personNumberLabel.text = [wself pastilleFromButton:button].personNumber;
        [wself.capacityLabel setTitle:[wself pastilleFromButton:button].capacity forState:UIControlStateNormal];
        
        [[pastilleClicked.button layer] setBorderWidth:0.0f];
        [pastilleClicked.button.layer removeAllAnimations];
        pastilleClicked = [wself pastilleFromButton:button];
        
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=1.0;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.25];
        theAnimation.toValue=[NSNumber numberWithFloat:1.0];
        [button.layer addAnimation:theAnimation forKey:@"scale"];
        
        wself.stateTableView.hidden = NO;
        wself.stateBottomMenu.hidden = NO;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[pastilleStateTable indexOfObject:pastilleClicked.state] inSection:0];
        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                    atScrollPosition:UITableViewScrollPositionNone
                                            animated:YES];
        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        
    }
    
    [MFLogger put:@"change state from tap"];
    
}

-(void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    [self searchPastille:gesture.direction];
    
}

-(void) searchPastille : (int) direction {
    
    NSMutableArray<PastilleButton*> *directButtons = [[NSMutableArray<PastilleButton*> alloc] init];
    
    float x = pastilleClicked.button.frame.origin.x+pastilleClicked.button.frame.size.height/2;
    float y = pastilleClicked.button.frame.origin.y+pastilleClicked.button.frame.size.height/2;
    float b = y-x;
    float d = y+x;
    
    for (PastilleButton *pb in buttons) {
        
        float x1 = pb.button.frame.origin.x+pb.button.frame.size.height/2;
        float y1 = pb.button.frame.origin.y+pb.button.frame.size.height/2;
        
        switch (direction) {
                
            case UISwipeGestureRecognizerDirectionUp:
                if (y1 < y && x1 >= x-pastilleClicked.button.frame.size.height && x1 <= x+pastilleClicked.button.frame.size.height) {
                    [directButtons addObject:pb];
                }
                break;
                
            case UISwipeGestureRecognizerDirectionDown:
                if (y1 > y && x1 >= x-pastilleClicked.button.frame.size.height && x1 <= x+pastilleClicked.button.frame.size.height) {
                    [directButtons addObject:pb];
                }
                break;
                
            case UISwipeGestureRecognizerDirectionLeft:
                if (x1 < y && y1 >= y-pastilleClicked.button.frame.size.height && y1 <= y+pastilleClicked.button.frame.size.height) {
                    [directButtons addObject:pb];
                }
                break;
                
            case UISwipeGestureRecognizerDirectionRight:
                if (x1 > x && y1 >= y-pastilleClicked.button.frame.size.height && y1 <= y+pastilleClicked.button.frame.size.height) {
                    [directButtons addObject:pb];
                }
                break;
                
            default:
                break;
        }
        
    }

    if (directButtons.count == 0) {
        
        for (PastilleButton *pb in buttons) {
            
            float x1 = pb.button.frame.origin.x+pb.button.frame.size.height/2;
            float y1 = pb.button.frame.origin.y+pb.button.frame.size.height/2;
            
            switch (direction) {
                    
                case UISwipeGestureRecognizerDirectionUp:
                    if (y1 > x1+b && y1 > -x1+d) {
                        [directButtons addObject:pb];
                    }
                    break;
                    
                case UISwipeGestureRecognizerDirectionDown:
                    if (y1 < x1+b && y1 <-x1+d) {
                        [directButtons addObject:pb];
                    }
                    break;
                    
                case UISwipeGestureRecognizerDirectionLeft:
                    if (y1 > x1+b && y1 < -x1+d) {
                        [directButtons addObject:pb];
                    }
                    break;
                    
                case UISwipeGestureRecognizerDirectionRight:
                    if (y1 < x1+b && y1 > -x1+d) {
                        [directButtons addObject:pb];
                    }
                    break;
                    
                default:
                    break;
            }
            
        }

        if (directButtons.count == 0) {
            for (PastilleButton *pb in buttons) {
                
                float x1 = pb.button.frame.origin.x+pb.button.frame.size.height/2;
                float y1 = pb.button.frame.origin.y+pb.button.frame.size.height/2;
                
                switch (direction) {
                        
                    case UISwipeGestureRecognizerDirectionUp:
                        if (y1 < y) {
                            [directButtons addObject:pb];
                        }
                        break;
                        
                    case UISwipeGestureRecognizerDirectionDown:
                        if (y1 > y) {
                            [directButtons addObject:pb];
                        }
                        break;
                        
                    case UISwipeGestureRecognizerDirectionLeft:
                        if (x1 < x) {
                            [directButtons addObject:pb];
                        }
                        break;
                        
                    case UISwipeGestureRecognizerDirectionRight:
                        if (x1 > x) {
                            [directButtons addObject:pb];
                        }
                        break;
                        
                    default:
                        break;
                }
                
            }

        }
        
        
    }
        NSMutableArray *array = [[NSMutableArray alloc] init];
    for (PastilleButton *pb in directButtons) {
        
        NSString *dist = [NSString stringWithFormat:@"%f",[self getDistanceFromLatLonInKm:pastilleClicked.button.frame.origin.x :pastilleClicked.button.frame.origin.y :pb.button.frame.origin.x :pb.button.frame.origin.y]];
        [array addObject:dist];
        
    }
    
    int pos = 0;
    long min = 0.0;
    for (int i = 0; i < array.count ; i++) {
        
        if (i == 0) {
            
            min = [[array objectAtIndex:i] floatValue];
            pos = i;
            
        }
        
        else if ([[array objectAtIndex:i] floatValue] <= min && [[array objectAtIndex:i] floatValue] != 0.0) {
            
            min = [[array objectAtIndex:i] floatValue];
            pos = i;
            
        }
        
        
        
    }
    
    if (array.count > 0) {
        
        [self selectPastilleButton:[directButtons objectAtIndex:pos].button];
    }
    
    else {
        
        switch (direction) {
                
                case UISwipeGestureRecognizerDirectionUp:
                [self.view makeToast:@"Aucune pastille en haut"];
                break;
                
                case UISwipeGestureRecognizerDirectionDown:
                [self.view makeToast:@"Aucune pastille en bas"];
                break;
                
                case UISwipeGestureRecognizerDirectionLeft:
                [self.view makeToast:@"Aucune pastille à gauche"];
                break;
                
                case UISwipeGestureRecognizerDirectionRight:
                [self.view makeToast:@"Aucune pastille à droite"];
                break;
                
            default:
                break;
        }
        
    }
    
    //NSLog(@"%@",array);
    
}

-(float) getDistanceFromLatLonInKm : (float) lat1 : (float) lon1 : (float) lat2 : (float) lon2 {
    float R = 6371; // Radius of the earth in km
    float dLat = [self deg2rad:lat2-lat1];  // deg2rad below
    float dLon = [self deg2rad:lon2-lon1];
    float a =
    sinf(dLat/2) * sinf(dLat/2) +
    cosf([self deg2rad:lat1]) * cosf([self deg2rad:lat2]) *
    sinf(dLon/2) * sinf(dLon/2)
    ;
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c; // Distance in km
    
    d = sqrtf(powf(lat1-lat2,2) + powf(lon1-lon2,2));
    return d;
}

-(float) deg2rad : (float) deg {
    
    return deg * (M_PI/M_PI);
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.dumpText setTarget:nil];
    [self.dumpText setAction:nil];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"FlexViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

-(void) viewDidAppear:(BOOL)animated {
    

        
    @autoreleasepool {
        __weak __typeof__(self) wself = self;
        [NSThread detachNewThreadSelector:@selector(startTheBackgroundJobb) toTarget:wself withObject:nil];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:wself selector:@selector(updateView) userInfo:nil repeats:YES];
    }
    
}

- (void) startTheBackgroundJobb {
    
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __weak __typeof__(self) wself = self;
                NSDate *date = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd/MM/yyyy  "];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:[self managedObjectContext]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = %@", @"FALSE"];
                [fetchRequest setPredicate:predicate];
                [fetchRequest setEntity:entity];
                NSError *error;
                NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
                
                wself.topNavBar.topItem.title = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:date],wself.sector.name];
                [wself.dumpText setTitle:[NSString stringWithFormat:@"En attente : %lu",(unsigned long)items.count]];
                
                wself.loadingGif.hidden = NO;
                
                if (!wself.sector.planImage) {
                    
                    wself.sector.planFragments = [PlanFragment selectPlanFragmentFromLocalDataStore:wself.sector.name :wself.sector.inventaire_id];
                    [wself.sector getcolumnNumber];
                    for (PlanFragment *planF in wself.sector.planFragments) {
                        
                        [images addObject:planF.planFragmentImage];
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.sector.planImage = [wself concatImages:wself.sector];
                        
                        
                        [MFLogger put:@"start put pastilles"];
                        [wself putPastilleButton:^(void) {
                            [MFLogger put:@"pastilles done"];
                            
                            if (!wself.sector.thumbNail) {
                                
                                wself.sector.thumbNail = [wself captureScreenInRect:wself.zommableView.frame];
                                [wself.sector updateInLocalDataStore];
                                
                            }
                            
                            wself.planImage.image = self.sector.planImage;
                            [MFLogger put:@"plan loaded"];
                            wself.planImage.contentMode = UIViewContentModeScaleAspectFit;
                            wself.planImage.clipsToBounds = YES;
                            wself.loadingGif.hidden = YES;
                            wself.sector.planImage = wself.planImage.image;
                            [wself.sector updateInLocalDataStore];
                        }];
                        
                    });
                    
                    
                }
                
                else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [wself putPastilleButton:^(void) {
                            
                            wself.planImage.image = wself.sector.planImage;
                            wself.planImage.contentMode = UIViewContentModeScaleAspectFit;
                            wself.planImage.clipsToBounds = YES;
                            wself.loadingGif.hidden = YES;
                            
                            //sleep(1);
                            
                            
                            UIAlertController * alert=   [UIAlertController
                                                          alertControllerWithTitle:@"Souhaitez-vous récupérer l'ensemble des positions ?"
                                                          message:@""
                                                          preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction
                                                 actionWithTitle:@"Oui"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)
                                                 {
                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                     [wself restoreStates];
                                                     
                                                 }];
                            UIAlertAction* cancel = [UIAlertAction
                                                     actionWithTitle:@"Non"
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                                                     {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                     }];
                            
                            [alert addAction:ok];
                            [alert addAction:cancel];
                            
                            
                        }];
                        
                    });

                    
                }

                
        });
                
        });
        
    }

    
}

-(void) updateView {
    
    @autoreleasepool {
        __weak __typeof__(self) wself = self;
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy  "];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:[self managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved = %@", @"FALSE"];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        wself.topNavBar.topItem.title = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:date],wself.sector.name];
        [wself.dumpText setTitle:[NSString stringWithFormat:@"En attente : %lu",(unsigned long)items.count]];
        //wself.topNavBar.topItem.title = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)items.count,[dateFormatter stringFromDate:date],wself.sector.name];
        
        wself.timerLabel.text = pastilleClicked.timerValue;
        NSString *numberC = [NSString stringWithFormat:@"%@ | %@/%@",pastilleClicked.name,pastilleClicked.personNumber,pastilleClicked.capacity];
        [UIView setAnimationsEnabled:NO];
        [wself.pastilleNameButton setTitle:numberC forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        
        for (UIView *j in pastilleClicked.button.subviews){
            if([j isKindOfClass:[M13BadgeView class]]){
                ((M13BadgeView*)j).text = pastilleClicked.personNumber;
            }
        }
        
    }
    
    
}



-(void) setGraphicSetup {
    
    //setup LeftMenu
    @autoreleasepool {
        __weak __typeof__(self) wself = self;
        
        
        [[self.trackPadView layer] setMasksToBounds:YES];
        [[self.trackPadView layer] setCornerRadius:2.0f];
        [[self.trackPadView layer] setBorderColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
        [[self.trackPadView layer] setBorderWidth:1.0f];
        [[self.trackPadView layer] setShadowColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
        [[self.trackPadView layer] setShadowOffset:CGSizeMake(5, 5)];
        [[self.trackPadView layer] setShadowOpacity:1];
        [[self.trackPadView layer] setShadowRadius:2.0];
        
        wself.capacityImg.image = [wself.capacityImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.capacityImg setTintColor:[UIColor groupTableViewBackgroundColor]];
        wself.addPersonButton.layer.cornerRadius = 25.0;
        wself.addPersonButton.layer.borderColor = [[UIColor alloc] initWithWhite:1 alpha:0.75].CGColor;
        wself.addPersonButton.layer.borderWidth = 1.0;
        self.personNumberLabel.layer.cornerRadius = 25.0;
        wself.removePersonButton.layer.cornerRadius = 25.0;
        wself.removePersonButton.layer.borderColor = [[UIColor alloc] initWithWhite:1 alpha:0.75].CGColor;
        wself.removePersonButton.layer.borderWidth = 1.0;
        
        wself.personSuperView.layer.cornerRadius = 69/2;
        //setup bottomMenu
        wself.selectionImg.image = [wself.selectionImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.selectionImg setTintColor:[UIColor darkGrayColor]];
        
        wself.drawImg.image = [wself.drawImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.drawImg setTintColor:[UIColor darkGrayColor]];
        
        wself.commentImg.image = [wself.commentImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.commentImg setTintColor:[UIColor darkGrayColor]];
        
        wself.menuImg.image = [wself.menuImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.menuImg setTintColor:[UIColor darkGrayColor]];
        
        wself.stateTableView.layer.cornerRadius = 5.0;
        wself.stateTableView.layer.borderColor = [[UIColor alloc] initWithWhite:1 alpha:0.75].CGColor;
        wself.stateTableView.layer.borderWidth = 1.0;
        
        wself.stateBottomMenu.layer.cornerRadius = 5.0;
        wself.stateBottomMenu.layer.borderColor = [[UIColor alloc] initWithWhite:1 alpha:0.75].CGColor;
        wself.stateBottomMenu.layer.borderWidth = 1.0;
        
        wself.stateHistoryButton.layer.cornerRadius = 25.0;
        wself.stateHistoryButton.layer.borderColor = [[UIColor alloc] initWithWhite:1 alpha:0.75].CGColor;
        wself.stateHistoryButton.layer.borderWidth = 1.0;
        
        wself.bottomMenuView.layer.cornerRadius = 5.0;
        wself.bottomMenuView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        wself.bottomMenuView.layer.borderWidth = 1.0;
        
        wself.bottomSubMenu.layer.cornerRadius = 5.0;
        wself.bottomSubMenu.layer.borderColor = [UIColor darkGrayColor].CGColor;
        wself.bottomSubMenu.layer.borderWidth = 1.0;
        
    }

    
    
    
}

- (void) putPastilleButton : (MyFunc)func {
    __weak __typeof__(self) wself = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @autoreleasepool {
                for (UIView *j in wself.zommableView.subviews){
                    if([j isKindOfClass:[UIButton class]]){
                        [((UIButton*)j) removeFromSuperview];
                    }
                }
                
                float widthRatio = wself.zommableView.bounds.size.width / wself.sector.planImage.size.width;
                float heightRatio = wself.zommableView.bounds.size.height / wself.sector.planImage.size.height;
                float scale = MIN(widthRatio, heightRatio);
                float imageWidth = scale * wself.sector.planImage.size.width;
                float imageHeight = scale * wself.sector.planImage.size.height;
                
                NSString *strFileContent = wself.sector.wpFile;
                //if(_sector.imagesObj.count > 0)
                //strFileContent = _sector.wp;
                
                NSInteger length = [[strFileContent componentsSeparatedByCharactersInSet:
                                     [NSCharacterSet newlineCharacterSet]] count];
                
                UIButton *btn;
                @autoreleasepool {
                    for (int i = 1; i < length ; i++) {
                        
                        NSString *data = [[strFileContent componentsSeparatedByCharactersInSet:
                                           [NSCharacterSet newlineCharacterSet]] objectAtIndex:i];
                        NSArray* dataArray = [data componentsSeparatedByString: @";"];
                        if([dataArray count] >= 6 ) {
                            
                            NSString *WPHandle = @"";
                            NSString *WPDateTime = @"";
                            NSString *WPShape = @"";
                            NSString *WPRadius = @"";
                            NSString *WPSITE = @"";
                            NSString *WPBUILD = @"";
                            NSString *WPFLOOR = @"";
                            NSString *WPZONE = @"";
                            NSString *WPCLUSTER = @"";
                            NSString *WPPLACE = @"";
                            NSString *WPPt = @"";
                            NSString *WPState = @"";
                            NSString *WPClass = @"";
                            NSString *WPTYPE = @"";
                            NSString *WPDir = @"";
                            NSString *WPComment = @"";
                            NSString *WPCritical = @"";
                            NSString *WPBookable = @"";
                            NSString *WPCAPCITY = @"";
                            NSString *WPCountable = @"";
                            NSString *WPOptData1 = @"";
                            NSString *WPOptData2 = @"";
                            NSString *WPOptData3 = @"";
                            @try {
                                WPHandle = [dataArray objectAtIndex: 0];
                                WPDateTime = [dataArray objectAtIndex: 1];
                                WPShape = [dataArray objectAtIndex: 2];
                                WPRadius = [dataArray objectAtIndex: 3];
                                WPSITE = [dataArray objectAtIndex: 4];
                                WPBUILD = [dataArray objectAtIndex: 5];
                                WPFLOOR = [dataArray objectAtIndex: 6];
                                WPZONE = [dataArray objectAtIndex: 7];
                                WPCLUSTER = [dataArray objectAtIndex: 8];
                                WPPLACE = [dataArray objectAtIndex: 9];
                                WPPt = [dataArray objectAtIndex: 10];
                                WPState = [dataArray objectAtIndex: 11];
                                WPClass = [dataArray objectAtIndex: 12];
                                WPTYPE = [dataArray objectAtIndex: 13];
                                WPDir = [dataArray objectAtIndex: 14];
                                WPComment = [dataArray objectAtIndex: 15];
                                WPCritical = [dataArray objectAtIndex: 16];
                                WPBookable = [dataArray objectAtIndex: 17];
                                WPCAPCITY = [dataArray objectAtIndex: 18];
                                WPCountable = [dataArray objectAtIndex: 19];
                                WPOptData1 = [dataArray objectAtIndex: 20];
                                WPOptData2 = [dataArray objectAtIndex: 21];
                                WPOptData3 = [dataArray objectAtIndex: 22];
                            } @catch (NSException *exception) {
                                [MFLogger put:@"Non conform WP File"];
                            } @finally {
                                
                            }
                            
                            
                            
                            NSString *x = [[WPPt componentsSeparatedByString:@","] objectAtIndex:0];
                            NSString *y = [[WPPt componentsSeparatedByString:@","] objectAtIndex:1];
                            
                            float wSize = 25*scale;
                            float hSize = 25*scale;
                            
                            float xPosition = [x doubleValue] / (800*wself.sector.columnNumber/imageWidth) + (wself.zommableView.frame.size.width/2 - imageWidth/2)-wSize/2;
                            float yPosition = [y doubleValue] / (640*wself.sector.lineNumber/imageHeight) + (wself.zommableView.frame.size.height/2 - imageHeight/2)-hSize/2;
                            btn = [[UIButton alloc] initWithFrame:CGRectMake(xPosition,yPosition,wSize,hSize)];
                            PastilleButton *pbtn = [[PastilleButton alloc] init];
                            pbtn.WPHandle = WPHandle;
                            pbtn.WPDateTime = WPDateTime;
                            pbtn.WPShape = WPShape;
                            pbtn.WPRadius = WPRadius;
                            pbtn.WPSITE = WPSITE;
                            pbtn.WPBUILD = WPBUILD;
                            pbtn.WPFLOOR = WPFLOOR;
                            pbtn.WPZONE = WPZONE;
                            pbtn.WPCLUSTER = WPCLUSTER;
                            pbtn.WPPLACE = WPPLACE;
                            pbtn.WPComment = WPComment;
                            pbtn.WPClass = WPClass;
                            pbtn.WPTYPE = WPTYPE;
                            pbtn.WPDir = WPDir;
                            pbtn.WPState = WPState;
                            pbtn.WPCritical = WPCritical;
                            pbtn.WPBookable = WPBookable;
                            pbtn.WPOptData1 = WPOptData1;
                            pbtn.WPOptData2 = WPOptData2;
                            pbtn.WPOptData3 = WPOptData3;
                            pbtn.WPCAPCITY = WPCAPCITY;
                            pbtn.wpcountable = WPCountable;
                            pbtn.WPPt = WPPt;
                            pbtn.inventaire_id = _sector.inventaire_id;
                            
                            [btn setBackgroundColor:[UIColor blackColor]];
                            
                            //UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:wself action:@selector(longPressGestures:)];
                            
                            //[btn addGestureRecognizer:press];
                            
                            [btn addTarget:wself action:@selector(pastilleClickAction:withEvent:)forControlEvents:UIControlEventTouchUpInside];
                            btn.restorationIdentifier = WPPLACE;
                            pbtn.name = WPPLACE;
                            
                            
                            
                            
                            btn.accessibilityIdentifier = @"0";
                            pbtn.personNumber =@"0";
                            //[btn addGestureRecognizer:press];
                            M13BadgeView *badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0,0,hSize/2,hSize/2)];
                            badgeView.text = @"0";
                            
                            float largestFontSize = 7;
                            while ([@"0" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:largestFontSize]}].width > hSize/2)
                            {
                                largestFontSize--;
                            }
                            badgeView.font = [UIFont systemFontOfSize:largestFontSize];
                            badgeView.textColor = [UIColor whiteColor];
                            badgeView.badgeBackgroundColor = [UIColor darkGrayColor];
                            badgeView.hidesWhenZero = YES;
                            [btn addSubview:badgeView];
                            
                            
                            if ([WPCAPCITY isEqualToString:@"1"]) {
                                btn.layer.cornerRadius = wSize/2;
                                btn.accessibilityValue = @"1";
                                pbtn.capacity = @"1";
                                pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"S":self.sector.inventaire_id];
                                
                            }
                            else {
                                
                                btn.layer.cornerRadius = 3.0;
                                //[btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
                                btn.accessibilityValue = [dataArray objectAtIndex:7];
                                pbtn.capacity = WPCAPCITY;
                                pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"M":self.sector.inventaire_id];
                            }
                            pbtn.button = btn;
                            pbtn.sector_id = wself.sector.sector_id;
                            pbtn.sector_name = wself.sector.name;
                            [buttons addObject:pbtn];
                            [pbtn initPastilleState];
                            
                            [wself.zommableView addSubview:btn];
                            
                        }
                    }
                    
                    
                }
            }
            
            if (func)
                func();
        });
    
    });
    }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) subMenuHiddenConfig:(BOOL) state {
    
    __weak __typeof__(self) wself = self;
    if (state) {
        float y = wself.bottomSubMenu.frame.origin.y;
        [wself.drawButton setBackgroundColor:wself.drawButton.tintColor];
        [wself.drawButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
        wself.drawImg.image = [wself.drawImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.drawImg setTintColor:[UIColor groupTableViewBackgroundColor]];
        
        [wself enableRotation:NO];
        [wself enableComment:NO];
        [wself enableSelection:NO];
        
        [wself.bottomSubMenu setFrame:CGRectMake(wself.bottomSubMenu.frame.origin.x, y+70, wself.bottomSubMenu.frame.size.width, wself.bottomSubMenu.frame.size.height)];
        wself.bottomSubMenu.hidden = NO;
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [wself.bottomSubMenu setFrame:CGRectMake(wself.bottomSubMenu.frame.origin.x, y, wself.bottomSubMenu.frame.size.width, wself.bottomSubMenu.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                         }];
       
        
    }
    
    else {
        
        [wself.drawButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [wself.drawButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        wself.drawImg.image = [wself.drawImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.drawImg setTintColor:[UIColor darkGrayColor]];
        
        float y = wself.bottomSubMenu.frame.origin.y;
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [wself.bottomSubMenu setFrame:CGRectMake(wself.bottomSubMenu.frame.origin.x, y+70, wself.bottomSubMenu.frame.size.width, wself.bottomSubMenu.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             wself.bottomSubMenu.hidden = YES;
                             [wself.bottomSubMenu setFrame:CGRectMake(wself.bottomSubMenu.frame.origin.x, y, wself.bottomSubMenu.frame.size.width, wself.bottomSubMenu.frame.size.height)];
                             
                         }];
    }
    
    
}
- (IBAction)drawButtonAction:(id)sender {
    __weak __typeof__(self) wself = self;
    [wself subMenuHiddenConfig:wself.bottomSubMenu.isHidden];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return pastilleStateTable.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof__(self) wself = self;
    PastilleStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pastilleState"];
    cell.pastilleStateText.text = [pastilleStateTable objectAtIndex:indexPath.row].UsageDisplayText;
    cell.pastilleStateButton.backgroundColor = [wself colorFromHexString:[pastilleStateTable objectAtIndex:indexPath.row].UsageHexColor];
    cell.pastilleStateIcon.hidden = YES;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = tableView.tintColor;
    [cell setSelectedBackgroundView:bgColorView];
    if ([pastilleStateTable objectAtIndex:indexPath.row].iconImage) {
        
        cell.pastilleStateIcon.image = [pastilleStateTable objectAtIndex:indexPath.row].iconImage;
        cell.pastilleStateIcon.contentMode = UIViewContentModeScaleAspectFit;
        cell.pastilleStateIcon.hidden = NO;
        
    }
    
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (![[pastilleStateTable objectAtIndex:indexPath.row].UsageID isEqualToString:pastilleClicked.state.UsageID]) {
        __weak __typeof__(self) wself = self;
        pastilleClicked.LatLng = LatLng;
        [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:indexPath.row]];
        [UIView setAnimationsEnabled:NO];
        [wself.pastilleNameButton setTitle:pastilleClicked.name forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        wself.personNumberLabel.text = pastilleClicked.personNumber;
        [wself.capacityLabel setTitle:pastilleClicked.capacity forState:UIControlStateNormal];
        for (UIView *j in pastilleClicked.button.subviews){
            if([j isKindOfClass:[M13BadgeView class]]){
                ((M13BadgeView*)j).text = pastilleClicked.personNumber;
            }
        }
        [MFLogger put:@"change state from list"];
        
    }
    
    
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(UIImage*) concatImages : (Sector*) sector {
    
    @autoreleasepool {
        __weak __typeof__(self) wself = self;
        NSMutableArray<UIImage*> *imgLines = [[NSMutableArray<UIImage*> alloc] init];
        for (int i = 0 ; i < sector.lineNumber ; i++) {
            
            UIImage *imgL = [[UIImage alloc] init];
            for (int j = 0 ; j < sector.columnNumber ; j++) {
                if(j==0) {
                    
                    imgL = [images objectAtIndex:j+(sector.columnNumber*i)];
                    
                }
                else {
                    
                    imgL = [wself imageByCombiningImage:imgL withImage:[images objectAtIndex:j+(sector.columnNumber*i)]];
                }
                
            }
            if(imgL != nil) {
                [imgLines addObject:imgL];
            }
            
            
            
        }
        UIImage *image = [[UIImage alloc] init];
        for (int i = 0 ; i < sector.lineNumber ; i++) {
            
            if(i==0) {
                image = (UIImage*)[imgLines objectAtIndex:i];
            }
            else {
                image = [wself imageByCombiningImageLine:image withImage:(UIImage*)[imgLines objectAtIndex:i]];
            }
        }
        
        
        return image;
    }
    
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    
    @autoreleasepool {
        UIImage *image = nil;
        
        CGSize newImageSize = CGSizeMake(firstImage.size.width+secondImage.size.width-4, MAX(firstImage.size.height,secondImage.size.height));
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO,1.0);
        
        [firstImage drawAtPoint:CGPointMake(0,0)];
        [secondImage drawAtPoint:CGPointMake(firstImage.size.width-2,0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //_scrollView.directionalLockEnabled = NO;
        //_scrollView.pagingEnabled = YES;
        //wself.scrollView.contentOffset = CGPointZero;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        return image;
    }
    
}
- (UIImage*)imageByCombiningImageLine:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    @autoreleasepool {
        UIImage *image = nil;
        
        CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width,secondImage.size.width), firstImage.size.height+secondImage.size.height);
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO,1.0);
        
        [firstImage drawAtPoint:CGPointMake(0,0)];
        [secondImage drawAtPoint:CGPointMake(0,roundf((newImageSize.height-secondImage.size.height)))];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //_scrollView.directionalLockEnabled = NO;
        //_scrollView.pagingEnabled = YES;
        //wself.scrollView.contentOffset = CGPointZero;
        
        return image;
    }
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
    
    
        _scrollView.contentScaleFactor = _scrollView.zoomScale;
        for (UILabel *subview in _scrollView.subviews) {
            subview.contentScaleFactor = _scrollView.zoomScale;
        }
    
}

-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    scrollView.contentScaleFactor = scale;
    for (UILabel *subview in scrollView.subviews) {
        subview.contentScaleFactor = scale;
    }
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    __weak __typeof__(self) wself = self;
    return wself.zommableView;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    __weak __typeof__(self) wself = self;
    if ([scrollView isEqual:wself.scrollView])
    [wself deselectPastilleButton];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    __weak __typeof__(self) wself = self;
    if ([segue.identifier isEqualToString:@"sectors"]) {
        
        SectorTableViewController *vc = (SectorTableViewController*)[[segue destinationViewController] topViewController];
        vc.sectors = [[NSMutableArray<Sector*> alloc] init];
        vc.sectors = wself.sectors;
        vc.selectedSector = wself.sector;
        [MFLogger put:@"sector list"];
        
    }
    
    else if ([segue.identifier isEqualToString:@"history"]) {
        DumpViewController *destination = (DumpViewController*) [[segue destinationViewController] topViewController];
        destination.sector = wself.sector;
        [MFLogger put:@"sector history"];
    }
    
    else if ([segue.identifier isEqualToString:@"phistory"]) {
        TableViewController *destination = (TableViewController*) [[segue destinationViewController] topViewController];
        destination.sector = wself.sector;
        destination.pastilleClicked = pastilleClicked;
        [MFLogger put:[NSString stringWithFormat:@"%@ History",pastilleClicked.name]];
    }
    
    else if ([segue.identifier isEqualToString:@"butonInfo"]) {
        
        ButtonInfoViewController *bic = (ButtonInfoViewController*) [segue.destinationViewController topViewController];
        bic.modalPresentationStyle = UIModalPresentationFormSheet;;
        bic.pastilleButton = pastilleClicked;
    }
    
    else {
        
        _menuController = (MenuTableViewController*) [segue destinationViewController];
        _menuController.delagate = self;
        
    }
}

-(void) onClickMenu:(NSInteger)item {
    
    switch (item) {
        case -1:
            [self performSegueWithIdentifier:@"sectors" sender:self];
            break;
        case 0:
            [self performSegueWithIdentifier:@"history" sender:self];
            break;
        case 1:
        {
            __weak __typeof__(self) wself = self;
            wself.stateTableView.hidden = YES;
            wself.stateBottomMenu.hidden = YES;
            [MFLogger put:@"reset action"];
            [self deselectPastilleButton];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Souhaitez-vous réinitialiser l'ensemble des positions?"
                                          message:@"ATTENTION! Cette operation n'est pas réversible, les chronomètres seront remis à 0."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Oui"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [MFLogger put:@"reset YEs"];
                                     
                                     CGRect visibleRect = [_scrollView convertRect:_scrollView.bounds toView:wself.zommableView];
                                     wself.scrollView.zoomScale = 0.0;
                                     [buttons removeAllObjects];
                                     [wself putPastilleButton:^(void) {
                                         [wself.scrollView zoomToRect:visibleRect animated:NO];
                                     }];
                                     
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Non"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [MFLogger put:@"reset NO"];
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            
            [wself presentViewController:alert animated:YES completion:nil];
            break;

        }
        case 2:
        {
            __weak __typeof__(self) wself = self;
            CGRect visibleRect = [_scrollView convertRect:_scrollView.bounds toView:wself.zommableView];
            wself.scrollView.zoomScale = 0.0;
            NSString * message = wself.sector.name;
            UIImage * image = [wself captureScreenInRect:wself.view.frame];
            [wself.scrollView zoomToRect:visibleRect animated:NO];
            NSArray * shareItems = @[message, image];
            
            UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
            avc.modalPresentationStyle = UIModalPresentationPopover;
            avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            avc.popoverPresentationController.barButtonItem = wself.menuList;
            [wself presentViewController:avc animated:YES completion:nil];
            break;
        }
            
            
        default:
            break;
    }
}

- (void) rotation : (UIGestureRecognizer*) sender
{
    CGAffineTransform myTransform = CGAffineTransformMakeRotation(((UIRotationGestureRecognizer*)sender).rotation);
    ((UIRotationGestureRecognizer*)sender).view.transform = myTransform;
}

-(void) rotationGesture:(UIRotationGestureRecognizer *) sender {
    if(sender.state == UIGestureRecognizerStateBegan ||
       sender.state == UIGestureRecognizerStateChanged)
    {
        __weak __typeof__(self) wself = self;
        sender.view.transform = CGAffineTransformRotate(wself.zommableView.transform, sender.rotation);
        _currRotation = _currRotation + sender.rotation;
        [sender setRotation:0];
    }
}

- (IBAction)closeAction:(id)sender {
    
    [MFLogger put:@"close Action"];
    NSString *msg = @"";
    for (PastilleButton *pb in buttons) {
        
        if (pb.state.UsageAbsoluteValue.intValue == -1) {
            
            msg = @"Attention certaines positions ne sont pas renseignées, voulez-vous continuer?";
            break;
            
        }
        
    }
    __weak __typeof__(self) wself = self;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Souhaitez-vous fermer la fenêtre ?"
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Oui"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [MFLogger put:@"close YES"];
                             @autoreleasepool {
                                 
                                 [myTimer invalidate];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 [wself saveScreenshotToPhotosAlbum:wself.view];
                                 wself.sector = nil;
                                 [wself dismissViewControllerAnimated:YES completion:^{
                                     
                                     wself.scrollView.zoomScale = 1.0;
                                     wself.stateTableView.hidden = YES;
                                     wself.stateBottomMenu.hidden = YES;
                                     for (PastilleButton *b in buttons) {
                                         [b.timer invalidate];
                                         [b.button removeFromSuperview];
                                     }
                                     CFRelease((__bridge CFTypeRef)(wself));
                                     
                                 }];
                                 
                                 
                             }
                             
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Non"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [MFLogger put:@"close NO"];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{ [wself presentViewController:alert animated:YES completion:nil]; });
    
    
}

-(UIImage *)captureScreenInRect:(CGRect)captureFrame
{
    __weak __typeof__(self) wself = self;
    CALayer *layer;
    layer = wself.view.layer;
    UIGraphicsBeginImageContext(wself.view.bounds.size);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

- (void)saveScreenshotToPhotosAlbum:(UIView *)view
{
    __weak __typeof__(self) wself = self;
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm"];
    
    wself.topNavBar.topItem.title = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:date],wself.sector.name];
    UIImageWriteToSavedPhotosAlbum([wself captureScreenInRect:wself.view.frame], wself, nil,nil);
    [MFLogger put:@"screen shot"];
}


- (IBAction)rotationAction:(id)sender {
    __weak __typeof__(self) wself = self;
    if (wself.rotationButton.tag == 0) {
        
        [wself enableRotation:YES];
    }
    
    else {
        
        [wself enableRotation:NO];
    }
}

- (void) enableRotation : (BOOL) enable {
    
    __weak __typeof__(self) wself = self;
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:wself action:@selector(rotationGesture:)];
    
    if (enable) {
        
        [wself.rotationButton setBackgroundColor:wself.rotationButton.tintColor];
        [wself.rotationButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
        wself.rotationImg.image = [wself.rotationImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.rotationImg setTintColor:[UIColor groupTableViewBackgroundColor]];
        wself.rotationButton.tag = 1;
        [wself subMenuHiddenConfig:NO];
        [wself enableSelection:NO];
        [wself enableComment:NO];
        wself.scrollView.maximumZoomScale = wself.scrollView.zoomScale;
        wself.scrollView.minimumZoomScale = wself.scrollView.zoomScale;
        wself.scrollView.scrollEnabled = NO;
        
        [wself.zommableView addGestureRecognizer:rotate];
        
    }
    
    else {
        
        [wself.rotationButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [wself.rotationButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        wself.rotationImg.image = [wself.rotationImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.rotationImg setTintColor:[UIColor darkGrayColor]];
        wself.rotationButton.tag = 0;
        [wself.zommableView removeGestureRecognizer:rotate];
        wself.scrollView.scrollEnabled = YES;
        wself.scrollView.maximumZoomScale = 10.0;
        wself.scrollView.minimumZoomScale = 1.0;
        wself.zommableView.transform = CGAffineTransformMakeRotation(0);
        
    }

    
}
- (IBAction)commentAction:(id)sender {
    
    __weak __typeof__(self) wself = self;
    if (wself.commentButton.tag == 0) {
        
        [wself enableComment:YES];
    }
    
    else {
        
        [wself enableComment:NO];
    }
    
}

-(void) enableComment : (BOOL) enable {
    
    __weak __typeof__(self) wself = self;
    if (enable) {
        
        [wself.commentButton setBackgroundColor:wself.commentButton.tintColor];
        [wself.commentButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
        wself.commentImg.image = [wself.commentImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.commentImg setTintColor:[UIColor groupTableViewBackgroundColor]];
        wself.commentButton.tag = 1;
        [wself subMenuHiddenConfig:NO];
        [wself enableRotation:NO];
        [wself enableSelection:NO];
        
    }
    
    else {
        
        [wself.commentButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [wself.commentButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        wself.commentImg.image = [wself.commentImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.commentImg setTintColor:[UIColor darkGrayColor]];
        wself.commentButton.tag = 0;
        
    }

}

- (IBAction)selectionAction:(id)sender {
    
    __weak __typeof__(self) wself = self;
    if (wself.selectionButton.tag == 0) {
        
        [wself enableSelection:YES];
    }
    
    else {
        
        [wself enableSelection:NO];
    }
    
}

-(void) enableSelection : (BOOL) enable {
    
    __weak __typeof__(self) wself = self;
    if (enable) {
        
        [wself.selectionButton setBackgroundColor:wself.selectionButton.tintColor];
        [wself.selectionButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
        wself.selectionImg.image = [wself.selectionImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.selectionImg setTintColor:[UIColor groupTableViewBackgroundColor]];
        wself.selectionButton.tag = 1;
        [wself subMenuHiddenConfig:NO];
        [wself enableRotation:NO];
        [wself enableComment:NO];
        
    }
    
    else {
        
        [wself.selectionButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [wself.selectionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        wself.selectionImg.image = [wself.selectionImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [wself.selectionImg setTintColor:[UIColor darkGrayColor]];
        wself.selectionButton.tag = 0;
        
    }
    
}

-(void) pastilleClickAction:(id) sender withEvent:(UIEvent*)event {
    __weak __typeof__(self) wself = self;
    UIButton *button = (UIButton*)sender;
    if (![button isEqual:pastilleClicked.button] || wself.stateTableView.hidden == YES)
    [wself selectPastilleButton:button];
    
    else {
        NSLog(@"%d",pastilleClicked.state.UsageID.intValue);
        int index = 0;
        
        for (int i = 0; i < pastilleStateTable.count ; i++ ) {
            
            if ([pastilleClicked.state.UsageID isEqualToString:[pastilleStateTable objectAtIndex:i].UsageID]) {
                
                index = i;
                break;
                
            }
            
        }
        if (index < pastilleStateTable.count-1) {
            pastilleClicked.LatLng = LatLng;
            [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:(index+1)]];
            
        }
        
        else {
            pastilleClicked.LatLng = LatLng;
            [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:0]];
            
        }
        [UIView setAnimationsEnabled:NO];
        [wself.pastilleNameButton setTitle:[wself pastilleFromButton:button].name forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        wself.personNumberLabel.text = [wself pastilleFromButton:button].personNumber;
        [wself.capacityLabel setTitle:[wself pastilleFromButton:button].capacity forState:UIControlStateNormal];
        
        [[pastilleClicked.button layer] setBorderWidth:0.0f];
        [pastilleClicked.button.layer removeAllAnimations];
        pastilleClicked = [wself pastilleFromButton:button];
        
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=1.0;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.25];
        theAnimation.toValue=[NSNumber numberWithFloat:1.0];
        [button.layer addAnimation:theAnimation forKey:@"scale"];
        
        wself.stateTableView.hidden = NO;
        wself.stateBottomMenu.hidden = NO;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[pastilleStateTable indexOfObject:pastilleClicked.state] inSection:0];
        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionNone
                                           animated:YES];
        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        
    }
    
    [MFLogger put:@"change state from tap"];
}

- (void) selectPastilleButton:(UIButton*) button {
    __weak __typeof__(self) wself = self;
   
    [UIView setAnimationsEnabled:NO];
    [wself.pastilleNameButton setTitle:[wself pastilleFromButton:button].name forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];
    wself.personNumberLabel.text = [wself pastilleFromButton:button].personNumber;
    [wself.capacityLabel setTitle:[wself pastilleFromButton:button].capacity forState:UIControlStateNormal];
    
    [[pastilleClicked.button layer] setBorderWidth:0.0f];
    [pastilleClicked.button.layer removeAllAnimations];
    pastilleClicked = [wself pastilleFromButton:button];
    [wself topViewHiddenConfig:NO];
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.25];
    theAnimation.toValue=[NSNumber numberWithFloat:1.0];
    [button.layer addAnimation:theAnimation forKey:@"scale"];
    
    wself.stateTableView.hidden = NO;
    wself.stateBottomMenu.hidden = NO;
    
    if (pastilleClicked.capacity.intValue == 1) {
        
        pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"S":self.sector.inventaire_id];
        [wself.stateTableView reloadData];
    }
    
    else {
        
        pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"M":self.sector.inventaire_id];
        [wself.stateTableView reloadData];
        
    }
    
    if (pastilleClicked.state.UsageAbsoluteValue.intValue == -1) {
        
        __weak __typeof__(self) wself = self;
        pastilleClicked.LatLng = LatLng;
        [pastilleClicked setPastilleState:[pastilleStateTable objectAtIndex:1]];
        [UIView setAnimationsEnabled:NO];
        [wself.pastilleNameButton setTitle:pastilleClicked.name forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        wself.personNumberLabel.text = pastilleClicked.personNumber;
        [wself.capacityLabel setTitle:pastilleClicked.capacity forState:UIControlStateNormal];
        for (UIView *j in pastilleClicked.button.subviews){
            if([j isKindOfClass:[M13BadgeView class]]){
                ((M13BadgeView*)j).text = pastilleClicked.personNumber;
            }
        }
        [MFLogger put:@"change state from select"];
        
    }
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int index = 0;
        
        for (int i = 0; i < pastilleStateTable.count ; i++ ) {
            
            if ([pastilleClicked.state.UsageID isEqualToString:[pastilleStateTable objectAtIndex:i].UsageID]) {
                
                index = i;
                break;
                
            }
            
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionNone
                                           animated:YES];
        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    });
    
    [MFLogger put:[@"select pastille : " stringByAppendingString:pastilleClicked.name]];
}

- (void) deselectPastilleButton {
    __weak __typeof__(self) wself = self;
    [wself topViewHiddenConfig:YES];
    wself.stateTableView.hidden = YES;
    wself.stateBottomMenu.hidden = YES;
    [pastilleClicked.button.layer removeAllAnimations];
    [[pastilleClicked.button layer] setBorderWidth:0.0f];
    
    
    
}

- (PastilleButton*) pastilleFromButton : (UIButton*) button {
    
    for (int i = 0; i< buttons.count; i++) {
        
        if([[buttons objectAtIndex:i].button isEqual:button]) {
            
            PastilleButton *pb = [[PastilleButton alloc] init];
            pb = [buttons objectAtIndex:i];
            pb.button = button;
            return pb;
            
        }
        
    }
    return nil;
}

- (IBAction)resetAction:(id)sender {
    __weak __typeof__(self) wself = self;
    wself.stateTableView.hidden = YES;
    wself.stateBottomMenu.hidden = YES;
    [MFLogger put:@"reset action"];
    [self deselectPastilleButton];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Souhaitez-vous réinitialiser l'ensemble des positions?"
                                  message:@"ATTENTION! Cette operation n'est pas réversible, les chronomètres seront remis à 0."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Oui"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [MFLogger put:@"reset YEs"];
                             
                             CGRect visibleRect = [_scrollView convertRect:_scrollView.bounds toView:wself.zommableView];
                             wself.scrollView.zoomScale = 0.0;
                             [buttons removeAllObjects];
                             [wself putPastilleButton:^(void) {
                                 [wself.scrollView zoomToRect:visibleRect animated:NO];
                             }];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Non"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [MFLogger put:@"reset NO"];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [wself presentViewController:alert animated:YES completion:nil];
}

- (void) updatePastillePositions {
    [self.menuController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    __weak __typeof__(self) wself = self;
    CGRect visibleRect = [_scrollView convertRect:_scrollView.bounds toView:wself.zommableView];
    wself.scrollView.zoomScale = 0.0;
    
    float widthRatio = wself.zommableView.bounds.size.width / wself.planImage.image.size.width;
    float heightRatio = wself.zommableView.bounds.size.height / wself.planImage.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * wself.planImage.image.size.width;
    float imageHeight = scale * wself.planImage.image.size.height;
    

    
    for (int i = 0; i < buttons.count; i++) {
        
        NSString *WPPt = [buttons objectAtIndex:i].WPPt;
        NSString *x = [[WPPt componentsSeparatedByString:@","] objectAtIndex:0];
        NSString *y = [[WPPt componentsSeparatedByString:@","] objectAtIndex:1];
        
        float wSize = 25*scale;
        float hSize = 25*scale;
        float hLSize = 5;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            hLSize = 10;
            //wSize = 15;
            //hSize = 15;
        }
        
        
        float xPosition = [x doubleValue] / (800*wself.sector.columnNumber/imageWidth) + (wself.zommableView.frame.size.width/2 - imageWidth/2)-wSize/2;
        float yPosition = [y doubleValue] / (640*wself.sector.lineNumber/imageHeight) + (wself.zommableView.frame.size.height/2 - imageHeight/2)-hSize/2;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xPosition,yPosition,wSize,hSize)];
        
        [[buttons objectAtIndex:i].button setFrame:btn.frame];
        if ([buttons objectAtIndex:i].capacity.intValue == 1)
        [buttons objectAtIndex:i].button.layer.cornerRadius = wSize/2;
        
    }
    [wself.scrollView zoomToRect:visibleRect animated:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        __weak __typeof__(self) wself = self;
        [wself updatePastillePositions];
    }];
}

-(void)closeModal2:(NSNotification *)notification{
    
    [MFLogger put:@"sector changed"];
    [MFLogger put:_sector.name];
    UIViewController *controller=(UIViewController *)notification.object;
    __weak __typeof__(self) wself = self;
    [controller dismissViewControllerAnimated:YES completion:^ {
        
        for (UIView *j in wself.zommableView.subviews){
            if([j isKindOfClass:[UIButton class]]){
                [((UIButton*)j) removeFromSuperview];
            }
        }
        wself.planImage.image = [UIImage imageNamed:@"IMG_0161.PNG"];
        wself.planImage.contentMode = UIViewContentModeScaleAspectFill;
        NSDictionary *dict = notification.userInfo;
        Sector *message = [dict valueForKey:@"sector"];
        wself.sector = message;
        _currRotation = 0.0;
        pastilleClicked = [[PastilleButton alloc] init];
        buttons = [[NSMutableArray<PastilleButton*> alloc] init];
        pastilleStateTable = [[NSMutableArray<PastilleState*> alloc] init];
        images = [[NSMutableArray<UIImage*> alloc] init];
        pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"S":self.sector.inventaire_id];
        [wself setGraphicSetup];
        wself.scrollView.delegate = wself;
        wself.scrollView.scrollEnabled = YES;
        wself.scrollView.maximumZoomScale = 10;
        wself.scrollView.zoomScale = 0;
        wself.rotationButton.tag = 0;
        wself.selectionButton.tag = 0;
        wself.commentButton.tag = 0;
        wself.selectionButton.tag = 0;

        [NSThread detachNewThreadSelector:@selector(startTheBackgroundJobb) toTarget:wself withObject:nil];
    }];
    
}

- (IBAction)addPerson:(id)sender {
    __weak __typeof__(self) wself = self;
    [wself addPerson];
    [MFLogger put:@"add to"];
    [MFLogger put:pastilleClicked.name];

}

- (IBAction)removePerson:(id)sender {
    __weak __typeof__(self) wself = self;
    [wself removePerson];
    [MFLogger put:@"remove from"];
    [MFLogger put:pastilleClicked.name];
    
}

- (void) addPerson {
    __weak __typeof__(self) wself = self;
    if (pastilleClicked.capacity.intValue == 1) {
        
        if (wself.personNumberLabel.text.intValue < 50) {
            
            wself.personNumberLabel.text = [NSString stringWithFormat:@"%i",wself.personNumberLabel.text.intValue+1];
            pastilleClicked.personNumber = wself.personNumberLabel.text;
            for (UIView *j in pastilleClicked.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = pastilleClicked.personNumber;
                }
            }
            if (pastilleClicked.state.UsageAbsoluteValue.intValue !=1) {
                pastilleClicked.LatLng = LatLng;
                
                for (int i = 0 ; i < pastilleStateTable.count ; i++) {
                    
                    PastilleState *state = [pastilleStateTable objectAtIndex:i];
                    if (state.UsageAbsoluteValue.intValue == 1) {
                        
                        [pastilleClicked setPastilleState:state];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                                    atScrollPosition:UITableViewScrollPositionNone
                                                            animated:YES];
                        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                        break;
                        

                        
                    }
                    
                }
                
            }
            
            [pastilleClicked startTimer];
        }
        
    }
    
    else {
        
        if (pastilleClicked.capacity.intValue < 100) {
            
            wself.personNumberLabel.text = [NSString stringWithFormat:@"%i",wself.personNumberLabel.text.intValue+1];
            pastilleClicked.personNumber = wself.personNumberLabel.text;
            for (UIView *j in pastilleClicked.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = pastilleClicked.personNumber;
                }
            }
            if (pastilleClicked.state.UsageAbsoluteValue.intValue !=1) {
                pastilleClicked.LatLng = LatLng;
                for (int i = 0 ; i < pastilleStateTable.count ; i++) {
                    
                    PastilleState *state = [pastilleStateTable objectAtIndex:i];
                    if (state.UsageAbsoluteValue.intValue == 1) {
                        
                        [pastilleClicked setPastilleState:state];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                                    atScrollPosition:UITableViewScrollPositionNone
                                                            animated:YES];
                        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                        break;
                        
                        
                        
                    }
                    
                }
                
            }
            [pastilleClicked startTimer];
        }
        
    }
    [MFLogger put:wself.personNumberLabel.text];
    
}

-(void) removePerson {
    __weak __typeof__(self) wself = self;
    if (pastilleClicked.capacity.intValue == 1) {
        
        if (wself.personNumberLabel.text.intValue > 0 && pastilleClicked.state.UsageAbsoluteValue.intValue == 1) {
            
            wself.personNumberLabel.text = [NSString stringWithFormat:@"%i",wself.personNumberLabel.text.intValue-1];
            pastilleClicked.personNumber = wself.personNumberLabel.text;
            for (UIView *j in pastilleClicked.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = pastilleClicked.personNumber;
                }
            }
            if (pastilleClicked.state.UsageAbsoluteValue.intValue !=0 && wself.personNumberLabel.text.intValue == 0) {
                pastilleClicked.LatLng = LatLng;
                
                for (int i = 0 ; i < pastilleStateTable.count ; i++) {
                    
                    PastilleState *state = [pastilleStateTable objectAtIndex:i];
                    if (state.UsageAbsoluteValue.intValue == 0) {
                        
                        [pastilleClicked setPastilleState:state];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                                    atScrollPosition:UITableViewScrollPositionNone
                                                            animated:YES];
                        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                        break;
                        
                        
                        
                    }
                    
                }
                
            }
            [pastilleClicked startTimer];
        }
    }
    
    else {
        
        if (wself.personNumberLabel.text.intValue > 0 && pastilleClicked.state.UsageAbsoluteValue.intValue == 1) {
            
            wself.personNumberLabel.text = [NSString stringWithFormat:@"%i",wself.personNumberLabel.text.intValue-1];
            pastilleClicked.personNumber = wself.personNumberLabel.text;
            for (UIView *j in pastilleClicked.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = pastilleClicked.personNumber;
                }
            }
            if (pastilleClicked.state.UsageAbsoluteValue.intValue !=0  && wself.personNumberLabel.text.intValue == 0) {
                pastilleClicked.LatLng = LatLng;
                for (int i = 0 ; i < pastilleStateTable.count ; i++) {
                    
                    PastilleState *state = [pastilleStateTable objectAtIndex:i];
                    if (state.UsageAbsoluteValue.intValue == 0) {
                        
                        [pastilleClicked setPastilleState:state];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [wself.stateTableView scrollToRowAtIndexPath:indexPath
                                                    atScrollPosition:UITableViewScrollPositionNone
                                                            animated:YES];
                        [wself.stateTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                        break;
                        
                        
                        
                    }
                    
                }
                
            }
            [pastilleClicked startTimer];
        }
    }
    [MFLogger put:wself.personNumberLabel.text];
}

-(void) topViewHiddenConfig : (BOOL) hidden {
    __weak __typeof__(self) wself = self;
    if (hidden) {
        float y = wself.topView.frame.origin.y;
        
        
        [UIView animateWithDuration:0
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [wself.topView setFrame:CGRectMake(wself.topView.frame.origin.x, y-70, wself.topView.frame.size.width, wself.topView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                             wself.topView.hidden = YES;
                             [wself.topView setFrame:CGRectMake(wself.topView.frame.origin.x, y, wself.topView.frame.size.width, wself.topView.frame.size.height)];
                             
                         }];
        
        
    }
    
    else {
        
        float y = wself.topView.frame.origin.y;
        [wself.topView setFrame:CGRectMake(wself.topView.frame.origin.x, y-70, wself.topView.frame.size.width, wself.topView.frame.size.height)];
        wself.topView.hidden = NO;
        [UIView animateWithDuration:0
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [wself.topView setFrame:CGRectMake(wself.topView.frame.origin.x, y, wself.topView.frame.size.width, wself.topView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

- (void) getLastStates {
    __weak __typeof__(self) wself = self;
    [MFLogger put:@"load last states"];
    for (PastilleButton *btn in buttons) {
        
        NSMutableArray *datas = [[NSMutableArray alloc] init];
        NSMutableArray *datas2 = [[NSMutableArray alloc] init];
        NSManagedObjectContext *managedObjectContext = [wself managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id LIKE %@", btn.name];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        
        NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
        
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity2];
        
        NSArray *fetchedObjects2 = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        datas2 = [[NSMutableArray alloc] initWithArray:fetchedObjects2];
        
        
        int i = 0;
        NSString *b_id = [[datas objectAtIndex:i] valueForKey:@"id"];
        NSString *person = [[datas objectAtIndex:i] valueForKey:@"person"];
        NSString *capacity = [[datas objectAtIndex:i] valueForKey:@"capacity"];
        NSString *state = [[datas objectAtIndex:i] valueForKey:@"state"];
        NSString *timestamp = [[datas objectAtIndex:i] valueForKey:@"timestamp"];
        
        PastilleButton *pb = [[PastilleButton alloc] init];
        pb.name = b_id;
        pb.state = [[PastilleState alloc] init];
        pb.state.UsageDisplayText = state;
        pb.timerValue = timestamp;
        pb.personNumber = person;
        pb.capacity = capacity;
        pb.done = @"0";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSDate *date  = [NSDate date];
        NSString *today = [dateFormatter stringFromDate:date];
        [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm:ss"];
        
        NSDate *pDate = [dateFormatter dateFromString:timestamp];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *pdateS = [dateFormatter stringFromDate:pDate];
        
        if ([today isEqualToString:pdateS] && [[[datas objectAtIndex:i] valueForKey:@"sector_id"] isEqualToString:wself.sector.sector_id]) {
                
            }
        
        
    }
    
}

- (IBAction)shareAction:(id)sender {
    __weak __typeof__(self) wself = self;
    CGRect visibleRect = [_scrollView convertRect:_scrollView.bounds toView:wself.zommableView];
    wself.scrollView.zoomScale = 0.0;
    NSString * message = wself.sector.name;
    UIImage * image = [wself captureScreenInRect:wself.view.frame];
    [wself.scrollView zoomToRect:visibleRect animated:NO];
    NSArray * shareItems = @[message, image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    avc.modalPresentationStyle = UIModalPresentationPopover;
    avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    avc.popoverPresentationController.barButtonItem = sender;
    [wself presentViewController:avc animated:YES completion:nil];

}

- (void) restoreStates {
    [MFLogger put:@"load last states"];
    __weak __typeof__(self) wself = self;
    for (PastilleButton *pastilleButton in buttons) {
        
        NSMutableArray *datas = [[NSMutableArray alloc] init];
        NSManagedObjectContext *managedObjectContext = [wself managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id LIKE %@", pastilleButton.name];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        
        NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
        
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity2];
        
        
        int count = (int)datas.count-1;
        
        for (int j = 0 ; j < datas.count ; j++) {
            
            NSString *b_id = [[datas objectAtIndex:j] valueForKey:@"id"];
            NSString *person = [[datas objectAtIndex:j] valueForKey:@"person"];
            NSString *state = [[datas objectAtIndex:j] valueForKey:@"state"];
            NSString *capacity = [[datas objectAtIndex:j] valueForKey:@"capacity"];
            NSString *timestamp = [[datas objectAtIndex:j] valueForKey:@"timestamp"];
            NSString *sector = [[datas objectAtIndex:j] valueForKey:@"sector_id"];
            NSString *inv = [[datas objectAtIndex:j] valueForKey:@"inventaire_id"];
            PastilleButton *pb = [[PastilleButton alloc] init];
            pb.name = b_id;
            pb.state = [[PastilleState alloc] init];
            pb.state.UsageDisplayText = state;
            pb.timerValue = timestamp;
            pb.personNumber = person;
            pb.capacity = capacity;
            pb.done = @"0";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            NSDate *date  = [NSDate date];
            NSString *today = [dateFormatter stringFromDate:date];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *pDate = [dateFormatter dateFromString:timestamp];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            NSString *pdateS = [dateFormatter stringFromDate:pDate];
            
            if ([today isEqualToString:pdateS] && [sector isEqualToString:_sector.name] && [inv isEqualToString:_sector.inventaire_id])
            {
                if (capacity.intValue == 1) {
                    pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"S":self.sector.inventaire_id];
                    for (int i = 0; i < pastilleStateTable.count; i++) {
                        
                        PastilleState *pastille = [pastilleStateTable objectAtIndex:i];
                        if ([state isEqualToString:pastille.UsageDisplayText]) {
                            
                            pastilleButton.timeStamp = timestamp;
                            [pastilleButton restorePastilleStateTo:pastille];
                            [pastilleButton makeItDisabled];
                            break;
                            
                        }
                    }
                }
                
                else {
                    
                    pastilleStateTable = [PastilleState selectSectorFromLocalDataStore:@"M":self.sector.inventaire_id];
                    for (int i = 0; i < pastilleStateTable.count; i++) {
                        
                        PastilleState *pastille = [pastilleStateTable objectAtIndex:i];
                        if ([state isEqualToString:pastille.UsageDisplayText]) {
                            
                            pastilleButton.timeStamp = timestamp;
                            [pastilleButton restorePastilleStateTo:pastille];
                            [pastilleButton makeItDisabled];
                            break;
                            
                        }
                    }
                    
                }
            }
            
            
        }

        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Les positions barrées ne sont pas enregistrées. Elles sont affichées à titre indicatif uniquement."
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    __weak __typeof__(self) wself = self;
    [super viewWillDisappear:animated];
    [wself deselectPastilleButton];
}

-(void) dealloc {
    
    NSLog(@"dealloc");
}


- (IBAction)buttonInfoAction:(id)sender {
}
@end
