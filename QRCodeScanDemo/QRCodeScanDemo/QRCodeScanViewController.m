//
//  QRCodeScanViewController.m
//  MCDY
//
//  Created by 郭人豪 on 16/8/22.
//  Copyright © 2016年 瞄财网络科技（北京）有限公司. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

//扫描框
@property (nonatomic, strong) UIView * view_bg;
//扫描线
@property (nonatomic, strong) CALayer * layer_scanLine;
//提示语
@property (nonatomic, strong) UILabel * lab_word;

@property (nonatomic, strong) NSTimer * timer;

//采集的设备
@property (strong,nonatomic) AVCaptureDevice * device;
//设备的输入
@property (strong,nonatomic) AVCaptureDeviceInput * input;
//输出
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
//采集流
@property (strong,nonatomic) AVCaptureSession * session;
//窗口
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * previewLayer;

@end

@implementation QRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码扫描";
    
    [self startScan];
}


#pragma mark - add subviews

- (void)addSubviews {
    
    [self.view addSubview:self.view_bg];
    
    [self.view addSubview:self.lab_word];
    
    [_view_bg.layer addSublayer:self.layer_scanLine];
    
}

#pragma mark - make constraints

- (void)makeConstraintsForUI {
    
    [_view_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(0.7 * Screen_Width,  0.5 * (Screen_Height - 64)));
        
        make.left.mas_equalTo(@(0.15 * Screen_Width));
        
        make.top.mas_equalTo(@(0.25 * (Screen_Height - 64) - 32));
    }];
    
    [_lab_word mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(Screen_Width, 21));
        
        make.left.mas_equalTo(@0);
        
        make.top.mas_equalTo(_view_bg.mas_bottom).with.offset(20);
    }];
    
}

#pragma mark - start saomiao

- (void)startScan {
    
    // Device 实例化设备   //获取摄像设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input 设备输入     //创建输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    // Output 设备的输出  //创建输出流
    _output = [[AVCaptureMetadataOutput alloc]init];
    
    //设置代理   在主线程里刷新
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session         //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    // 二维码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode];
    
    // Preview 扫描窗口设置
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _previewLayer.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - 64);
    
    _output.rectOfInterest = CGRectMake(0.15, 0.25, 0.7, 0.5);
    
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    //添加框和线
    [self addSubviews];
    
    [self makeConstraintsForUI];
    
    // Start 开始扫描   //开始捕获
    [_session startRunning];
    
    self.timer.fireDate = [NSDate distantPast];
    
}

#pragma mark - timer action

- (void)scanLineMove {
    
    CABasicAnimation * animation = [[CABasicAnimation alloc] init];
    
    //告诉系统要执行什么样的动画
    animation.keyPath = @"position";
    
    //设置通过动画  layer从哪到哪
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0.5 * (Screen_Height - 64))];
    
    //动画时间
    animation.duration = 4.0;
    
    //设置动画执行完毕之后不删除动画
    animation.removedOnCompletion = NO;
    
    //设置保存动画的最新动态
    animation.fillMode = kCAFillModeForwards;
    
    //添加动画到layer
    [self.layer_scanLine addAnimation:animation forKey:nil];
    
}

#pragma mark - AVCaptureMetadataOutputObjects delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //得到解析到的结果
    NSString * stringValue;
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects.firstObject;
        
        stringValue = metadataObject.stringValue;
    }
    
    //停止扫描
    [_session stopRunning];
    
    self.timer.fireDate = [NSDate distantFuture];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"结果：%@", stringValue] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [_previewLayer removeFromSuperlayer];
        
        [self.timer invalidate];
        
        _timer = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction * actionReStart = [UIAlertAction actionWithTitle:@"重新扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [_session startRunning];
        
        self.timer.fireDate = [NSDate distantPast];
        
    }];
    
    
    [alertController addAction:actionCancel];
    
    [alertController addAction:actionReStart];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - setter and getter

- (UIView *)view_bg {
    
    if (!_view_bg) {
        
        _view_bg = [[UIView alloc] init];
        
        _view_bg.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _view_bg.layer.borderWidth = 1.0;
    }
    
    return _view_bg;
}

- (CALayer *)layer_scanLine {
    
    if (!_layer_scanLine) {
        
        CALayer * layer = [[CALayer alloc] init];
        
        layer.bounds = CGRectMake(0, 0, 0.7 * Screen_Width, 1);
        
        layer.backgroundColor = [UIColor greenColor].CGColor;

        //起点
        layer.position = CGPointMake(0, 0);
        
        //定位点
        layer.anchorPoint = CGPointMake(0, 0);
        
        _layer_scanLine = layer;
    }
    
    return _layer_scanLine;
}

- (UILabel *)lab_word {
    
    if (!_lab_word) {
        
        _lab_word = [[UILabel alloc] init];
        
        _lab_word.textAlignment = NSTextAlignmentCenter;
        
        _lab_word.textColor = [UIColor whiteColor];
        
        _lab_word.font = H13;
        
        _lab_word.text = @"将二维码/条码放入框内，即可进行扫描";
    }
    
    return _lab_word;
}

- (NSTimer *)timer {
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scanLineMove) userInfo:nil repeats:YES];
        
        [_timer fire];
    }
    
    return _timer;
}





@end
