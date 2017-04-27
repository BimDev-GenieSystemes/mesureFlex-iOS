//
//  MenuTableViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 11/04/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MenuDelegate
-(void) onClickMenu : (NSInteger) item;
@end
@interface MenuTableViewController : UITableViewController
@property id <MenuDelegate> delagate;
@end
