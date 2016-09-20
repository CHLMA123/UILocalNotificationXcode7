//
//  AppDelegate.h
//  UILocalNotificationDemo
//
//  Created by MCL on 16/9/20.
//  Copyright © 2016年 CHLMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

/*
 注意
 
 1.iOS系统没有自定义时间间隔的通知，如果要实现类似功能需要注册多个通知
 2.如果重复次数为0的话，通知了一次这个通知就会从系统消除
 3.如果你的通知没有消除，即使卸载了程序，这依然会残留，在下次装入的时候会继续运行，如果想要移除本地通知可以调用UIApplication的cancelLocalNotification:或cancelAllLocalNotifications移除指定通知或所有通知
 4.在使用通知之前必须注册通知类型，如果用户不允许应用程序发送通知，则以后就无法发送通知，除非用户手动到iOS设置中打开通知
 5.通知的声音是由iOS系统播放的，格式必须是Linear PCM、MA4（IMA/ADPCM）、µLaw、aLaw中的一种，并且播放时间必须在30s内，否则将被系统声音替换，同时自定义声音文件必须放到main boundle中
 6.本地通知的数量是有限制的，最近的本地通知最多只能有64个，超过这个数量将被系统忽略
 
 */

