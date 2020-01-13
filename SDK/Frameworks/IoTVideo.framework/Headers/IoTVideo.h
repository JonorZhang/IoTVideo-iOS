//
//  IoTVideo.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/13.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVLog.h"

#import "IVAVDefine.h"
#import "IVAVCodecable.h"
#import "IVPlayer.h"
#import "IVLivePlayer.h"
#import "IVMonitorPlayer.h"
#import "IVPlaybackPlayer.h"

#import "IVMessageMgr.h"

#import "IVQRCodeHelper.h"
#import "IVLanNetConfig.h"
#import "IVQRCodeNetConfig.h"
#import "IVNetConfig.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *kIoTVideoHostKey;
extern NSString *kIoTVideoHostType;

@interface IoTVideo : NSObject

+ (instancetype)sharedInstance;
@property (class, nonatomic, strong, readonly) IoTVideo *sharedInstance;

@property (nonatomic, strong, nullable, readonly) NSString *ivCid;
@property (nonatomic, strong, nullable, readonly) NSString *ivToken;
@property (nonatomic, strong, nullable, readonly) NSString *accessId;
@property (nonatomic, strong, nullable, readonly) NSString *productId;
@property (nonatomic, strong, nullable, readonly) NSDictionary *userInfo;
@property (nonatomic, assign, readonly) NSInteger SDKVersion;

/// 调试模式
@property (nonatomic, assign) BOOL debugMode;

/// 日志输出回调
@property (nonatomic, copy, nullable) IVLogCallback logCallback;

/// SDK初始化
/// @param productId  app的产品id(从平台注册时获取)
/// @param ivCid      客户id(从平台注册时获取)
/// @param userInfo  其他信息，默认传nil
/// @code
/// [self setupToken]
/// @endcode
/// @remark 录成功服务器
- (void)registerWithProductId:(NSString *)productId ivCid:(NSString *)ivCid userInfo:(nullable NSDictionary *)userInfo;

/// 设置当前用户信息
/// @param ivToken   登录成功服务器返回的`ivToken`
/// @param accessId  是外部访问IotVideo云平台的唯一性身份标识，所有 OpenAPI 接口都需要传入这个头部参数。
- (void)setupToken:(NSString *)ivToken accessId:(NSString *)accessId;

///退出登录时调用
- (void)removeTokenAndAccessId;

/// 刷新ivToken
/// @param ivToken 登录成功服务器返回的`ivToken`
- (void)updateToken:(NSString *)ivToken;

/// SDK反初始化
//- (void)unregister;

@end

NS_ASSUME_NONNULL_END
