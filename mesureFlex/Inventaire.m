//
//  Org.m
//  Athlex
//
//  Created by Fares Ben Ammar on 12/08/2015.
//  Copyright (c) 2015 Fares Ben Ammar. All rights reserved.
//

#import "Inventaire.h"
#import "JSONModel.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@implementation Inventaire



+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                       @"id": @"inventaire_id",
                                                       
                                                       }];
}

- (NSMutableArray<Sector*>*) getSectors {
    
    return [Sector selectSectorFromLocalDataStore:self.CampID];
    
}

- (void) insertIntoLocalDataStore {
    
    NSManagedObjectContext *context = [self managedObjectContext2];
    
    // Create a new managed object
    NSManagedObject *Invs = [NSEntityDescription insertNewObjectForEntityForName:@"Inventaires" inManagedObjectContext:context];
    [Invs setValue:self.CampID forKey:@"campid"];
    [Invs setValue:self.CampFullName forKey:@"campfullname"];
    [Invs setValue:self.CampStatus forKey:@"campstatus"];
    [Invs setValue:self.CampIssuer forKey:@"campissuer"];
    [Invs setValue:self.CampCreDateTime forKey:@"campcredatetime"];
    [Invs setValue:self.CampModDateTime forKey:@"campmoddatetime"];
    [Invs setValue:self.CampCustomer forKey:@"campcustomer"];
    [Invs setValue:self.CampSite forKey:@"campsite"];
    [Invs setValue:self.CampPosNbr forKey:@"campposnbr"];
    [Invs setValue:self.CampTotalCount forKey:@"camptotalcount"];
    [Invs setValue:self.CampSectorNames forKey:@"campsectornames"];
    [Invs setValue:self.CampAllowedUsersIDs forKey:@"campallowedusersids"];
    [Invs setValue:self.CampUsageSinglePosIDs forKey:@"campusagesingleposids"];
    [Invs setValue:self.CampUsageMultiplePosIDs forKey:@"campusagemultipleposids"];
    [Invs setValue:self.CampDateStart forKey:@"campdatetimestart"];
    [Invs setValue:self.CampDateEnd forKey:@"campdatetimeend"];
    
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inventaires" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campid = %@", self.CampID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext2] executeFetchRequest:fetchRequest error:&error];
    
    [[items objectAtIndex:0] setValue:self.CampID forKey:@"campid"];
    [[items objectAtIndex:0] setValue:self.CampFullName forKey:@"campfullname"];
    [[items objectAtIndex:0] setValue:self.CampStatus forKey:@"campstatus"];
    [[items objectAtIndex:0] setValue:self.CampIssuer forKey:@"campissuer"];
    [[items objectAtIndex:0] setValue:self.CampCreDateTime forKey:@"campcredatetime"];
    [[items objectAtIndex:0] setValue:self.CampModDateTime forKey:@"campmoddatetime"];
    [[items objectAtIndex:0] setValue:self.CampCustomer forKey:@"campcustomer"];
    [[items objectAtIndex:0] setValue:self.CampSite forKey:@"campsite"];
    [[items objectAtIndex:0] setValue:self.CampPosNbr forKey:@"campposnbr"];
    [[items objectAtIndex:0] setValue:self.CampTotalCount forKey:@"camptotalcount"];
    [[items objectAtIndex:0] setValue:self.CampSectorNames forKey:@"campsectornames"];
    [[items objectAtIndex:0] setValue:self.CampAllowedUsersIDs forKey:@"campallowedusersids"];
    [[items objectAtIndex:0] setValue:self.CampUsageSinglePosIDs forKey:@"campusagesingleposids"];
    [[items objectAtIndex:0] setValue:self.CampUsageMultiplePosIDs forKey:@"campusagemultipleposids"];
    [[items objectAtIndex:0] setValue:self.CampDateStart forKey:@"campdatetimestart"];
    [[items objectAtIndex:0] setValue:self.CampDateEnd forKey:@"campdatetimeend"];
    // Save the object to persistent store
    if (![[self managedObjectContext2] save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    else {
        NSLog(@"Save! %@ %@", error, [error localizedDescription]);
    }
    
}

- (void) deleteFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inventaires" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campid LIKE %@", self.CampID];
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

