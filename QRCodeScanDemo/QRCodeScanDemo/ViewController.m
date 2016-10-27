//
//  ViewController.m
//  QRCodeScanDemo
//
//  Created by 郭人豪 on 2016/10/27.
//  Copyright © 2016年 Abner_G. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)createUI {
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    
    btn.center = self.view.center;
    
    btn.backgroundColor = [UIColor lightGrayColor];
    
    [btn setTitle:@"二维码扫描" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(qrCodeScanClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

- (void)qrCodeScanClick:(UIButton *)btn {
    
    QRCodeScanViewController * scan = [[QRCodeScanViewController alloc] init];
    
    [self.navigationController pushViewController:scan animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
