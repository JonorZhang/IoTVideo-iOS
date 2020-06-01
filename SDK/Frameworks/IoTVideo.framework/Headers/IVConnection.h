//
//  IVConnection.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/5/25.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 最大连接个数
#define MAX_CONNECTION_NUM 4

/// 单个数据包允许最大字节数
#define MAX_PKG_BYTES 64000

/// 连接类型
typedef NS_ENUM(NSUInteger, IVConnType) {
    /// 视频呼叫，双向音视频
    IVConnTypeLive          = 0,
    /// 监控，单向视频，双向音频（对讲）
    IVConnTypeMonitor       = 1,
    /// 录像回放
    IVConnTypePlayback      = 2,
    /// 数据传输
    IVConnTypeTransmission  = 3,
};

/// 连接状态
typedef NS_ENUM(NSInteger, IVConnStatus) {
    /// 断开中...
    IVConnStatusDisconnecting   = -1,
    /// 已断开
    IVConnStatusDisconnected    = 0,
    /// 连接中...
    IVConnStatusConnecting      = 1,
    /// 已连接
    IVConnStatusConnected       = 2,
};

/// 连接错误
typedef NS_ENUM(NSUInteger, IVConnError) {
    /// 超过最大通道个数
    IVConnError_ExceedsMaxNumber  = 21020,
    /// 重复的连接通道
    IVConnError_Duplicate         = 21021,
    /// 建立连接失败
    IVConnError_ConnectFailed     = 21022,
    /// 连接已断开/连接失败
    IVConnError_Disconnected      = 21023,
    /// 数据超出最大长度
    IVConnError_ExceedsMaxLength  = 21024,
};


@class IVConnection;

/// 连接代理
@protocol IVConnectionDelegate <NSObject>

/// 状态更新
/// @param connection 连接实例
/// @param status 状态
- (void)connection:(IVConnection *)connection didUpdateStatus:(IVConnStatus)status;

/// 收到错误
/// @param connection 连接实例
/// @param error 错误
- (void)connection:(IVConnection *)connection didReceiveError:(NSError *)error;

/// 收到数据
/// @param connection 连接实例
/// @param data 数据
- (void)connection:(IVConnection *)connection didReceiveData:(NSData *)data;

@end

/// 通道连接（抽象类，不要直接实例化，请使用其派生类: IVLivePlayer / IVPlaybackPlayer / IVMonitorPlayer / IVTransmission）
@interface IVConnection: NSObject

/// 连接代理
@property (nonatomic, weak, nullable) id<IVConnectionDelegate> delegate;

/// 设备ID
@property (nonatomic, strong, readonly) NSString *deviceId;

/// 通道ID，连接成功该值才有效
@property (nonatomic, assign, readonly) uint32_t channel;

/// 连接类型
@property (nonatomic, assign, readonly) IVConnType connType;

/// 连接状态
@property (nonatomic, assign, readonly) IVConnStatus connStatus;

/// 开始连接
- (BOOL)connect;

/// 断开连接
- (BOOL)disconnect;

/// 发送自定义数据
///
/// 需要与设备建立专门的连接通道，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
/// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
/// @return 发送是否成功
- (BOOL)sendData:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