+ (Inventaire*) selectInventaireFromLocalDataStore:(NSString*) inv {
    
    NSMutableArray<Inventaire*> *inventaireTable = [[NSMutableArray<Inventaire*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *invs = [[NSFetchRequest alloc] initWithEntityName:@"Inventaires"];
    datas  = [[managedObjectContext executeFetchRequest:invs error:nil] mutableCopy];
    Inventaire * obj = [[Inventaire alloc] init];
    for (int i = 0 ; i < datas.count ; i++) {
        
        
        
        obj.CampID = [[datas objectAtIndex:i] valueForKey:@"campid"];
        
        
        if ([obj.CampID isEqualToString:inv]) {
            
            obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
            obj.CampStatus = [[datas objectAtIndex:i] valueForKey:@"campstatus"];
            obj.CampIssuer = [[datas objectAtIndex:i] valueForKey:@"campissuer"];
            obj.CampCreDateTime = [[datas objectAtIndex:i] valueForKey:@"campcredatetime"];
            obj.CampModDateTime = [[datas objectAtIndex:i] valueForKey:@"campmoddatetime"];
            obj.CampCustomer = [[datas objectAtIndex:i] valueForKey:@"campcustomer"];
            obj.CampSite = [[datas objectAtIndex:i] valueForKey:@"campsite"];
            obj.CampPosNbr = [[datas objectAtIndex:i] valueForKey:@"campposnbr"];
            obj.CampTotalCount = [[datas objectAtIndex:i] valueForKey:@"camptotalcount"];
            obj.CampSectorNames = [[datas objectAtIndex:i] valueForKey:@"campsectornames"];
            obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
            obj.CampAllowedUsersIDs = [[datas objectAtIndex:i] valueForKey:@"campallowedusersids"] ;
            obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
            obj.CampUsageSinglePosIDs = [[datas objectAtIndex:i] valueForKey:@"campusagesingleposids"];
            obj.CampUsageMultiplePosIDs = [[datas objectAtIndex:i] valueForKey:@"campusagemultipleposids"];
            obj.CampDateStart = [[datas objectAtIndex:i] valueForKey:@"campdatetimestart"];
            obj.CampDateEnd = [[datas objectAtIndex:i] valueForKey:@"campdatetimeend"];
            
            break;
        }
        
        
    }
    return obj;

}

+ (NSMutableArray<Inventaire*>*) selectInventaireFromLocalDataStore {
    
    NSMutableArray<Inventaire*> *inventaireTable = [[NSMutableArray<Inventaire*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *invs = [[NSFetchRequest alloc] initWithEntityName:@"Inventaires"];
    datas  = [[managedObjectContext executeFetchRequest:invs error:nil] mutableCopy];
    for (int i = 0 ; i < datas.count ; i++) {
        
        Inventaire * obj = [[Inventaire alloc] init];
        obj.CampID = [[datas objectAtIndex:i] valueForKey:@"campid"];
        obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
        obj.CampStatus = [[datas objectAtIndex:i] valueForKey:@"campstatus"];
        obj.CampIssuer = [[datas objectAtIndex:i] valueForKey:@"campissuer"];
        obj.CampCreDateTime = [[datas objectAtIndex:i] valueForKey:@"campcredatetime"];
        obj.CampModDateTime = [[datas objectAtIndex:i] valueForKey:@"campmoddatetime"];
        obj.CampCustomer = [[datas objectAtIndex:i] valueForKey:@"campcustomer"];
        obj.CampSite = [[datas objectAtIndex:i] valueForKey:@"campsite"];
        obj.CampPosNbr = [[datas objectAtIndex:i] valueForKey:@"campposnbr"];
        obj.CampTotalCount = [[datas objectAtIndex:i] valueForKey:@"camptotalcount"];
        obj.CampSectorNames = [[datas objectAtIndex:i] valueForKey:@"campsectornames"];
        obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
        obj.CampAllowedUsersIDs = [[datas objectAtIndex:i] valueForKey:@"campallowedusersids"] ;
        obj.CampFullName = [[datas objectAtIndex:i] valueForKey:@"campfullname"];
        obj.CampUsageSinglePosIDs = [[datas objectAtIndex:i] valueForKey:@"campusagesingleposids"];
        obj.CampUsageMultiplePosIDs = [[datas objectAtIndex:i] valueForKey:@"campusagemultipleposids"];
        obj.CampDateStart = [[datas objectAtIndex:i] valueForKey:@"campdatetimestart"];
        obj.CampDateEnd = [[datas objectAtIndex:i] valueForKey:@"campdatetimeend"];
        

        
        [inventaireTable addObject:obj];
        
    }
    return inventaireTable;
}

+ (void) deleteAllFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inventaires" inManagedObjectContext:[self managedObjectContext]];
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
