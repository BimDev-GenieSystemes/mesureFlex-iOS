//
//  ViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 13/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlexViewController.h"
#import "GRRequestsManager.h"

@interface ViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,GRRequestsManagerDelegate>

@property (retain,nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain,nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) FlexViewController *vc;
@property NSString *version;
@property NSString *build;
@property NSString *link;
- (IBAction)OTAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeList;
@property (weak, nonatomic) IBOutlet UIImageView *emptyImg;
@end

