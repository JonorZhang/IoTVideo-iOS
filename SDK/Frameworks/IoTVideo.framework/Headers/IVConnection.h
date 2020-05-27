//
//  IVConnection.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/5/25.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 单个数据包允许最大字节数
#define MAX_PKG_BYTES 64000

/// 连接状态
typedef NS_ENUM(NSUInteger, IVConnStatus) {
    /// 已断开
    IVConnStatusDisconnected,
    /// 正在连接...
    IVConnStatusConnecting,
    /// 已连接
    IVConnStatusConnected,
    /// 正在断开...
    IVConnStatusDisconnecting,
};

@protocol IVConnection;

/// 连接代理
@protocol IVConnectionDelegate <NSObject>

/// 状态更新
/// @param connection 连接实例
/// @param status 状态
- (void)connection:(id<IVConnection>)connection didUpdateStatus:(IVConnStatus)status;

/// 收到错误
/// @param connection 连接实例
/// @param error 错误
- (void)connection:(id<IVConnection>)connection didReceiveError:(NSError *)error;

/// 收到数据
/// @param connection 连接实例
/// @param data 数据
- (void)connection:(id<IVConnection>)connection didReceiveData:(NSData *)data;

@end

/// 连接类
@protocol IVConnection <NSObject>

/// 初始化连接
/// @param deviceId 设备ID
- (nullable instancetype)initWithDeviceId:(NSString *)deviceId;

/// 连接代理
@property (nonatomic, weak, nullable) id<IVConnectionDelegate> delegate;

/// 设备ID
@property (nonatomic, strong, readonly) NSString *deviceId;

/// 通道ID，连接成功该值才有效
@property (nonatomic, assign, readonly) uint32_t channel;

/// 连接状态
@property (nonatomic, assign, readonly) IVConnStatus status;

/// 开始连接
- (void)connect;

/// 断开连接
- (void)disconnect;

/// 发送自定义数据
///
/// 需要与设备建立专门的连接通道，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
/// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
/// @return 发送是否成功
- (BOOL)sendData:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
