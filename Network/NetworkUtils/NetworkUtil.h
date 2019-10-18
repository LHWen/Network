//
//  NetworkUtil.h
//  Network
//
//  Created by LHWen on 2019/10/18.
//  Copyright © 2019 LHWen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkUtil : NSObject

/** 检查当前是否连网 */
+ (BOOL)whetherConnectedNetwork;

/** 获取网络类型 */
+ (NSString *)getNetworkType;

/** 获取网络信号强度（dBm） */
+ (int)getSignalStrength;

@end

NS_ASSUME_NONNULL_END
