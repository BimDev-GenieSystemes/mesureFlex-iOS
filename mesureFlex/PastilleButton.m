//
//  PastilleButton.m
//  MesureFlex
//
//  Created by UrbaProd1 on 19/11/2016.
//  Copyright © 2016 URBAPROD. All rights reserved.
//

#import "PastilleButton.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "M13BadgeView.h"
#import "Sector.h"
#import <CoreLocation/CoreLocation.h>
#import "MFLogger.h"
#define SECTOR_AND_DATE ((int) 0)
#define SECTOR_NAME ((int) 1)
#define PROJECT_AND_DATE ((int) 2)
#define PROJECT_NAME ((int) 3)
#define ALL_OPTIONS_AND_DATE ((int) 4)
#define ALL_OPTIONS ((int) 5)

@implementation PastilleButton



- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate
                                   timeIntervalSinceDate:self.startDate];
    //NSLog(@"time interval %f",timeInterval);
    
    //300 seconds count down
    NSTimeInterval timeIntervalCountDown = timeInterval;
    
    NSDate *timerDate = [NSDate
                         dateWithTimeIntervalSince1970:timeIntervalCountDown];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timerValue = timeString;
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateTimer];
    
}


- (void)startTimer
{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.startDate = [NSDate date];
    
    
    [self insertIntoLocalDataStore];
    [self writeToTextFile:ALL_OPTIONS];
    [self displayContent];
    // Create the stop watch timer that fires every 100 ms
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
}



-(NSString*) getV : (int) time {
    
    if (time < 10)
        return [NSString stringWithFormat:@"0%d",time];
    else
        return [NSString stringWithFormat:@"%d",time];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) initPastilleState {
    PastilleState *state;
    
    if (self.capacity.intValue == 1)
    state = [[PastilleState selectSectorFromLocalDataStore:@"S":self.inventaire_id] objectAtIndex:0];
    else
         state = [[PastilleState selectSectorFromLocalDataStore:@"M":self.inventaire_id] objectAtIndex:0];
    
    self.state = state;
    [self.button setImage:state.iconImage forState:UIControlStateNormal];
    [self.button setImageEdgeInsets:UIEdgeInsetsMake(self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4)];
    self.button.backgroundColor = [self colorFromHexString:state.UsageHexColor];
    
}

- (void) setPastilleState : (PastilleState*) state {
    
    for (UIView *j in self.button.subviews){
        if([j isKindOfClass:[UIImageView class]] && [((UIImageView*)j).image isEqual:_disabled.image]){
            
            [j removeFromSuperview];
        }
    }
    
    self.state = state;
    [self.button setImage:state.iconImage forState:UIControlStateNormal];
    [self.button setImageEdgeInsets:UIEdgeInsetsMake(self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4)];
    self.button.backgroundColor = [self colorFromHexString:state.UsageHexColor];
    
    
            
            if (state.UsageAbsoluteValue.intValue == -1) {
                self.personNumber = @"0";
                [self stopTimer];
                for (UIView *j in self.button.subviews){
                    if([j isKindOfClass:[M13BadgeView class]]){
                        ((M13BadgeView*)j).text = self.personNumber;
                    }
                }
            }
            else if (state.UsageAbsoluteValue.intValue != 1 && state.UsageAbsoluteValue.intValue != -1) {
                self.personNumber = @"0";
                for (UIView *j in self.button.subviews){
                    if([j isKindOfClass:[M13BadgeView class]]){
                        ((M13BadgeView*)j).text = self.personNumber;
                    }
                }
            }
            
            else if (state.UsageAbsoluteValue.intValue == 1) {
                self.personNumber = @"1";
                for (UIView *j in self.button.subviews){
                    if([j isKindOfClass:[M13BadgeView class]]){
                        ((M13BadgeView*)j).text = self.personNumber;
                    }
                }
            }
            [self startTimer];
            
        
        //[self insertIntoLocalDataStore];
    
    
}


