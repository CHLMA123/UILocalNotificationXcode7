//
//  ViewController.m
//  UILocalNotificationDemo
//
//  Created by MCL on 16/9/20.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import "ViewController.h"
#import "OtherViewController.h"
#import "NSString+Extend.h"

static NSTimeInterval   const   kTimerInterval = 1;


#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define IOS_VERSION     [[[UIDevice currentDevice] systemVersion] floatValue]


@interface ViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSString *mSSID;
@property (nonatomic, strong) NSString *softAPSSID;

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"连接热点";
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.35];
    
    _softAPSSID = @"APP210";
    _mSSID = [NSString fetchWiFiName];
    NSLog(@"### _mSSID : %@", _mSSID);
    
//    [self setupData];
    [self setupView];
}

- (void)setupView{
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicatorView.frame = CGRectMake(0, 0, 120, 120);
    _indicatorView.center = self.view.center;
    _indicatorView.color = [UIColor blueColor];
    _indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_indicatorView];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom]
    ;
    settingBtn.frame = CGRectMake((SCREEN_WIDTH - 200)/2, 120, 200, 44);
    [settingBtn setTitle:@"SETTING Wi-Fi" forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(wifiButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
}

- (void)wifiButtonAction{
    
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
//    [_indicatorView startAnimating];
    return;
}


#pragma mark - OverviewStructure
- (void)pushToOverviewOfOtherVC{
    
    OtherViewController *push = [[OtherViewController alloc] init];
    [self.navigationController pushViewController:push animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
