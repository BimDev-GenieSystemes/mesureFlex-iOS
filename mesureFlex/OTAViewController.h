//
//  OTAViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
#import "WSMethodes.h"
#import "Parser.h"

@interface OTAViewController : UIViewController
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *loadGif;
@property(nonatomic, strong) WSMethodes *webServiceManager;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *progessValue;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end