- (void) insertIntoLocalDataStore {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *Invs = [NSEntityDescription insertNewObjectForEntityForName:@"DataState" inManagedObjectContext:context];
    NSString *b_id = self.name;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *sector_id = self.sector_id;
    NSString *person = self.personNumber;
    NSString *capacity = self.capacity;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date  = [NSDate date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *state = self.state.UsageDisplayText;
    [Invs setValue:b_id forKey:@"id"];
    [Invs setValue:capacity forKey:@"capacity"];
    [Invs setValue:device_id forKey:@"device_id"];
    [Invs setValue:person forKey:@"person"];
    [Invs setValue:sector_id forKey:@"sector_id"];
    [Invs setValue:self.sector_name forKey:@"sector"];
    [Invs setValue:state forKey:@"state"];
    [Invs setValue:timestamp forKey:@"timestamp"];
    [Invs setValue:@"FALSE" forKey:@"saved"];
    [Invs setValue:self.WPHandle forKey:@"wphandle"];
    [Invs setValue:self.WPDateTime forKey:@"wpdatetime"];
    [Invs setValue:self.WPShape forKey:@"wpshape"];
    [Invs setValue:self.WPRadius forKey:@"wpradius"];
    [Invs setValue:self.WPSITE forKey:@"wpsite"];
    [Invs setValue:self.WPBUILD forKey:@"wpbuild"];
    [Invs setValue:self.WPFLOOR forKey:@"wpfloor"];
    [Invs setValue:self.WPZONE forKey:@"wpzone"];
    [Invs setValue:self.WPCLUSTER forKey:@"wpcluster"];
    [Invs setValue:self.WPPLACE forKey:@"wpplace"];
    [Invs setValue:self.WPPt forKey:@"wppt"];
    [Invs setValue:self.WPComment forKey:@"wpcomment"];
    [Invs setValue:self.WPClass forKey:@"wpclass"];
    [Invs setValue:self.WPTYPE forKey:@"wptype"];
    [Invs setValue:self.WPDir forKey:@"wpdir"];
    [Invs setValue:self.WPState forKey:@"wpstate"];
    [Invs setValue:self.WPCritical forKey:@"wpcritical"];
    [Invs setValue:self.WPBookable forKey:@"wpbookable"];
    [Invs setValue:self.WPCAPCITY forKey:@"wpcapcity"];
    [Invs setValue:self.WPOptData1 forKey:@"wpoptdata1"];
    [Invs setValue:self.WPOptData2 forKey:@"wpoptdata2"];
    [Invs setValue:self.WPOptData3 forKey:@"wpoptdata3"];
    [Invs setValue:self.wpcountable forKey:@"wpcountable"];
    [Invs setValue:self.LatLng forKey:@"latlng"];
    [Invs setValue:self.inventaire_id forKey:@"inventaire_id"];
    [Invs setValue:self.state.UsageAbsoluteValue forKey:@"state_id"];
    //yyyymmdd-hh:mm:ss
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [MFLogger put:[NSString stringWithFormat:@"erreur %@ ==> %@",b_id,state]];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"core_data"
                                                              action:@"save_context"
                                                               label:[NSString stringWithFormat:@"Can't Save! %@ %@", error, [error localizedDescription]]
                                                               value:nil] build]];
    }
    
    else {
        NSLog(@"Save! %@ %@", error, [error localizedDescription]);
        [MFLogger put:[NSString stringWithFormat:@"succes %@ ==> %@",b_id,state]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"core_data"
                                                              action:@"save_context"
                                                               label:[NSString stringWithFormat:@"Save! %@ %@", error, [error localizedDescription]]
                                                               value:nil] build]];
    }

    
}

+ (NSMutableArray*) selectFromLocalDataStore : (Sector*) sector {
    
    NSMutableArray *historybyDate;
    NSMutableArray <PastilleButton*> *pbuttons;
    NSMutableArray <NSString*> *dates;
    
    pbuttons = [[NSMutableArray<PastilleButton*> alloc] init];
    dates = [[NSMutableArray<NSString*> alloc] init];
    historybyDate = [[NSMutableArray alloc] init];
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSMutableArray *datas2 = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext2];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity2];
    
    NSArray *fetchedObjects2 = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas2 = [[NSMutableArray alloc] initWithArray:fetchedObjects2];
    
    for (int i = 0 ; i < datas.count ; i++) {
        
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
        pb.personNumber = [NSString stringWithFormat:@"%@/%@",person,capacity];
        
        if ([[[datas objectAtIndex:i] valueForKey:@"sector"] isEqualToString:sector.name] && [[[datas objectAtIndex:i] valueForKey:@"inventaire_id"] isEqualToString:sector.inventaire_id]) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm:ss"];
            
            NSDate *pDate = [dateFormatter dateFromString:timestamp];
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            NSString *pdateS = [dateFormatter stringFromDate:pDate];
            [dates addObject:pdateS];
            [pbuttons addObject:pb];
        }
        
        
        
    }
    
    pbuttons = [[pbuttons reverseObjectEnumerator] allObjects].copy;
    dates = [[dates reverseObjectEnumerator] allObjects].copy;
    
    NSMutableArray<NSString*> *temp = [[NSMutableArray<NSString*> alloc] init];
    
    for (int i = 0; i < dates.count ;i++) {
        
        if (![temp containsObject:[dates objectAtIndex:i]]) {
            
            [temp addObject:[dates objectAtIndex:i]];
            
        }
        
    }
    
    dates = [[NSMutableArray<NSString*> alloc] initWithArray:temp];
    
    for (int i = 0 ; i < dates.count ; i++) {
        NSMutableArray <PastilleButton*> *pbuttonsByDate = [[NSMutableArray <PastilleButton*> alloc] init];
        for (int j = 0; j < pbuttons.count ; j++) {
            NSString *timestamp = [pbuttons objectAtIndex:j].timerValue;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm:ss"];
            
            NSDate *pDate = [dateFormatter dateFromString:timestamp];
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            NSString *pdateS = [dateFormatter stringFromDate:pDate];
            
            if ([pdateS isEqualToString:[dates objectAtIndex:i]]) {
                
                [pbuttonsByDate addObject:[pbuttons objectAtIndex:j]];
                
            }
            
        }
        [historybyDate addObject:pbuttonsByDate];
    }
    return historybyDate;
    
}

