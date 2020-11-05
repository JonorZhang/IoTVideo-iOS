//
//  IVMacros.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/11/2.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#ifndef IVMacros_h
#define IVMacros_h

#import <Foundation/Foundation.h>

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif


#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


#define dispatch_main_async_safe(block, ...)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block(__VA_ARGS__);\
    } else {\
        dispatch_async(dispatch_get_main_queue(), ^{\
            block(__VA_ARGS__);\
        });\
    }


#define dispatch_main_async_safe_weakSelf(block, ...)\
    @weakify(self)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        @strongify(self)\
        block(__VA_ARGS__);\
    } else {\
        dispatch_async(dispatch_get_main_queue(), ^{\
            @strongify(self)\
            block(__VA_ARGS__);\
        });\
    }


#define dispatch_main_sync_safe(block, ...)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block(__VA_ARGS__);\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), ^{\
            block(__VA_ARGS__);\
        });\
    }

#define block_exec_safe(block, ...) if (block) { block(__VA_ARGS__); };

#define block_exec_safe_main(block, ...) if (block) { dispatch_main_async_safe(block, __VA_ARGS__); };

#define block_exec_safe_main_weakSelf(block, ...) if (block) { dispatch_main_async_safe_weakSelf(block, __VA_ARGS__); };

#endif /* IVMacros_h */
