//
//  IVNetConfig.h
//  IoTVideo
//
//  Created by ZhaoYong on 2020/1/8.
//  Copyright © 2020 gwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVQRCodeNetConfig.h"
#import "IVLanNetConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface IVNetConfig : NSObject

+ (IVLanNetConfig *)lan;
+ (IVQRCodeNetConfig *)QRCode;

/** 零时订阅设备
 * @param token 订阅的设备访问token
 * @return 是否成功
 */
+ (BOOL)subscribeDeviceWithToken:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
