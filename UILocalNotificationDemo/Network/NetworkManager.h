//
//  MNetworkHelper.h
//  kugou
//
//  Created by MCL on 16/7/7.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, NetworkStatus) {
    
    NetworkStatusUnknown = 0,//未知状态
    NetworkStatusNotReachable,//无网状态
    NetworkStatusReachableViaWWAN,//手机网络
    NetworkStatusReachableViaWiFi,//Wifi网络
};

@interface NetworkManager : NSObject

/**
 *  建立网络请求单例
 */
+ (id)shareInstance;

/**
 *  GET请求
 *
 *  @param url        请求接口
 *  @param parameters 向服务器请求时的参数
 *  @param success    请求成功，block的参数为服务返回的数据
 *  @param failure    请求失败，block的参数为错误信息
 */
- (void)GET:(NSString *)urlString
 Parameters:(NSDictionary *)parameters
    Success:(void(^)(id responseObject))success
    Failure:(void (^)(NSError *error))failure;

/**
 *  POST请求
 *
 *  @param url        要提交的数据结构
 *  @param parameters 要提交的数据
 *  @param success    成功执行，block的参数为服务器返回的内容
 *  @param failure    执行失败，block的参数为错误信息
 */
- (void)PostR:(NSString *)urlString
  Parameters:(NSDictionary *)parameters
     Success:(void(^)(id responseObject))success
     Failure:(void(^)(NSError *error))failure;

/**
 *   监听网络状态的变化
 */
- (void)checkingNetwork:(void(^)(AFNetworkReachabilityStatus status))netBlock;

@end
