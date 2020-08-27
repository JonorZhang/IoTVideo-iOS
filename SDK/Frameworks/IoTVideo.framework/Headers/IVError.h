//
//  IVError.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/3/30.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IVError_h
#define IVError_h

// 公共错误码
typedef NS_ENUM(NSUInteger, IVError) {
    IVError_error_none = 0, //!< 成功

    //!< 接入服务器返回的错误码
    IVError_ASrv_dst_offline = 8000,                   //!< 目标离线
    IVError_ASrv_dst_notfound_asrv = 8001,           //!< 没有找到目标所在的接入服务器
    IVError_ASrv_dst_notexsit = 8002,                 //!< 目标不存在
    IVError_ASrv_dst_error_relation = 8003,           //!< 非法关系链
    IVError_ASrv_data_chkfrm_fail = 8004,          //!< 校验帧失败
    IVError_ASrv_data_loadjson_fail = 8005,           //!< 终端上传的json,加载到物模型失败
    IVError_ASrv_data_modifytick_fail = 8006,        //!< 终端上传的json,修改物模型相关的时间戳失败
    IVError_ASrv_tocsrv_timeout = 8007,      //!< 接入服务器与中心服务器通信超时
    IVError_ASrv_url_parse_fail = 8008,      //!< url地址解析失败
    IVError_ASrv_csrv_reply_err = 8009,            //!<  中心服务器响应错误的数据
    IVError_ASrv_forward_toASrv_timeout = 8010,       //!< 接入服务器转发消息到其他接入服务器超时
    IVError_ASrv_forward_toASrv_fail = 8011,           //!< 接入服务器转发消息到其他接入服务器失败
    IVError_ASrv_forward_toTerm_timeout = 8012,       //!< 接入服务器转发消息到设备超时
    IVError_ASrv_forward_toTerm_fail = 8013,           //!< 接入服务器转发消息到设备失败
    IVError_ASrv_handle_fail = 8014,                   //!< 接入服务器处理收到的数据帧失败
    IVError_ASrv_dstid_parse_faild = 8015,             //!< 接入服务器没有从数据帧中解析出目标ID
    IVError_ASrv_dstid_isuser = 8016,                //!< 接入服务器发现目标ID是个用户
    IVError_ASrv_calc_leaf_fail = 8017,              //!< 接入服务器计算leaf失败
    IVError_ASrv_set_timeval_leafval_fail = 8018,             //!< 接入服务器设置物模型的timeval值失败
    IVError_ASrv_calc_forward_json_fail = 8019,       //!< 接入服务器计算转发json失败
    IVError_ASrv_tmpsubs_parse_fail = 8020,          //!< 临时订阅帧没有解析出设备ID
    IVError_ASrv_csrvctrl_trgtype_error = 8021,      //!< 中心服务器发来的ctl帧，trgtype不对
    IVError_ASrv_binderror_dev_usr_has_bind = 8022,            //!< 这对设备和用户已经绑定
    IVError_ASrv_binderror_dev_has_bind_other = 8023,         //!< 设备已经绑定其他用户
    IVError_ASrv_binderror_customer_diffrent = 8024,          //!< 配网失败,设备的客户ID与用户的客户ID不一致
    IVError_ASrv_unformat_jsstr_fail = 8025,                  //!< json字符串处理失败
    IVError_ASrv_netcfg_maketoken_fail = 8026,       //!< 配网时生成token失败
    IVError_ASrv_netcfg_verifytoken_fail = 8027,         //!< 配网时校验token失败
    IVError_ASrv_parse_json_fail = 8028,
    IVError_ASrv_read_gdm_fail = 8029,              //!< 接入服务器没有读取到物模型信息
    IVError_ASrv_gdm_ctrl_forbidden = 8030,               //!< 禁止APP设置
    IVError_ASrv_generate_tx_sign_fail = 8031,       //!< 生成腾讯签名失败
    IVError_ASrv_src_term_disable = 8032,           //!< 消息SRC终端被禁用(RDB标识禁用)
    IVError_ASrv_dst_term_disable = 8033,           //!< 消息DST终端被禁用(RDB标识禁用)
    IVError_ASrv_set_origin_leafval_fail = 8034,       //!< 接入服务器设置物模型的origin值失败
    IVError_ASrv_termtype_error = 8035,      //!< 终端类型信息校验失败
    IVError_ASrv_gdm_match_fail = 8036,      //!< 数据与物模型匹配失败
    IVError_ASrv_gdmpath_error = 8037,      //!< 上传的leaf_path路径无效
    IVError_ASrv_rebuild_actioncmd_fail = 8038,      //!< 重组action消息失败
    

    //!< 中心服务器返回的错误码
    IVError_AC_frm_type_err                       = 8501, //!< 帧类型错误
    IVError_AC_frm_len_err                        = 8502, //!< 帧长度错误
    IVError_AC_frm_bson_hashval_err               = 8503, //!< bson数据与bson哈希值不匹配
    IVError_AC_GdmType_err                        = 8504, //!< 无效的GdmType
    IVError_AC_UploadReq_termid_is_not_dev_err    = 8505, //!< GACFRM_Bson_UploadReq帧上传的不是一个设备id
    IVError_AC_MsgBody_GdmBsonDat_Leaf_length_err = 8506, //!< MsgBody_GdmBsonDat结构体中leaf字符串的结束符错误
    IVError_AC_MsgBody_GdmJsonDat_Leaf_length_err = 8507, //!< MsgBody_GdmJsonDat结构体中leaf字符串的结束符错误
    IVError_AC_MsgBody_GetGdmDefBson_err          = 8508, //!< 获取GdmDefBson错误
    IVError_AC_MsgBody_GdmJsonDat_length_err      = 8509, //!< MsgBody_GdmJsonDat结构体中json字符串的结束符错误
    IVError_AC_MsgBody_GdmDat_Leaf_path_err       = 8510, //!< MsgBody_GdmDat结构体中leaf_path无效
    IVError_AC_MsgBody_GdmDat_content_err         = 8511, //!< MsgBody_GdmDat结构体中数据无效
    IVError_AC_csrv_no_term_GdmDat_err            = 8512, //!< 中心服务器中不存在该终端的物模型
    IVError_AC_csrv_no_term_err                   = 8513, //!< 中心服务器中找不到该终端
    IVError_AC_csrv_no_term_productID_err         = 8514, //!< 中心服务器中没有与该终端对应的productID
    IVError_AC_MsgBody_GetGdmDefJson_err          = 8515, //!< 中心服务器获取json格式物模型错误

    IVError_AC_TermOnlineReq_olinf_parm_err       = 8520,//!< 初始化请求帧，olinf 参数不正确
    IVError_AC_TermOnlineReq_opt_with_fp_but_no_with_termid = 8521, //!< 初始化请求帧,置上了opt_with_data_fp，但是没有置上opt_with_termid

    IVError_AC_Dat_UploadReq_dat_type_json_but_no_opt_with_termid_err = 8531,//!< GACFRM_Dat_UploadReq reqfrm->dat_type是0，但是没有置上opt_with_termid
    IVError_AC_Dat_UploadReq_dat_type_err = 8532,//!< GACFRM_Dat_UploadReq reqfrm->dat_type是0，但是没有置上opt_with_termid

    IVError_AC_other_err = 8600,                     //!< 其它类型错误
                                                                        
    IVError_AC_centerInner_load_bson_err    = 8601, //!< 中心服务器load_bson失败
    IVError_AC_centerInner_load_json_err    = 8602, //!< 中心服务器load_json失败
    IVError_AC_centerInner_get_bson_raw_err = 8603, //!< 中心服务器get_bson_raw失败

    IVError_AC_centerInner_insert_user_fail                 = 8610, //!< 中心服务器user哈希表插入失败
    IVError_AC_centerInner_insert_dev_fail                  = 8611, //!< 中心服务器dev哈希表插入失败
    IVError_AC_centerInner_find_login_user_err              = 8612,
    IVError_AC_centerInner_login_user_utcinitchgd_lower_err = 8613,
    IVError_AC_centerInner_login_dev_utcinitchgd_lower_err  = 8614,

    IVError_AC_centerInner_processDevLastWord_err           = 8620,
    IVError_AC_MsgBody_LastWords_topic_is_not_valide_err    = 8621,
    IVError_AC_MsgBody_LastWords_json_is_not_valide_err     = 8622,
    IVError_AC_MsgBody_LastWords_not_with_livetime_err      = 8623,
    IVError_AC_MsgBody_LastWords_not_with_topic_err         = 8624,
    IVError_AC_MsgBody_LastWords_not_with_json_err          = 8625,
    IVError_AC_MsgBody_LastWords_action_is_err              = 8626,
    IVError_AC_MsgBody_LastWords_query_is_none              = 8627, //!< 中心服务器未查到遗言
    
    IVError_ASrv_centerInner_other_err                      = 8700,
    IVError_ASrv_TempSubscription_termid_is_not_usr_err     = 8800, //!< GACFRM_TempSubscription帧上传的不是一个用户id
    IVError_ASrv_RdbTermListReq_neither_get_online_nor_get_offline_err = 8900, //!< GACFRM_RdbTermListReq帧既不获取在线信息也不获取离线信息，从业务上来说这是无意义的
    IVError_ASrv_AllTermInitReq_other_err = 9000,
    
    
    //!< 终端使用
    IVError_Term_msg_send_peer_timeout = 20001,            //!< 消息发送给对方超时
    //calling相关
    IVError_Term_msg_calling_hangup = 20002,            //!< 普通挂断消息
    IVError_Term_msg_calling_send_timeout = 20003,        //!< calling消息发送超时
    IVError_Term_msg_calling_no_srv_addr = 20004,        //!< 服务器未分配转发地址
    IVError_Term_msg_calling_handshake_timeout = 20005,//!< 握手超时
    IVError_Term_msg_calling_token_error = 20006,        //!< 设备端token校验失败
    IVError_Term_msg_calling_all_chn_busy = 20007,        //!< 监控通道数满
    IVError_Term_msg_calling_timeout_disconnect = 20008,//!< 超时断开
    IVError_Term_msg_calling_no_find_dst_id = 20009,    //!< 未找到目的id
    IVError_Term_msg_calling_check_token_error = 20010, //!< token校验出错
    IVError_Term_msg_calling_dev_is_disable       = 20011, //!< 设备已经禁用

    //物模型
    IVError_Term_msg_gdm_handle_processing = 20100,        //!< 设备正在处理中
    IVError_Term_msg_gdm_handle_leaf_path_error = 20101,//!< 设备端校验叶子路径非法
    IVError_Term_msg_gdm_handle_parse_json_fail = 20102, //!< 设备端解析JSON出错
    IVError_Term_msg_gdm_handle_fail = 20103,            //!< 设备处理ACtion失败
    IVError_Term_msg_gdm_handle_no_cb_registered = 20104,//!< 设备未注册相应的ACtion回调函数
    IVError_Term_msg_gdm_handle_buildin_prowritable_error = 20105,//!< 设备不允许通过局域网修改内置可写对象

    //
    IVError_Term_alloc_fail = 20200,
    IVError_Term_param_invalid = 20201,
    IVError_Term_term_unit_no_init = 20202,

    IVError_Term_msg_onlinemsg_handle_invalid= 20213, //!< 在线消息handle错误，有可能是过期丢弃了
    IVError_Term_msg_onlinemsg_handle_repeat = 20214, //!< 已回应handle值，不需重复发送
};

/// 错误描述字典
extern NSDictionary *IVErrorDescribeDictionary(void);

/// 根据`错误码`返回`错误描述`
/// @param errorCode 错误码
extern NSString *IVErrorDescribe(NSUInteger errorCode);

extern NSString *IVErrorDescribe2(NSUInteger errorCode, const char *fmt, ...);
extern NSError  *IVErrorMake(id target, NSUInteger errorCode, const char *fmt, ...);
extern NSError  *IVErrorMake2(id target, NSUInteger errorCode, NSUInteger reasonCode, NSString *reasonDesc, const char *fmt, ...);

#endif /* IVError_h */
