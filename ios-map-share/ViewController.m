//
//  ViewController.m
//  ios-map-share
//
//  Created by nick on 16/1/18.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "ViewController.h"
#import "LocChoseController.h"
#import "BLocChoseController.h"
@interface ViewController ()

@end

@implementation ViewController

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)locationShow:(id)sender {
    LocChoseController *locVC=[[LocChoseController alloc]init];
    [self presentViewController:locVC animated:YES completion:nil];
}
- (IBAction)locationShowBaidu:(id)sender {
    BLocChoseController *blocVC=[[BLocChoseController alloc]init];
    [self presentViewController:blocVC animated:YES completion:nil];
}

@end
