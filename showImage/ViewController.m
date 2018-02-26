//
//  ViewController.m
//  showImage
//
//  Created by xiaozhuzhu on 2018/2/26.
//  Copyright © 2018年 xiaozhuzhu. All rights reserved.
//

#import "ViewController.h"
#import "ImageTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonClick:(UIButton *)sender {
    __block ImageTestViewController *svc = ImageTestViewController.new;
    [svc didMoveToParentViewController:self];
    svc.view.frame = self.view.bounds;
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
    
}


@end
