//
//  ViewController.m
//  DQPlayer
//
//  Created by 林兴栋 on 2016/12/6.
//  Copyright © 2016年 林兴栋. All rights reserved.
//

#import "ViewController.h"
#import "DDBlineView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:[[DDBlineView alloc] initWithFrame:CGRectMake(0, 100, 400, 400)]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
