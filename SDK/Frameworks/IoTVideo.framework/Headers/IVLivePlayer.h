//
//  IVLivePlayer.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/20.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVPlayer.h"
#import <QuartzCore/CALayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface IVLivePlayer : IVPlayer

- (instancetype)initWithDeviceId:(NSString *)deviceId;

/// 摄像头预览图层
@property (nonatomic, strong, readonly) CALayer *previewLayer;

/// 镜头位置，默认IVCameraPositionFront
@property (nonatomic, assign, readonly) IVCameraPosition cameraPosition;

/// 是否正在开启摄像头
@property (nonatomic, assign, readonly) BOOL isCameraOpening;

/// 视频帧率，默认16
@property (nonatomic, assign) int frameRate;

/// 启动摄像头
- (void)openCamera;

/// 关闭摄像头
- (void)closeCamera;

/// 切换摄像头
- (void)switchCamera;

/// 是否正在对讲
@property (nonatomic, assign, readonly) BOOL isTalking;

/// 开启对讲
- (void)startTalk;

/// 关闭对讲
- (void)stopTalk;

@end

NS_ASSUME_NONNULL_END
