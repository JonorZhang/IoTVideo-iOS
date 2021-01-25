//
//  IVNetworkSign.h
//  IoTVideo
//
//  Created by ZhaoYong on 2019/12/6.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IVNetworkSign : NSObject

/// MD5 散列
/// @param str 需要散列字符串
+ (NSString *)MD5WithString:(NSString *)str;

/// sha256 散列
/// @param str 需要散列字符串
+ (NSString *)SHA256WithString:(NSString *)str;

/// HMAM-SHA1 签名 通过tokken解析key签名
/// @param str 需要签名字符串
+ (NSString *)HMACSHA1WithString:(NSString *)str;

/// HMAM-SHA1 签名
/// @param str 需要签名的字符串
/// @param key 签名key
+ (NSString *)HMACSHA1WithString:(NSString *)str withKey:(NSString *)key;

/// 获取一套匿名加密数据
/// @param salt salt
+ (NSDictionary *)getAnonymousSecureInfoBySalt:(NSString *)salt;

@end

NS_ASSUME_NONNULL_END
