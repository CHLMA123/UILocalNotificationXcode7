//
//  AppDelegate.m
//  UILocalNotificationDemo
//
//  Created by MCL on 16/9/20.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NetworkManager.h"
#import "NSString+Extend.h"

#define IOS_VERSION     [[[UIDevice currentDevice] systemVersion] floatValue]
static NSInteger        const   kDelayCountThreshold = 5;

@interface AppDelegate ()

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic, assign) NSInteger iDelayCount;//延迟进入(说明:检测到手机SSID与目标SSID匹配时，并不立即进入下一页面，切换网络kDelayCountThreshold次匹配开始)

@property (nonatomic, assign) BOOL bAddLocalNotify;

@property (nonatomic, strong) ViewController *rootVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _rootVC = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_rootVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    NSLog(@"### IOS_VERSION : %f", IOS_VERSION);
    // 首先注册通知请求用户允许通知；
    if (IOS_VERSION >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound
         ];
    }
    
//    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
//        NSLog(@"### addLocalNotification");
//        [self registerLocalNotificationInOldWay:10.0];
//        
//    }
    
    //#pragma mark 移除本地通知，在不需要此通知时记得移除
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    _iDelayCount = 0;
    _bAddLocalNotify = NO;
    
    return YES;
}

- (void)registerLocalNotificationInOldWay:(NSInteger)alertTime {
    
    UILocalNotification *notification=[[UILocalNotification alloc]init];//定义本地通知对象
    
    //设置调用时间
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:alertTime];//通知触发的时间，10s以后
    notification.repeatInterval = 0;
    notification.timeZone = [NSTimeZone defaultTimeZone];// 时区
    
    //设置通知属性
    notification.alertBody=@"最近添加了诸多有趣的特性，是否立即体验？"; //通知主体
    notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
    notification.alertAction=@"打开应用"; //待机界面的滑动动作提示
    notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
//    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
    
    //设置用户信息
    notification.userInfo=@{@"id":@"ConnectTargetWiFi"};//绑定到通知上的其他附加信息
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType  type= UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;  // 通知类型
        
        UIUserNotificationSettings *set = [UIUserNotificationSettings settingsForTypes:type categories:nil];  // 匹配通知类型
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:set];
        
        notification.repeatInterval = 0;
        notification.alertAction=@"push"; //待机界面的滑动动作提示
    }else
    {
        
        notification.repeatInterval = 0;
        
    }
    //调用通知 添加推送到uiapplication
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

#pragma mark 接收本地通知时触发
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"Application did receive local notifications");
    
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    NSLog(@"badge = %ld ", (long)badge);
    badge--;
    badge = badge>=0?badge:0;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    NSDictionary *infoDic = notification.userInfo;
    NSString *notifyID = [infoDic objectForKey:@"id"];
    if ([notifyID isEqualToString:@"ConnectTargetWiFi"]) {
        [_rootVC pushToOverviewOfOtherVC];
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self backgroundHandler];
}

- (void)backgroundHandler{

    NSLog(@"### -->backgroundinghandler");
    UIApplication *apl = [UIApplication sharedApplication];

    _backgroundTaskIdentifier = [apl beginBackgroundTaskWithExpirationHandler:^{

        [self endBackgroundTask];
        NSLog(@"====任务完成了。。。。。。。。。。。。。。。===>");

    }];

    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_bAddLocalNotify) {
            [self checkingNetwork];
            usleep(60*1000);
        }
    });
}

- (void)checkingNetwork{
    
        NSString *currentSSID = [NSString fetchWiFiName];
        
        if ([currentSSID isEqualToString:@"APP210"]){
            
            NSLog(@"...ssid matched");
            if (++_iDelayCount > kDelayCountThreshold && !_bAddLocalNotify){
                _bAddLocalNotify = YES;
                if ([[UIApplication sharedApplication]currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
                    
                    NSLog(@"### addLocalNotification");
                    [self registerLocalNotificationInOldWay:2.0];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self endBackgroundTask];
                });
            }
        }
    
}

- (void)endBackgroundTask{
    // 标记指定的后台任务完成
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
    // 销毁后台任务标识符
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.test.UILocalNotificationDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UILocalNotificationDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UILocalNotificationDemo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
