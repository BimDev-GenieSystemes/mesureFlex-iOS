//
//  PastilleState.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 15/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "PastilleState.h"
#import <UIKit/UIKit.h>
#import "PlanFragment.h"
#import <CoreData/CoreData.h>
#import "WebServiceConfig.h"

@implementation PastilleState

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"id": @"state_id",
                                                                  @"icon": @"URL_PATH_ICON",
                                                                  }];
}

- (void) insertIntoLocalDataStore {
    
    NSManagedObjectContext *context = [self managedObjectContext2];
    
    // Create a new managed object
    NSManagedObject *Invs = [NSEntityDescription insertNewObjectForEntityForName:@"PastilleStates" inManagedObjectContext:context];
    
    [Invs setValue:self.UsageID forKey:@"usageid"];
    [Invs setValue:self.UsageStatus forKey:@"usagestatus"];
    [Invs setValue:self.UsageContext forKey:@"usagecontext"];
    [Invs setValue:self.UsageAbsoluteValue forKey:@"usageabsolutevalue"];
    [Invs setValue:self.UsageAlwaysExists forKey:@"usagealwaysexists"];
    [Invs setValue:self.UsageDisplayText forKey:@"usagedisplaytext"];
    [Invs setValue:self.UsageHexColor forKey:@"usagehexcolor"];
    
    
    if(self.UsageDisplayIcon.length > 0) {
        
        NSString *path = [@"http://mflex.geniesystemes.net/Uploads/BTN/" stringByAppendingString:self.UsageDisplayIcon];
        NSString *url = [NSString stringWithFormat:@"%@",path];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [Invs setValue:imageData forKey:@"usagedisplayicon"];
        
    }
    
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    else {
        NSLog(@"Save! %@ %@", error, [error localizedDescription]);
    }
    
}
- (void) updateInLocalDataStore {
    
}
- (void) deleteFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PastilleStates" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"usageid LIKE %@", self.UsageID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext2] executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [[self managedObjectContext2] deleteObject:managedObject];
    }
    if (![[self managedObjectContext2] save:&error]) {
    }
    
}


+ (NSMutableArray<PastilleState*>*) selectSectorFromLocalDataStore : (NSString*) stateType : (NSString*) inv{
    
    
    Inventaire *inventaire = [[Inventaire alloc] init];
    inventaire = [Inventaire selectInventaireFromLocalDataStore:inv];
    NSMutableArray *allowedID = [[NSMutableArray alloc] init];
    
    if ([stateType isEqualToString:@"S"]) {
        
        allowedID = [inventaire.CampUsageSinglePosIDs componentsSeparatedByString:@"#"].copy;
    }
    
    else {
        
        allowedID = [inventaire.CampUsageMultiplePosIDs componentsSeparatedByString:@"#"].copy;
        
    }
    
    
    
    NSMutableArray<PastilleState*> *pastilleStateTable = [[NSMutableArray<PastilleState*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PastilleStates" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usagecontext LIKE %@) OR (usagecontext LIKE 'A')", stateType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    for (int i = 0 ; i < datas.count ; i++) {
        
        PastilleState * obj = [[PastilleState alloc] init];
        obj.UsageID = [[datas objectAtIndex:i] valueForKey:@"usageid"];
        obj.UsageStatus = [[datas objectAtIndex:i] valueForKey:@"usagestatus"];
        obj.iconImage  = [[UIImage alloc] initWithData:[[datas objectAtIndex:i] valueForKey:@"usagedisplayicon"]];
        obj.UsageContext = [[datas objectAtIndex:i] valueForKey:@"usagecontext"];
        obj.UsageAbsoluteValue = [[datas objectAtIndex:i] valueForKey:@"usageabsolutevalue"];
        obj.UsageAlwaysExists = [[datas objectAtIndex:i] valueForKey:@"usagealwaysexists"];
        obj.UsageDisplayText = [[datas objectAtIndex:i] valueForKey:@"usagedisplaytext"];
        obj.UsageDisplayIcon = [[datas objectAtIndex:i] valueForKey:@"usagedisplayicon"];
        obj.UsageHexColor = [[datas objectAtIndex:i] valueForKey:@"usagehexcolor"];
        
        for (int j = 0; j < allowedID.count; j++) {
            
            if ([[allowedID objectAtIndex:j] isEqualToString:obj.UsageID]) {
                
                [pastilleStateTable addObject:obj];
                break;
            }
            
        }
        
        
    }
    return pastilleStateTable;
    
}

+ (NSMutableArray<PastilleState*>*) selectSectorFromLocalDataStore {
    
    
    NSMutableArray<PastilleState*> *pastilleStateTable = [[NSMutableArray<PastilleState*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PastilleStates" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    for (int i = 0 ; i < datas.count ; i++) {
        
        PastilleState * obj = [[PastilleState alloc] init];
        obj.UsageID = [[datas objectAtIndex:i] valueForKey:@"usageid"];
        obj.UsageStatus = [[datas objectAtIndex:i] valueForKey:@"usagestatus"];
        obj.iconImage  = [[UIImage alloc] initWithData:[[datas objectAtIndex:i] valueForKey:@"usagedisplayicon"]];
        obj.UsageContext = [[datas objectAtIndex:i] valueForKey:@"usagecontext"];
        obj.UsageAbsoluteValue = [[datas objectAtIndex:i] valueForKey:@"usageabsolutevalue"];
        obj.UsageAlwaysExists = [[datas objectAtIndex:i] valueForKey:@"usagealwaysexists"];
        obj.UsageDisplayText = [[datas objectAtIndex:i] valueForKey:@"usagedisplaytext"];
        obj.UsageDisplayIcon = [[datas objectAtIndex:i] valueForKey:@"usagedisplayicon"];
        obj.UsageHexColor = [[datas objectAtIndex:i] valueForKey:@"usagehexcolor"];
        
        [pastilleStateTable addObject:obj];
        
    }
    return pastilleStateTable;
    
}


+ (void) deleteAllFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PastilleStates" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [[self managedObjectContext] deleteObject:managedObject];
    }
    if (![[self managedObjectContext] save:&error]) {
    }

    
}

+ (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

- (NSManagedObjectContext *)managedObjectContext2 {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

@end
