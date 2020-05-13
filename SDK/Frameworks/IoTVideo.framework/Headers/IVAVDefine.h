//
//  IVAVDefine.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/11/14.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifndef IVAVDefine_h
#define IVAVDefine_h

/// 音视频连接类型
typedef NS_ENUM(NSUInteger, IVAVConnType) {
    /// 视频呼叫，双向音视频
    IVAVConnTypeLive     = 0,
    /// 监控，单向视频，双向音频（对讲）
    IVAVConnTypeMonitor  = 1,
    /// 录像回放
    IVAVConnTypePlayback = 2,
};

/// 播放器状态
typedef NS_ENUM(NSUInteger, IVPlayerStatus) {
    /// 停止
    IVPlayerStatusStoped,
    /// 准备中
    IVPlayerStatusPreparing,
    /// 就绪
    IVPlayerStatusReady,
    /// 加载中
    IVPlayerStatusLoading,
    /// 播放中
    IVPlayerStatusPlaying,
    /// 暂停
    IVPlayerStatusPaused,
    /// 快进中
    IVPlayerStatusFastForward,
};

/// 多媒体类型
typedef NS_ENUM(NSUInteger, IVMediaType) {
    /// 视频
    IVMediaTypeVideo,
    /// 音频
    IVMediaTypeAudio,
};

/// 视频编码类型
typedef NS_ENUM(NSUInteger, IVVideoCodecType) {
    /// H.264
    IVVideoCodecTypeH264  = 1,
    /// MP4
    IVVideoCodecTypeMPEG4 = 2,
    /// JPEG
    IVVideoCodecTypeJPEG  = 3,
    /// MJPEG
    IVVideoCodecTypeMJPEG = 4,
    /// H.265
    IVVideoCodecTypeH265  = 5,
};

/// 视频像素格式
typedef NS_ENUM(NSUInteger, IVPixelFormatType) {
    /// YUV420P
    IVPixelFormatTypeYUV420P = 0,
    /// 32BGRA
    IVPixelFormatType32BGRA  = 1,
};

/// 视频清晰度
typedef NS_ENUM(NSUInteger, IVVideoDefinition) {
    /// 低
    IVVideoDefinitionLow  = 0,
    /// 中
    IVVideoDefinitionMid  = 1,
    /// 高
    IVVideoDefinitionHigh = 2,
};

/// 音频编码类型
typedef NS_ENUM(NSUInteger, IVAudioCodecType) {
    /// G711A
    IVAudioCodecTypeG711A  = 1,
    /// G711U
    IVAudioCodecTypeG711U  = 2,
    /// G726
    IVAudioCodecTypeG726   = 3,
    /// AAC
    IVAudioCodecTypeAAC    = 4,
    /// AMR
    IVAudioCodecTypeAMR    = 5,
    /// ADPCMA
    IVAudioCodecTypeADPCMA = 6,
};

/// 音频每个采样的位宽
typedef NS_ENUM(NSUInteger, IVAudioBitWidth) {
    /// 8 bits
    IVAudioBitWidth8  = 0,
    /// 16 bits
    IVAudioBitWidth16 = 1,
    /// 32 bits
    IVAudioBitWidth32 = 2,
};

/// 音频声道模式
typedef NS_ENUM(NSUInteger, IVAudioSoundMode) {
    /// 单声道
    IVAudioSoundModeMono   = 0,
    /// 立体声
    IVAudioSoundModeStereo = 1,
};

/// 音频格式
typedef NS_ENUM(NSUInteger, IVAudioFormat) {
    /// Linear PCM
    IVAudioFormatLinearPCM = 0,
};

/// 摄像头方位
typedef NS_ENUM(NSUInteger, IVCameraPosition) {
    /// 前置
    IVCameraPositionFront,
    /// 后置
    IVCameraPositionBack,
};

/// 视频原始帧
typedef struct _IVVideoFrame {
    // For YUV: [0]Y [1]U [2]V,
    // For RGBA: [0]BGRA
    
    IVPixelFormatType type;
    uint8_t    *data[3];
    uint32_t    linesize[3];
    uint32_t    width;
    uint32_t    height;
    uint64_t    pts;
    
    // 摄像头采集输出时有效
    CVImageBufferRef imgBuf;
    
} IVVideoFrame;

/// 音频原始帧
typedef struct _IVAudioFrame {
    IVAudioFormat type; //!< 音频采样格式
    uint8_t    *data;   //!< [IN][OUT] 缓冲区地址
    uint32_t    size;   //!< [IN] data最大容量,  [OUT] data有效长度
    uint64_t    pts;    //!< 时间戳，may be 0。
} IVAudioFrame;

/// 视频数据包
typedef struct _IVVideoPacket {
    IVVideoCodecType type;
    uint8_t    *data;
    int         size;
    bool        keyFrame;
    uint64_t    dts;
    uint64_t    pts;
} IVVideoPacket;

/// 音频数据包
typedef struct _IVAudioPacket {
    IVAudioCodecType type;
    uint8_t    *data;
    int         size;
    uint64_t    pts; 
} IVAudioPacket;

// 流媒体信息头
typedef struct _IVAVHeader {
    /*audio info*/
    IVAudioCodecType    audioType;         //!< 音频编码格式
    IVAudioSoundMode    audioMode;         //!< 音频模式： 单声道/双声道
    uint8_t             audioCodecOption;  //!< 音频编码格式的细分类型
    uint8_t             audioBitWidth;     //!< 音频位宽
    uint32_t            audioSampleRate;   //!< 音频采样率
    uint32_t            sampleNumPerFrame; //!< 每帧数据里的采样数
    
    /*video info*/
    IVVideoCodecType    videoType;         //!< 视频类型(h264/h265)
    uint8_t             videoFrameRate;    //!< 视频帧率
    uint32_t            videoWidth;        //!< 视频像素宽度
    uint32_t            videoHeight;       //!< 视频像素高度
} IVAVHeader;

#endif /* IVAVDefine_h */
