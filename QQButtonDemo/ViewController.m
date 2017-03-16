//
//  ViewController.m
//  QQButtonDemo
//
//  Created by liranhui on 2017/3/14.
//  Copyright © 2017年 liranhui. All rights reserved.
//

#import "ViewController.h"
#import "QQButton.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    QQButton *button = [[QQButton alloc]initWithFrame:CGRectMake(100, 200, 40, 40) AddToView:self.view];
    [button setTitle:@"20" forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
