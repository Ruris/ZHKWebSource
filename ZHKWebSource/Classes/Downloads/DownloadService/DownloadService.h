//
//  DownloadService.h
//  Pods-ZHKWebSource_Example
//
//  Created by ZHK on 2020/8/28.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WebSourceOptionDownloadDirectoryPaths;

@class GCDWebServer;
@interface DownloadService : NSObject

+ (instancetype)registWithServer:(GCDWebServer *)server options:(NSDictionary *)options;

@end


@interface DownloadFile : NSObject

/// 文件名称
@property (nonatomic, copy) NSString *fileName;
/// 文件路径
@property (nonatomic, copy) NSString *filePath;
/// 文件标识
@property (nonatomic, copy) NSString *token;

+ (NSArray<DownloadFile *> *)filesWithDirectory:(NSString *)directory names:(NSArray<NSString *> *)names;

@end

NS_ASSUME_NONNULL_END
