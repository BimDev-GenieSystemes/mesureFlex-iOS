//
//  FlexViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sector.h"
#import "FLAnimatedImageView.h"
#import <CoreLocation/CoreLocation.h>
#import "MenuTableViewController.h"
#import "ButtonInfoViewController.h"

@interface FlexViewController : UIViewController <UIScrollViewDelegate,CLLocationManagerDelegate,MenuDelegate>
@property (assign, nonatomic) IBOutlet UIImageView *menuImg;
@property (assign, nonatomic) IBOutlet UIButton *menuButton;
@property (assign, nonatomic) IBOutlet UIImageView *commentImg;
@property (assign, nonatomic) IBOutlet UIButton *commentButton;
@property (assign, nonatomic) IBOutlet UIImageView *drawImg;
@property (assign, nonatomic) IBOutlet UIButton *drawButton;
@property (assign, nonatomic) IBOutlet UIImageView *selectionImg;
@property (assign, nonatomic) IBOutlet UIButton *selectionButton;
@property (assign, nonatomic) IBOutlet UIImageView *capacityImg;
@property (assign, nonatomic) IBOutlet UIButton *capacityLabel;
@property (assign, nonatomic) IBOutlet UILabel *personNumberLabel;
@property (assign, nonatomic) IBOutlet UIButton *addPersonButton;
@property (assign, nonatomic) IBOutlet UIButton *removePersonButton;
@property (assign, nonatomic) IBOutlet UIView *bottomMenuView;
@property (assign, nonatomic) IBOutlet UIView *bottomSubMenu;
@property (assign, nonatomic) IBOutlet UITableView *stateTableView;
@property (assign, nonatomic) IBOutlet UIView *stateBottomMenu;
@property (assign, nonatomic) IBOutlet UIButton *pastilleNameButton;
@property (assign, nonatomic) IBOutlet UIButton *stateHistoryButton;
@property (assign, nonatomic) IBOutlet UIView *personSuperView;
@property (assign, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) IBOutlet UIView *zommableView;
@property (assign, nonatomic) IBOutlet UIImageView *rotationImg;
@property (assign, nonatomic) IBOutlet UIButton *rotationButton;
- (IBAction)rotationAction:(id)sender;
@property (assign, nonatomic) IBOutlet UIImageView *planImage;
@property Sector *sector;
@property (strong,nonatomic) NSMutableArray<Sector*> *sectors;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *loadingGif;
- (IBAction)commentAction:(id)sender;
- (IBAction)selectionAction:(id)sender;
@property (assign, nonatomic) IBOutlet UILabel *timerLabel;
- (IBAction)resetAction:(id)sender;
@property (assign, nonatomic) IBOutlet UINavigationBar *topNavBar;
- (IBAction)addPerson:(id)sender;
- (IBAction)removePerson:(id)sender;
@property (assign, nonatomic) IBOutlet UIView *topView;
- (IBAction)shareAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *trackPadView;
@property MenuTableViewController *menuController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuList;
- (IBAction)buttonInfoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dumpText;

@end
