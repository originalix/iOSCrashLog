//
//  TestViewController.m
//  CrashDemo
//
//  Created by Lix on 17/2/7.
//  Copyright © 2017年 Lix. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//数组越界
- (IBAction)buttonAction:(id)sender {
    NSArray *array = [NSArray arrayWithObjects:
                      @"lix",
                      @"lixiao",
                      @"lixxx",nil];
    NSLog(@"数组该越界了  %@", array[4]);
}

@end
