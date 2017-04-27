//
//  WebViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 24/02/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://i.diawi.com/w4VSfU"]]];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://i.diawi.com/w4VSfU"]];


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

@end
