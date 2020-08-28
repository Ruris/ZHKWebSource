//
//  LLNetwork.h
//  GCDWebServer
//
//  Created by ZHK on 2020/8/28.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLNetwork : NSObject

+ (BOOL)isPortCanUse:(int)port;

@end

NS_ASSUME_NONNULL_END
