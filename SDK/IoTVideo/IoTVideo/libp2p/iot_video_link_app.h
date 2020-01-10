/*************************************************************************
* Copyright (c) 2019, 深圳技威时代科技有限公司
* All rights reserved.

**************************************************************************/

#ifndef __IOT_VIDEO_LINK_INTERFACE_H_
#define __IOT_VIDEO_LINK_INTERFACE_H_

#include "iot_video_link_def.h"
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#pragma pack (1)

/*!
    \brief
*/
typedef struct GAVFrame
{
    uint8_t*            data[3];             //!< 视频帧各个通道的数据，目前data[0] 指向Y数据，data[1]指向U数据，data[2]指向V数据。
    uint32_t              linesize[3];         //!< 视频帧各个通道的线宽，（一行图像有多少个bytes）
    uint64_t             pts;                  //!< 该视频帧的时间戳
    uint32_t             dwWidth;              //!< 图像宽度
    uint32_t             dwHeight;             //!< 图像高度
} GAVFrame;

/*!
 \brief    视频原始帧数据结构体
 */
typedef struct sVideoRawFrameType
{
    uint8_t                *pData;           //!< 数据缓冲区
    uint32_t            dwSize;         //!< 大小
    uint64_t            u64PTS;         //!< 时间戳
    uint32_t            width;
    uint32_t            height;
}sVideoRawFrameType;

/*!
 \brief    编码后视频帧结构体
 */
typedef struct sVideoFrameType
{
    uint8_t         *pData;             //!< 数据缓冲区
    uint32_t           dwSize;         //!< 大小
    uint64_t          u64PTS;         //!< 时间戳
    uint64_t          u64DTS;         //!< 时间戳
    uint32_t        fgIPic;         //!< 是否I图
}sVideoFrameType;

typedef struct av_decoder_cb
{
    void(*iv_init_decoder)(uint32_t link_chn_id, void **pAudioDecoder, void **pVideoDecoder);
    int(*iv_decode_audio)(uint32_t link_chn_id, void *pAudioDecoder, uint8_t *pInputBuf, uint32_t dwInputDataSize, uint8_t *pOutputBuf, uint32_t *pdwOutputDataSize);
    int(*iv_decode_video)(uint32_t link_chn_id, void *pVideoDecoder, uint8_t *pInputData, uint32_t u32InputSize, uint64_t u64InputPTS, GAVFrame *pOutputFrame);
    void(*iv_destory_decoder)(uint32_t link_chn_id, void * pAudioDecoder, void *pVideoDecoder);
    void(*iv_recv_av_data)(uint32_t link_chn_id, uint8_t *pAudioData, uint32_t u32AudioDataLen, uint32_t u32Frames, uint64_t u64APTS, uint8_t *pstVideoData, uint32_t u32VideoLen, uint64_t u64VPTS);
    void(*iv_recv_user_data)(uint32_t link_chn_id, void *pData, uint32_t u32Size);
    void(*iv_recv_avheader)(uint32_t link_chn_id, sAVInfoType * pAVInfo);
}av_decoder_cb;

typedef struct av_encoder_cb
{
    void(*iv_init_encoder)(uint32_t link_chn_id, void **pAudioEncoder, void **pVideoEncoder);
    int(*iv_encode_audio)(uint32_t link_chn_id, void *pAudioEncoder, uint8_t *pInputBuf, uint32_t u32InputSize, uint8_t* pOutputData, uint32_t *pOutputDataSize);
    int(*iv_encode_video)(uint32_t link_chn_id, void *pVideoEncoder, sVideoRawFrameType *pInput, struct sVideoFrameType *pOutput, uint32_t u32MaxSize);
    void(*iv_destory_encoder)(uint32_t link_chn_id, void *pAudioEncoder, void *pVideoEncoder);
}av_encoder_cb;

typedef struct av_link_req_param_s
{
    uint64_t        dst_id;
    uint32_t        link_chnid;
    iv_conn_type_e    conn_type;
    uint32_t        call_param[8];
    sAVInfoType        avinfo_encode;//APP端音视频编码参数
    av_decoder_cb   pdecode;
    av_encoder_cb   pencoder;
}av_link_req_param_s;
                
/* sdk初始化参数结构体 */
typedef struct iot_video_init_param_s
{
    uint32_t                    iv_log_level;             //查看1.5日志级别定义
    uint32_t                    iv_broadcast;            //是否进行局域网搜索,是:1,否:0
    uint64_t                    access_id;                //!< 访问id，由WEB登陆时获取
    char                           access_token[128];         //!< APP访问token，由WEB登陆时获取
    iv_discon_av_link_cb        av_link_discon_cb;        //!< 通道断开通知
    iv_app_gdm_callback            ivm_rcv_data_mode_cb;    //!< 收到某个id的数据信息
    iv_rcv_ev_msg_callback        iv_rcv_ev_cb;            //!< 收到事件通知
    iv_send_service_resp        iv_send_srv_resp_cb;    //!< 收到service请求回应
    iv_rcv_pass_through_msg     rcv_passthrough_cb;        //!< 收到终端透传消息
    iv_send_msg_ack             send_passthrough_ack_cb;//!< 发送终端透传消息状态结果
    iv_get_gdm_data_resp        ivm_get_gdm_data_cb;    //!< 获取物模型信息回调
    iv_send_last_word_resp      iv_send_last_word_resp_cb; //!< 遗言响应
    
} iot_video_init_param_s;

