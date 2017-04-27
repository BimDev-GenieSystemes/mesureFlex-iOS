//
//  TableViewController.h
//  MesureFlex
//
//  Created by UrbaProd1 on 24/11/2016.
//  Copyright © 2016 URBAPROD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PastilleButton.h"
#import "Sector.h"
#import "PNChart.h"
#import "PastilleState.h"

@interface TableViewController : UITableViewController <UIAccelerometerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PastilleButton *pastilleClicked;
@property (strong, nonatomic) Sector *sector;
@property (strong, nonatomic) NSMutableArray<PastilleState*> *pastillesButton;
@property (strong, nonatomic) IBOutlet PNPieChart *pieChart;
- (IBAction)closeAction:(id)sender;
@end