- (void) restorePastilleStateTo : (PastilleState*) state {
    
    self.state = state;
    [self.button setImage:state.iconImage forState:UIControlStateNormal];
    [self.button setImageEdgeInsets:UIEdgeInsetsMake(self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4, self.button.frame.size.height/4)];
    self.button.backgroundColor = [self colorFromHexString:state.UsageHexColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm:ss"];
    NSDate *pDate1 = [dateFormatter dateFromString:self.timeStamp];
    NSDate *pDate2;
    pDate2 = [NSDate date];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSTimeInterval timeInterval = [pDate2
                                   timeIntervalSinceDate:pDate1];
    NSLog(@"time interval %f",timeInterval);
    
    //300 seconds count down
    NSTimeInterval timeIntervalCountDown = timeInterval;
    
    NSDate *timerDate = [NSDate
                         dateWithTimeIntervalSince1970:timeIntervalCountDown];
    
    // Create a date formatter
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timerValue = timeString;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.startDate = pDate2;
    // Create the stop watch timer that fires every 100 ms
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
    if (self.capacity.intValue == 1 ) {
        
        if (state.UsageID.intValue == 1) {
            self.personNumber = @"0";
        }
        else if (state.UsageID.intValue == 2 || state.UsageID.intValue == 3) {
            self.personNumber = @"0";
        }
        
        else if (state.UsageID.intValue > 3 && self.personNumber.intValue <= 1) {
            self.personNumber = @"1";
            for (UIView *j in self.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = self.personNumber;
                    break;
                }
            }
            [self updateTimer];
        }
        
    }
    
    else {
        if (state.UsageID.intValue == 1) {
            self.personNumber = @"0";
            for (UIView *j in self.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = self.personNumber;
                    break;
                }
            }
        }
        else if (state.UsageID.intValue == 2) {
            self.personNumber = @"0";
            [self updateTimer];
            for (UIView *j in self.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = self.personNumber;
                    break;
                }
            }
        }
        
        else if (state.UsageID.intValue == 10  && self.personNumber.intValue <= 1) {
            self.personNumber = @"1";
            [self updateTimer];
            for (UIView *j in self.button.subviews){
                if([j isKindOfClass:[M13BadgeView class]]){
                    ((M13BadgeView*)j).text = self.personNumber;
                    break;
                }
            }
        }
        
    }

    
}

+ (void) deleteFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:[self managedObjectContext2]];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext2] executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [[self managedObjectContext2] deleteObject:managedObject];
    }
    if (![[self managedObjectContext2] save:&error]) {
    }
    
}

- (void) makeItDisabled {
    
     _disabled = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.button.frame.size.width, self.button.frame.size.height)];
    _disabled.image = [UIImage imageNamed:@"no-image-icon-3.png"];
    _disabled.contentMode = UIViewContentModeScaleToFill;
    [self.button addSubview:_disabled];
    
}