typedef enum{
    IV_ERROR_NONE = 0,
    IV_ERROR_ILLEGAL_INPUT = 1,
    IV_ERROR_MEM_MALLOC_FAIL = 2,
}iv_error_e;

/**
*    @\brief  初始化Iot SDK
*    @\param  init_param  Iot SDK初始化参数
*    @\return  0 : 成功   其他值:失败原因
*/
int iv_access_init( iot_video_init_param_s*    init_param );

/**
*    @\brief  网络库退出并释放资源
*/
int iv_access_destroy(void);

/**
*    @\brief 设置用户token
*    @\param access_token token数组
*    @\param token_len token的长度
*    @\return 0: 成功, 其他值失败
*/
int iv_set_access_token(char* access_token, int token_len);

/**
*    @\brief  获取SDK版本号
*    @\return  版本号
*/
int get_sdk_version(void);

/**
*    @\brief  获取局域网的设备信息
*    @\param     dev_cnt 返回搜索到的局域网设备个数
*    @\return 返回数据内容，使用iot_dev_info_s解析
*/
char* get_lan_device_info(int* dev_cnt);

/**
*    @\brief     创建一个连接通道，此函数为阻塞函数
*    @\param        link_param 连接参数
*    @\return    大于等于0：成功，-1：失败
*/
int iv_start_av_link(av_link_req_param_s link_param, av_link_rcv_param_s* rcv_param);

/**
*    @\brief     停止一个连接通道，此函数为阻塞函数
*    @\param        link_chn_id 通道id
*    @\return    -1:失败，其他值:成功
*/
int iv_stop_av_link(uint32_t link_chn_id );

/**
*    @\brief     获取解码后的YUV视频数据
*    @\param        link_chn_id 通道id
*    @\return    0：成功，-1:失败
*/
int iv_get_video_yuvframe(GAVFrame* pFrame, uint32_t link_chn_id);

/**
*    @\brief     获取解码前的H264/H265视频数据
*    @\param        link_chn_id 通道id
*    @\return    0：成功，-1:失败
*/
int iv_get_video_before_decode_frame(uint8_t* data_buf, uint32_t* buf_len, uint64_t* pts, uint32_t link_chn_id);

/**
*    @\brief     获取音频pcm数据
*    @\param        link_chn_id 通道id
*    @\return    0：成功，-1:失败
*/
int iv_get_audio_data(uint8_t* pbuf, uint32_t get_size, uint64_t* audio_pts, uint32_t link_chn_id);

int iv_fill_audio_raw_data(uint8_t* pdata, uint32_t data_len, uint32_t link_chn_id);

int iv_fill_video_raw_frame(uint8_t* pdata, uint32_t data_len, uint32_t link_chn_id);

/*
*    @\brief   监控中发送的用户数据
*    @\param   link_chn_id 通道id
*
*/
int iv_send_user_data_link_chn(uint32_t link_chn_id, uint8_t * pdata,uint32_t data_len);

/*
*    @\brief 发送CO/SP信息给设备
*    @\param ivm_data_object_s 消息结构体
*    @\return 大于0返回消息ID，0失败
*/
uint32_t ivm_send_data_object_value(ivm_data_object_s data_object);

/*
*    @\brief 从服务器获取某个设备的物模型信息，服务器返回后触发ivm_get_gdm_data_cb回调
*    @\param id  请求设备id
*    @\param url 请求的物模型信息路径
*    @\param urllen 请求的物模型信息路径长度
*    @\return 大于0返回消息ID，0失败
*/
uint32_t ivm_get_gdm_data(uint64_t id, void *url,uint16_t urllen);

/*
*    @\brief Hsa256加密并将结果用16进制编码后返回
*    @\param output 调用者分配64字节空间
    @\return 返回output的长度
*/

int iv_sha256_with_hex(const char* input, int inlen,char* output);
/*
*    @\brief Hmac-Sha1加密并将结果用base64编码后返回
*    @\param output 调用者分配64字节空间
*    @\return 返回output的长度
*/

int iv_hmac_encode_sha1_with_base64(const char* input, int len, char* output);

/*
*    @\brief 临时订阅设备
*    @\param token_arr 订阅的设备访问token数组
*    @\param token_total_len token_arr的长度
*    @\param cnt_token 订阅的设备访问token个数
*    @\return 返回0成功， -1 失败
*/
int iv_subscribe_dev(uint8_t* token_arr, int token_total_len, int cnt_token);
    

/**
*    @\brief     发送终端透传消息
*    @\param        id       目标终端id
*    @\param        mesg     发送消息
*    @\param        mesglen  发送消息长度
*    @\return    0 失败    非0为消息帧ID
*   @\relation  与rcv_passthrough_cb 回调为一对收发函数，send_passthrough_ack_cb为消息发送状态回调函数
*   @\请特别注意:发送透传消息需要对端回应，且要确定发送请求唯一性的，可在mesg消息体内增加判断消息唯一性的字段。
*/
uint32_t iv_send_passthrough_msg(uint64_t id, void *mesg, uint32_t mesglen);

/**
*    @\brief     发送服务器消息
*    @\param        url        发送url路径
*    @\param        urllen     发送url路径长度
*    @\param        mesg       发送消息
*    @\param        mesglen    发送消息长度
*    @\return    0 失败      非0为消息帧ID
*   @\relation  iv_send_srv_resp_cb 为消息结果回调函数
*/
uint32_t iv_send_service_msg( void *url, uint32_t urllen,void *mesg, uint32_t mesglen);

#pragma pack () /* 恢复字节对齐设定*/

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif//__IOT_VIDEO_LINK_INTERFACE_H_

