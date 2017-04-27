//
//  SectorTableViewController.h
//  Tap2Check
//
//  Created by Mohamed Mokrani on 22/07/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sector.h"

@interface SectorTableViewController : UITableViewController <UIGestureRecognizerDelegate>
- (IBAction)closeAction:(id)sender;
@property (strong,nonatomic) NSMutableArray<Sector*> *sectors;
@property Sector *selectedSector;
@property UITapGestureRecognizer *tapBehindGesture;
@end
