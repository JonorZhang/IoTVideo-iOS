//
//  libp2p.h
//  IotVideo
//
//  Created by JonorZhang on 2019/11/1.
//  Copyright © 2019 gwell. All rights reserved.
//

#ifndef libp2p_h
#define libp2p_h

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include "iot_video_link_app.h"

typedef NS_ENUM(NSUInteger, IVLogLevel) {
    IVLogLevel_OFF   = 0,    //!< 不打印日志
    IVLogLevel_FATAL = 1,    //!< 严重
    IVLogLevel_ERROR = 2,    //!< 错误
    IVLogLevel_WARN  = 3,    //!< 警告
    IVLogLevel_INFO  = 4,    //!< 信息
    IVLogLevel_DEBUG = 5,    //!< 调试
    IVLogLevel_TRACE = 6,    //!< 跟踪
};

// 日志输出
void _logger_(IVLogLevel level, const char *file, const char *func, int line, const char *fmt, ...);
#define logFatal(fmt, ...) _logger_(IVLogLevel_FATAL, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logError(fmt, ...) _logger_(IVLogLevel_ERROR, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logWarning(fmt, ...) _logger_(IVLogLevel_WARN, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logInfo(fmt, ...) _logger_(IVLogLevel_INFO, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logDebug(fmt, ...) _logger_(IVLogLevel_DEBUG, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logVerbose(fmt, ...) _logger_(IVLogLevel_TRACE, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);
#define logTrace(fmt, ...) _logger_(IVLogLevel_TRACE, __FILE__, __PRETTY_FUNCTION__, __LINE__, fmt, ##__VA_ARGS__);

extern uint32_t AUDIO_BIT_WIDTH_MAP[3];

extern int f_int2enum(uint32_t i, uint32_t map[], int cnt);

#define enum2int(e, map) map[e]
#define int2enum(i, map) f_int2enum(i, map, sizeof(map)/sizeof(map[0]))


int iv_fill_av_header(uint32_t link_chn_id, sAVInfoType pAVInfo);

#endif /* libp2p_h */
