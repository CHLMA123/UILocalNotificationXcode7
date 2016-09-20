//
//  NSString+Extend.m
//  LocalNotifyDemo
//
//  Created by MCL on 16/9/19.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import "NSString+Extend.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation NSString (Extend)

#pragma mark - wifiName
+ (NSString *)fetchWiFiName{
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    if (!ifs) {
        return nil;
    }
    NSString *WiFiName = nil;
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            // 这里其实对应的有三个key:kCNNetworkInfoKeySSID、kCNNetworkInfoKeyBSSID、kCNNetworkInfoKeySSIDData，
            // 不过它们都是CFStringRef类型的
            WiFiName = [info objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            //            WiFiName = [info objectForKey:@"SSID"];
            break;
        }
    }
    return WiFiName;
}

@end
