//
//  Sector.m
//  Tap2Check
//
//  Created by Mohamed Mokrani on 17/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "Sector.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "WebServiceConfig.h"
#import "PastilleButton.h"
#import "M13BadgeView.h"

@implementation Sector
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                       @"id": @"sector_id",
                                                       
                                                       }];
}
-(void) getcolumnNumber {
    
    int columnNumber = 0;
    
    for(int j = 0 ; j < _planFragments.count ; j++) {
        
        NSString *imagePath = [_planFragments objectAtIndex:j].URL_PATH;
        if ([imagePath rangeOfString:@"_0-"].location != NSNotFound) {
            columnNumber++;
        }
        
        
    }
    
    _columnNumber = columnNumber;
    _lineNumber = (int)_planFragments.count/_columnNumber;
}

- (void) insertIntoLocalDataStore {
    
    NSManagedObjectContext *context = [self managedObjectContext2];
    NSManagedObject *sector = [NSEntityDescription insertNewObjectForEntityForName:@"Sectors" inManagedObjectContext:context];
    [sector setValue:self.name forKey:@"name"];
    NSNumber *n = [[NSNumber alloc] initWithInt:self.sector_id.intValue];
    [sector setValue:self.sector_id forKey:@"id"];
    n = [[NSNumber alloc] initWithInt:self.level.intValue];
    [sector setValue:n forKey:@"level"];
    [sector setValue:self.inventaire_id forKey:@"inventaire_id"];
    
    NSNumber * c = [[NSNumber alloc] initWithInt:self.columnNumber];
    NSNumber * l = [[NSNumber alloc] initWithInt:self.lineNumber];
    [sector setValue:c forKey:@"column"];
    [sector setValue:l forKey:@"line"];
    
    NSString *url = self.wpFile;
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSData *urlData = [NSData dataWithContentsOfURL:URL];
    NSString *strFileContent = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
    
    [sector setValue:strFileContent forKey:@"wp"];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name LIKE %@) AND (inventaire_id LIKE %@)", self.name,self.inventaire_id];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext2] executeFetchRequest:fetchRequest error:&error];
    
    if (items.count > 0) {
        
        if ([[[items objectAtIndex:0] valueForKey:@"inventaire_id"] isEqualToString:self.inventaire_id]) {
            
            [[items objectAtIndex:0] setValue:UIImagePNGRepresentation(self.thumbNail) forKey:@"thumb"];
            [[items objectAtIndex:0] setValue:UIImagePNGRepresentation(self.planImage) forKey:@"image"];
            
            NSNumber * c = [[NSNumber alloc] initWithInt:self.columnNumber];
            NSNumber * l = [[NSNumber alloc] initWithInt:self.lineNumber];
            [[items objectAtIndex:0] setValue:c forKey:@"column"];
            [[items objectAtIndex:0] setValue:l forKey:@"line"];
            
            // Save the object to persistent store
            if (![[self managedObjectContext2] save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
            else {
                NSLog(@"Save! %@ %@", error, [error localizedDescription]);
            }
            
            
        }
        
    }

    
}

- (void) deleteFromLocalDataStore {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:[self managedObjectContext2]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %d", self.sector_id.intValue];
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

+ (NSMutableArray<Sector*>*) selectSectorFromLocalDataStore : (NSString*) inventaire_id {
    
    NSMutableArray<Sector*> *sectorTable = [[NSMutableArray<Sector*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inventaire_id LIKE %@", inventaire_id];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    for (int i = 0 ; i < datas.count ; i++) {
        
        Sector * obj = [[Sector alloc] init];
        obj.sector_id = [[datas objectAtIndex:i] valueForKey:@"name"];
        obj.inventaire_id = [[datas objectAtIndex:i] valueForKey:@"inventaire_id"];
        obj.name = [[datas objectAtIndex:i] valueForKey:@"name"];
        obj.wpFile = [[datas objectAtIndex:i] valueForKey:@"wp"];
        obj.thumbNail = [UIImage imageWithData:[[datas objectAtIndex:i] valueForKey:@"thumb"]];
        obj.planImage = [UIImage imageWithData:[[datas objectAtIndex:i] valueForKey:@"image"]];
        obj.columnNumber = [[[datas objectAtIndex:i] valueForKey:@"column"] intValue];
        obj.lineNumber = [[[datas objectAtIndex:i] valueForKey:@"line"] intValue];
        
        [sectorTable addObject:obj];
    }

    return sectorTable;
}

+ (NSMutableArray<Sector*>*) selectSectorFromLocalDataStore {
    
    NSMutableArray<Sector*> *sectorTable = [[NSMutableArray<Sector*> alloc] init];
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    datas = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    for (int i = 0 ; i < datas.count ; i++) {
        
        Sector * obj = [[Sector alloc] init];
        obj.sector_id = [[datas objectAtIndex:i] valueForKey:@"name"];
        obj.name = [[datas objectAtIndex:i] valueForKey:@"name"];
        obj.inventaire_id = [[datas objectAtIndex:i] valueForKey:@"inventaire_id"];
        obj.wpFile = [[datas objectAtIndex:i] valueForKey:@"wp"];
        obj.thumbNail = [UIImage imageWithData:[[datas objectAtIndex:i] valueForKey:@"thumb"]];
        obj.planImage = [UIImage imageWithData:[[datas objectAtIndex:i] valueForKey:@"image"]];
        obj.columnNumber = [[[datas objectAtIndex:i] valueForKey:@"column"] intValue];
        obj.lineNumber = [[[datas objectAtIndex:i] valueForKey:@"line"] intValue];
        [sectorTable addObject:obj];
    }
    
    return sectorTable;
}

+ (void) deleteAllFromLocalDataStore {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sectors" inManagedObjectContext:[self managedObjectContext]];
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
