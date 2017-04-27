//
//  ButtonInfoViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 18/04/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "ButtonInfoViewController.h"

@interface ButtonInfoViewController ()

@end

@implementation ButtonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView setText:[_pastilleButton toString]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
