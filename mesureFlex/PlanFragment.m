//
//  PlanFragment.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 15/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "PlanFragment.h"
#import <UIKit/UIKit.h>
#import "PlanFragment.h"
#import <CoreData/CoreData.h>

@implementation PlanFragment

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"id": @"planFragment_id",
                                                                  @"path": @"URL_PATH",
                                                                  
                                                                  }];
}


- (void) insertIntoLocalDataStore {
    
    NSManagedObjectContext *context = [self managedObjectContext2];
    
    // Create a new managed object
    NSManagedObject *Invs = [NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:context];
    [Invs setValue:self.URL_PATH forKey:@"path"];
    NSNumber *n = [[NSNumber alloc] initWithInt:self.planFragment_id.intValue];
    //[Invs setValue:n forKey:@"id"];
    [Invs setValue:self.sector_id forKey:@"sector_id"];
    [Invs setValue:self.inv_id forKey:@"inventaire_id"];
    [Invs setValue:self.planFragmentData forKey:@"data"];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %d", self.planFragment_id.intValue];
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

+ (NSMutableArray<PlanFragment*>*) selectPlanFragmentFromLocalDataStore:(NSString*) sector_id :(NSString*) inv_id {
    
    NSMutableArray<PlanFragment*> *sectorTable = [[NSMutableArray<PlanFragment*> alloc] init];
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sector_id LIKE %@",sector_id];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    
    double width = 640;
    double height = 512;
    //width = width/1.5;
    //height = height/1.5;
    
    
    for (int i = 0 ; i < datas.count ; i++) {
        
        
        if ([[[datas objectAtIndex:i] valueForKey:@"inventaire_id"] isEqualToString:inv_id]) {
            
            PlanFragment *img = [[PlanFragment alloc] init];
            img.URL_PATH = [[datas objectAtIndex:i] valueForKey:@"path"];
            img.planFragmentData = [[datas objectAtIndex:i] valueForKey:@"data"];
            img.sector_id = sector_id;
            img.planFragment_id = [[datas objectAtIndex:i] valueForKey:@"id"];
            UIImage *mmg = [[UIImage alloc] initWithData:img.planFragmentData];
            
            UIImage *m = mmg;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 0.0);
            [m drawInRect:CGRectMake(0, 0,width,height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            img.planFragmentImage = newImage;
            
            [sectorTable addObject:img];
        }
    }
    
    
    return sectorTable;
    
}
+ (void) deleteAllFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:[self managedObjectContext]];
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
