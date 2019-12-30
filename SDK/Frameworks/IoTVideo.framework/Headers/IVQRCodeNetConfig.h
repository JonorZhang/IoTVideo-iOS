//
//  IVQRCodeNetConfig.h
//  IoTVideo
//
//  Created by ZhaoYong on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface IVQRCodeNetConfig : NSObject

/**
 生成设备配网二维码
 
 时区：系统时区 语言：设备语言
 @param wifiName    wifi name
 @param wifiPwd     wifi 密码
 @param netConfigId 配网id
 @param size        二维码尺寸
*/
+ (nullable UIImage *)createQRCodeWithWifiName:(NSString *)wifiName wifiPwd:(NSString  * _Nullable)wifiPwd netConfigId:(NSString *)netConfigId QRSize:(CGSize)size;


/**
 生成设备配网二维码
 
 @param wifiName    wifi name
 @param wifiPwd     wifi 密码
 @param netConfigId 配网id
 @param language    需要配置的语言
 @param timeZone    timeZone 分钟
 @param size        二维码尺寸
*/
+ (nullable UIImage *)createQRCodeWithWifiName:(NSString *)wifiName wifiPwd:(NSString * _Nullable)wifiPwd netConfigId:(NSString *)netConfigId language:(NSString *)language timeZone:(NSInteger)timeZone QRSize:(CGSize)size;




@end

NS_ASSUME_NONNULL_END
