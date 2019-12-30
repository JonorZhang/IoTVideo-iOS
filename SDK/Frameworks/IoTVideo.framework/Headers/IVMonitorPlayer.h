//
//  IVMonitorPlayer.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/20.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVMonitorPlayer : IVPlayer

/// 是否正在对讲
@property (nonatomic, assign, readonly) BOOL isTalking;

/// 开启对讲
- (void)startTalk;

/// 关闭对讲
- (void)stopTalk;

@end

NS_ASSUME_NONNULL_END
