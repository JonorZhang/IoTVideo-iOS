//
//  IVPlaybackPlayer.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/20.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVPlaybackPlayer : IVPlayer

/// 暂停
- (int)pause;

/// 恢复播放
- (int)resume;

/// 指定时间播放
- (void)seekToTime:(NSTimeInterval)time;

/// 快进播放
- (void)fastForward;

/// 取消快进播放
- (void)cancelFastForward;

@end

NS_ASSUME_NONNULL_END
