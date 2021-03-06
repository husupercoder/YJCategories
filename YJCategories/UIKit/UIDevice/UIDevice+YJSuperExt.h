//
//  UIDevice+YJSuperExt.h
//  YJCategoriesGather
//
//  Created by YJHou on 2015/3/17.
//  Copyright © 2015年 侯跃军 houmanager@Hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (YJSuperExt)

/** 根据状态栏获取_网络状态 */
+ (NSString *)getNetWorkStates;

/** 获取手机当前的DNS地址 */
+ (NSArray *)getAllDNSServers;

/** 文件大小的计算转换为KB/MB/GB */
+ (NSString *)fileSizeWithOrginalSize:(CGFloat)orginalSize;

/** 获取设备UUID */
+ (NSString *)yj_UUID;

@end
