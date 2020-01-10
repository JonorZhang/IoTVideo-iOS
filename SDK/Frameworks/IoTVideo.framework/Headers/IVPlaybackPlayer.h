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

@interface IVPlaybackItem: NSObject
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, strong) NSString      *type;
@end

@interface IVPlaybackPage: NSObject
///当前页码索引
@property (nonatomic, assign) uint32_t  pageIndex;
///总页数
@property (nonatomic, assign) uint32_t  totalPage;
///回放文件数组
@property (nonatomic, strong) NSArray<IVPlaybackItem *> *items;
@end


typedef void (^PlaybackListCallback)(IVPlaybackPage *_Nullable page, NSError *_Nullable error);

@interface IVPlaybackPlayer : IVPlayer

/// 创建回放播放器
/// @param deviceId 设备ID
/// @param startTime 回放开始时间点
- (instancetype)initWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime;

/// 暂停
- (int)pause;

/// 恢复播放
- (int)resume;

/// 跳到指定时间播放
/// @param time 指定时间点（精确到秒）
- (void)seekToTime:(NSTimeInterval)time;

/// 快进播放
- (void)fastForward;

/// 取消快进播放
- (void)cancelFastForward;

/// 获取一页回放文件列表
/// @param deviceId 设备ID
/// @param pageIndex 页码索引，从0开始（获取哪一页的回放文件）
/// @param countPerPage 每页包含回放文件数
/// @param startTime 开始时间戳（精确到秒）
/// @param endTime 结束时间戳（精确到秒）
/// @param completionHandler 结果回调
+ (void)getPlaybackListOfDevice:(NSString *)deviceId
                      pageIndex:(NSUInteger)pageIndex
                   countPerPage:(NSUInteger)countPerPage
                      startTime:(NSTimeInterval)startTime
                        endTime:(NSTimeInterval)endTime
              completionHandler:(PlaybackListCallback)completionHandler;

@end

NS_ASSUME_NONNULL_END