+ (NSManagedObjectContext *)managedObjectContext2 {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

-(NSString*) dataToLineString {
    
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *sector_id = self.sector_id;
    NSString *person = self.personNumber;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date  = [NSDate date];
    [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm:ss"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *state = self.state.UsageDisplayText;
    NSString *line = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@\n",self.name,self.capacity,device_id,person,sector_id,self.sector_name,state,timestamp,_WPHandle,self.WPDateTime,self.WPShape,self.WPRadius,self.WPSITE,self.WPBUILD,_WPFLOOR,_WPZONE,_WPCLUSTER,_WPPLACE,_WPPt,_WPComment,_WPClass,_WPTYPE,_WPDir,_WPState,_WPCritical,_WPBookable,_WPCAPCITY,_WPOptData1,_WPOptData2,_WPOptData3,_LatLng,_wpcountable];
    
    return line;
    
}

-(void) writeToTextFile : (int) option {
    
    switch (option) {
            
        case 0:
            [self writetofilewithSDName];
            break;
            
        case 1:
            [self writetofilewithSName];
            break;
            
        case 2:
            [self writetofilewithPDName];
            break;
            
        case 3:
            [self writetofilewithPName];
            break;
            
        case 4:
            [self writetofiletobothwithDate];
            break;
            
        case 5:
            [self writetofiletoBoth];
            break;
            
        default:
            break;
    }
}

-(void) writetofilewithSDName {
    
    NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@.DS",device_id,self.sector_name,timestamp];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    // Write the file
    
    // Read the file
    
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"dataFile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:NO];
    }

    
}

-(void) writetofilewithSName {
    
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.DS",device_id,self.sector_name];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    // Write the file
    
    // Read the file
    
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"dataFile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:NO];
    }
    
    
}

-(void) writetofilewithPDName {
    
    NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@.DS",device_id,self.WPSITE,timestamp];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    // Write the file
    
    // Read the file
    
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"dataFile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:NO];
    }
    
}

-(void) writetofilewithPName {
    
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.DS",device_id,self.WPSITE];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    // Write the file
    
    // Read the file
    
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"dataFile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:NO];
    }
    
}

-(void) writetofiletobothwithDate {
    
    NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileNameProject = [NSString stringWithFormat:@"%@-%@-%@.DS",device_id,self.WPSITE,timestamp];
    NSString *fileNameSector = [NSString stringWithFormat:@"%@-%@-%@.DS",device_id,self.sector_name,timestamp];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pathP = [docsDirectory stringByAppendingPathComponent:fileNameProject];
    NSString *pathS = [docsDirectory stringByAppendingPathComponent:fileNameSector];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:pathP]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:pathP]) {
        [fileManager createFileAtPath:pathP contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:pathP encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:pathP atomically:NO];
    }
    
    [fileManager fileExistsAtPath:pathS]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:pathS]) {
        [fileManager createFileAtPath:pathS contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:pathS encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:pathS atomically:NO];
    }
    
}

-(void) writetofiletoBoth {
    
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileNameProject = [NSString stringWithFormat:@"%@#%@#%@.DS",device_id,self.inventaire_id,self.sector_name];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pathP = [docsDirectory stringByAppendingPathComponent:fileNameProject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:pathP]; // Returns a BOOL
    if (![fileManager fileExistsAtPath:pathP]) {
        [fileManager createFileAtPath:pathP contents:[[self dataToLineString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    else {
        NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:pathP encoding:NSUTF8StringEncoding error:nil];
        NSString *newText = [stringFromFile stringByAppendingString:[self dataToLineString]];
        [[newText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:pathP atomically:NO];
    }
    
}





-(void) displayContent{
    //get the documents directory:
    /*NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    NSString * timestamp = newDate;
    NSString *device_id = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.txt",timestamp,self.sector_name,device_id];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *path = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"dataFile"];
    
    NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];*/
}

- (NSString*) toString {
    
    NSString *string = [NSString stringWithFormat:@"McurCampID :  %@\nMCurSector : %@\nMcurCount : %@\n\nWPHandle : %@\nWPDateTime : %@\nWPShape : %@\nWPRadius : %@\nWPSITE : %@\nWPBUILD : %@\nWPFLOOR : %@\nWPZONE : %@\nWPCLUSTER : %@\nWPPLACE : %@\nWPPt : %@\nWPState : %@\nWPClass : %@\nWPTYPE : %@\nWPDir : %@\nWPComment : %@\nWPCritical : %@\nWPBookable : %@\nWPCapacity : %@\nWPCountable : %@\nWPOptData1 : %@\nWPOptData2 : %@\nWPOptData3 : %@",_inventaire_id,_sector_name,_personNumber,_WPHandle,_WPDateTime,_WPShape,_WPRadius,_WPSITE,_WPBUILD,_WPFLOOR,_WPZONE,_WPCLUSTER,_WPPLACE,_WPPt,_WPState,_WPClass,_WPTYPE,_WPDir,_WPComment,_WPCritical,_WPBookable,_WPCAPCITY,_wpcountable,_WPOptData1,_WPOptData2,_WPOptData3];
    
    return string;
    
}

@end
