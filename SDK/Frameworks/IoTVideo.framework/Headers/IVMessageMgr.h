//
//  IVMessageMgr.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/27.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IVMessageType) {
    IVMessageTypeEV = 0,  //!<  通知
    IVMessageTypeFP = 1,  //!<  通知
    IVMessageTypeST = 2,  //!<  通知 / 读
    IVMessageTypeCO = 3,  //!<  通知 / 写
    IVMessageTypeSP = 4,  //!<  通知 / 读 / 写
};

@interface IVMessage : NSObject
/// 设备ID
@property (nonatomic, strong) NSString *deviceId;
/// 消息类型
@property (nonatomic, assign) IVMessageType type;
/// 路径（JSON的叶子节点路径）
@property (nonatomic, strong) NSString *path;
/// 内容（JSON的具体字符串）
@property (nonatomic, strong) NSString *data;

@end

typedef void(^IVMessageCallback)(IVMessage * _Nullable message, NSError * _Nullable error);


@class IVMessageMgr;

/// 消息代理协议
@protocol IVMessageDelegate <NSObject>

/// 接收到事件消息（EVT）:  告警、分享、系统通知
/// @param message 事件消息体
/// @param topic 请参照物模型定义
- (void)didReceiveEventMessage:(NSString *)message topic:(NSString *)topic;

/// 接收到状态消息（ST）
/// @param message 消息体
- (void)didReceiveStatusMessage:(IVMessage *)message;

@end


/// 消息管理类
@interface IVMessageMgr : NSObject

/// 消息管理单例
@property (class, nonatomic, strong, readonly) IVMessageMgr *sharedInstance;
+ (instancetype)sharedInstance;

/// 消息代理
@property (nonatomic, weak) id<IVMessageDelegate> delegate;

/// 消息超时时间，默认10秒
@property (nonatomic, assign) NSTimeInterval timeout;

/// 注册离线消息
/// @param deviceToken APNs返回的deviceToken
/// @param completionHandler 完成回调
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                    completionHandler:(nullable void(^)(NSString * _Nullable json, NSError * _Nullable error))completionHandler;

#pragma mark - 便利方法

/// 控制/操作设备（CO）
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param data JSON数据内容
/// @param completionHandler 完成回调
- (void)controlDevice:(NSString *)deviceId
                 path:(NSString *)path
                 data:(NSString *)data
    completionHandler:(nullable IVMessageCallback)completionHandler;

/// 设置设备参数（SP）
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param data JSON数据内容
/// @param completionHandler 完成回调
- (void)setParameterToDevice:(NSString *)deviceId
                        path:(NSString *)path
                        data:(NSString *)data
           completionHandler:(nullable IVMessageCallback)completionHandler;

/// 获取设备状态（ST）
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param completionHandler 完成回调
- (void)getStatusFromDevice:(NSString *)deviceId
                       path:(NSString *)path
          completionHandler:(nullable IVMessageCallback)completionHandler;

/// 获取设备参数（SP）
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param completionHandler 完成回调
- (void)getParameterFromDevice:(NSString *)deviceId
                          path:(NSString *)path
             completionHandler:(nullable IVMessageCallback)completionHandler;

#pragma mark - 自定义方法

/// 发送消息
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param data JSON数据内容
/// @param type 具有`写属性`的类型
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)setDataToDevice:(NSString *)deviceId
                   path:(NSString *)path
                   data:(NSString *)data
                   type:(IVMessageType)type
                timeout:(NSTimeInterval)timeout
      completionHandler:(nullable IVMessageCallback)completionHandler;

/// 获取消息
/// @param deviceId 设备ID
/// @param path JSON的叶子节点路径
/// @param type 具有`读属性`的类型
/// @param timeout 超时时间
/// @param completionHandler 完成回调
- (void)getDataFromDevice:(NSString *)deviceId
                     path:(NSString *)path
                     type:(IVMessageType)type
                  timeout:(NSTimeInterval)timeout
        completionHandler:(nullable IVMessageCallback)completionHandler;

@end


NS_ASSUME_NONNULL_END
