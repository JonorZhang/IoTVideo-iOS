#ifndef IOT_VIDEO_LINK_COMMON_H_
#define IOT_VIDEO_LINK_COMMON_H_

#include "iot_video_link_def.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
/*!
    \brief    换为32进制字符串为64位整数
*/
bool  iv_fromstr_32digit(uint64_t* pval, const char* psrc, int len );


/*!
    \brief    64位整数转换为32进制字符串
*/
int  iv_tostr_32digit(uint64_t _val, char* pdst);


/*!
    \brief BASE64 接口
*/
int iv_base64_encode(const char* _in, int inlen, char * out, int maxlen);
int iv_base64_decode(const char* _in, int inlen, char * out, int maxlen);



#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif
