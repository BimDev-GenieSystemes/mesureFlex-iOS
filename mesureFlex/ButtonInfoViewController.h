//
//  ButtonInfoViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 18/04/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PastilleButton.h"

@interface ButtonInfoViewController : UIViewController
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property PastilleButton *pastilleButton;
@end
