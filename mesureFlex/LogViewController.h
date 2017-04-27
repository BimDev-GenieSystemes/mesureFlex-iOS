//
//  LogViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 31/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRRequestsManager.h"

@interface LogViewController : UIViewController <GRRequestsManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) GRRequestsManager *requestsManager;
- (IBAction)pushAction:(id)sender;
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;

@end
