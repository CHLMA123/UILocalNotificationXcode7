//
//  MNetworkHelper.m
//  kugou
//
//  Created by MCL on 16/7/7.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager ()

@property (nonatomic, strong)AFHTTPSessionManager *manger;

@end

@implementation NetworkManager

/**
 *  建立网络请求单例
 */
+ (id)shareInstance{
    static NetworkManager *networkHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkHelper = [[NetworkManager alloc] init];
    });
    return networkHelper;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.manger = [AFHTTPSessionManager manager];
        self.manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/html", nil];
        self.manger.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manger.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}


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
    Failure:(void (^)(NSError *error))failure{
    //网络检查
//    [[NetworkManager shareInstance] checkingNetwork:^(AFNetworkReachabilityStatus status) {
//        
//        if (status == AFNetworkReachabilityStatusNotReachable) {
//            [MBProgressHUD showError:@"网络连接失败" ToView:nil];
//
//            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"a" message:@"" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
//            [al show];
//    
//            NSLog(@"网络连接失败");
//        }
//        return ;
//    }];
         //断言
    NSAssert(urlString != nil, @"urlString不能为空");
    NSURL *url = [NSURL URLWithString:urlString];
    //状态栏菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.manger GET:url.absoluteString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //网络请求成功
        if (success) {
            success (responseObject);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络请求失败
        if (failure) {
            failure(error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    
}

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
     Failure:(void(^)(NSError *error))failure{
    //断言
    NSAssert(urlString != nil, @"urlString不能为空");
    NSURL *url = [NSURL URLWithString:urlString];
    [self.manger POST:url.absoluteString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success (responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}



/**
 *   监听网络状态的变化
 */
- (void)checkingNetwork:(void(^)(AFNetworkReachabilityStatus status))netBlock
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (netBlock) {
            netBlock(status);
        }
    }];
    
}

@end
