//
//  IVVAS.h
//  IVVAS
//
//  Created by JonorZhang on 2020/4/2.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IoTVideo/IVNetwork_p2p.h>

/* ⚠️Automatically generated by script, do not manually edit! */
#define kIVVASVersion "1.3(1c80) Release"
#define kIVVASCompileDate "2020-12-04 11:36:06"

/// 支付方式
typedef NS_ENUM(NSInteger, IVVASOrderPayType) {
  IVVASOrderPayTypeWxpay = 0,
  IVVASOrderPayTypeAlipay = 1,
};

/// 订单状态
typedef NS_ENUM(NSInteger, IVVASOrderStatus) {
/// 已支付
  IVVASOrderStatusPaid = 0,
/// 未支付
  IVVASOrderStatusUnpaid = 1,
/// 关闭
  IVVASOrderStatusClose = 2,
};

/// 套餐服务类型
typedef NS_ENUM(NSInteger, IVVASServiceType) {
/// 全时套餐
  IVVASServiceTypeVss = 1,
/// 分时套餐
  IVVASServiceTypeEvs = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface IVVAS : NSObject

/// 增值服务管理单例
+ (instancetype)shareInstance;
@property (nonatomic, class, strong, readonly) IVVAS *shared;

/// SDK版本
@property (class, nonatomic, strong, readonly) NSString *SDKVersion;

/// 查询设备的云存详细信息
/// @param deviceId 设备id
/// @param responseHandler 回调
- (void)getServiceDetailInfoWithDeviceId:(NSString *)deviceId responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;

/// 查询多通道设备的云存详细信息
/// @param deviceId 设备id
/// @param channel 视频流通道号。(对于存在多路视频流的设备，如NVR设备，与设备实际视频流通道号对应)。
/// @param responseHandler 回调
- (void)getServiceDetailInfoWithDeviceId:(NSString *)deviceId channel:(NSInteger)channel responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;

//MARK:- 回放

/// 获取云存视频可播放日期信息
/// - 用于终端用户在云存页面中对云存服务时间内的日期进行标注，区分出是否有云存视频文件。
/// @param deviceId 设备id
/// @param timezone 相对于0时区的秒数，例如东八区28800
/// @param responseHandler 回调
- (void)getVideoDateListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;

/// 获取回放文件列表
/// - 获取云存列表，用户对时间轴渲染
/// @param deviceId 设备id
/// @param startTime 开始UTC时间,单位秒
/// @param endTime 结束UTC时间,单位秒 超过一天只返回一天
/// @param responseHandler 回调
- (void)getVideoPlayListWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;

/// 获取回放 m3u8 播放地址
/// @param deviceId 设备id
/// @param startTime 开始UTC时间,单位秒
/// @param endTime 结束UTC时间,单位秒 填 0 则默认播放到最新为止
/// @param responseHandler 回调
/// json:
/// endflag boolean 播放结束标记， 表示此次播放是否把需要播放的文件播完，没有则需以返回的 endtime 为基准再次请求。false 表示未播放完，true 表示播放完成
- (void)getVideoPlayAddressWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTiem:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;


//MARK:- 事件

/// 获取有事件日期信息
/// - 用于终端用户在云存页面中对日期进行标注，区分出是否有事件。
/// @param deviceId 设备id
/// @param timezone 相对于0时区的秒数，例如东八区28800
/// @param responseHandler 回调
- (void)getEventDateListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;

/// 获取事件列表
///
/// @param deviceId 设备id
/// @param startTime 事件告警开始UTC时间, 一般为当天开始时间， 单位秒
/// @param endTime 事件告警结束UTC时间，获取更多应传入当前列表的最后一个事件的开始时间(事件列表按时间逆序排列)；
/// @param pageSize 本次最多查询多少条记录，取值范围 [1 - 50]
/// @param typeMasks 筛选指定类型的事件掩码数组：Array<UInt32>，
/// @param validCloudStorage 是否只返回有效云存期内的事件
/// @param responseHandler 回调 json, 其中pageEnd为分页结束标志
/// @code
/// /// typeMask 过滤规则
/// /// bit 0-15 为SDK内置 bit16 - 32为调用者可自定义类型 bit15 为标志有视频的事件即 0x8000
/// ///
/// /// 对于列表中每个掩码，单个掩码中每个bit按 或 规则来过滤，例如
/// /// almTypeMasks = [3]
/// /// 3 等于 bit0 | bit1， 此时获取到的事件为 包含bit0 或 bit1类型的事件
///
/// /// 对于列表中掩码之间，按 与 的规则来过滤， 例如
/// /// almTypeMasks = [1， 2]
/// /// 1 等于 bit0 ，2 等于 bit1， 此时获取到的事件为 同时包含bit0 和 bit1类型的事件
///
/// /// 加载更多
/// func getMoreEvents() {
///     let endTime = eventList.last?.startTime ?? currDate + 86400
///     IVVAS.shared.getEventList(withDeviceId: deviceID, startTime: currDate, endTime: endTime, pageSize: 50, filterTypeMask: 0) { [weak self](json, error) in
///         /* get more data here */
///     }
/// }
///
/// /// 下拉刷新
/// func refreshEvents() {
///     let endTime = currDate + 86400
///     IVVAS.shared.getEventList(withDeviceId: deviceID, startTime: currDate, endTime: endTime, pageSize: 50, filterTypeMask: 0) { [weak self](json, error) in
///         /* new data here */
///     }
/// }
/// @endcode
- (void)getEventListWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime pageSize:(NSInteger)pageSize filterTypeMask:(NSArray<NSNumber *> * _Nullable)typeMasks validCloudStorage:(BOOL)validCloudStorage responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;


/// 查询事件详情
/// @param deviceId 设备id
/// @param alarmId 报警事件id
/// @param responseHandler 回调json
- (void)getEventInfoWithDeviceId:(NSString *)deviceId alarmId:(NSString *)alarmId responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;


/// 事件删除
/// @param deviceId 设备id
/// @param eventIds 事件 id 数组
/// @param responseHandler 回调
- (void)deleteEventsWithDeviceId:(NSString *)deviceId eventIds:(NSArray<NSString *> *)eventIds responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;


#pragma mark - Deprecated

/// 获取云存视频信息
/// - 用于终端用户在云存页面中对云存服务时间内的日期进行标注，区分出是否有云存视频文件。
/// @param deviceId 设备id
/// @param timezone 相对于0时区的秒数，例如东八区28800
/// @param responseHandler 回调
/// @deprecated Use `-getVideoDateListWithDeviceId:timezone:completionHandler:` instead.
- (void)getVideoListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler API_DEPRECATED("Use -getVideoDateListWithDeviceId:timezone:completionHandler: instead", ios(2.0,9.0));

/// 获取云存回放m3u8列表
///- 终端用户获取云存储的m3u8列表进行回放，同时根据返回的列表对时间轴进行渲染。
/// @param deviceId 设备id
/// @param timezone  相对于0时区的秒数，例如东八区28800
/// @param startTime  时间戳，回放开始时间
/// @param endTime 时间戳，回放结束时间
/// @param responseHandler 回调
/// @deprecated Use `-getVideoPlayListWithDeviceId:tartTime:endTime:completionHandler:` instead.
- (void)getVideoPlaybackListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler API_DEPRECATED("Use -getVideoPlayListWithDeviceId:tartTime:endTime:completionHandler: instead", ios(2.0,9.0));

/// 获取事件列表
/// @param deviceId 设备id
/// @param startTime 事件告警开始UTC时间,单位秒
/// @param endTime 事件告警结束UTC时间，当为0时，默认当天的23点59分59秒
/// @param pageNum 分页查询，第几页 从1开始
/// @param pageSize 分页查询，单页数量 最大 1-50
/// @param responseHandler 回调 json
/// @deprecated Use -getEventListWithDeviceId:tartTime:endTime:pageSize:filterTypeMask:responseHandler: instead
- (void)getEventListWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime pageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler API_DEPRECATED("Use -getEventListWithDeviceId:tartTime:endTime:pageSize:filterTypeMask:responseHandler: instead", ios(2.0,9.0));

@end

NS_ASSUME_NONNULL_END


