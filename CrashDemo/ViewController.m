//
//  ViewController.m
//  CrashDemo
//
//  Created by Lix on 17/2/7.
//  Copyright © 2017年 Lix. All rights reserved.
//

#import "ViewController.h"
#import <Bugly/Bugly.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BLYLogWarn(@"Bugly 警告信息");
    BLYLogDebug(@"Bugly Debug");
    BLYLogDebug(@"----上传信息-----");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//---注销Button方法 引起崩溃---
//- (IBAction)buttonAction:(id)sender {
//}

@end
