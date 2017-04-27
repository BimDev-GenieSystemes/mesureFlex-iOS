//
//  UploadViewController.h
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
#import "GRRequestsManager.h"

@interface UploadViewController : UIViewController <GRRequestsManagerDelegate>
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifImage;
@property (nonatomic, strong) GRRequestsManager *requestsManager;
@end
