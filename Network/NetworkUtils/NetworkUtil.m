//
//  NetworkUtil.m
//  Network
//
//  Created by LHWen on 2019/10/18.
//  Copyright © 2019 LHWen. All rights reserved.
//

#import "NetworkUtil.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"

@implementation NetworkUtil

// 检查当前是否连网
+ (BOOL)whetherConnectedNetwork {
    
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    // IP地址
    struct sockaddr_storage zeroAddress;
    // 将地址转换为0.0.0.0
    bzero(&zeroAddress, sizeof(zeroAddress));
    // 地址长度
    zeroAddress.ss_len = sizeof(zeroAddress);
    // 地址类型为UDP, TCP, etc.
    zeroAddress.ss_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    // 如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) {
        return NO;
    }
    
    // 根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable&&!needsConnection) ? YES : NO;
}

// 获取网络类型
+ (NSString *)getNetworkType {
  
    if (![self whetherConnectedNetwork]) return @"NONE";
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *type = @"NONE";
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    type = @"NONE";
                    break;
                case 1:
                    type = @"2G";
                    break;
                case 2:
                    type = @"3G";
                    break;
                case 3:
                    type = @"4G";
                    break;
                case 5:
                    type = @"WIFI";
                    break;
            }
        }
    }
    return type;
}

// 获取网络信号强度（dBm）
+ (int)getSignalStrength {
    
   BOOL iPhoneX = ([UIScreen mainScreen].bounds.size.height >= 812.0) ? YES : NO;
    if (iPhoneX) {
        id statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
        id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
        UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
        int signalStrength = 0;
        
        NSArray *subviews = [[foregroundView subviews][2] subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                break;
            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                break;
            }
        }
        return signalStrength;
    } else {
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        NSString *dataNetworkItemView = nil;
        int signalStrength = 0;
        
        for (id subview in subviews) {
            
            if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]] && [[self getNetworkType] isEqualToString:@"WIFI"] && ![[self getNetworkType] isEqualToString:@"NONE"]) {
                dataNetworkItemView = subview;
                signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                break;
            }
            
            if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]] && ![[self getNetworkType] isEqualToString:@"WIFI"] && ![[self getNetworkType] isEqualToString:@"NONE"]) {
                dataNetworkItemView = subview;
                signalStrength = [[dataNetworkItemView valueForKey:@"_signalStrengthRaw"] intValue];
                break;
            }
        }
        return signalStrength;
    }
}

@end
