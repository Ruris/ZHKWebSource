//
//  DownloadService.m
//  Pods-ZHKWebSource_Example
//
//  Created by ZHK on 2020/8/28.
//  
//

#import "DownloadService.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import <GCDWebServer/GCDWebServerFileRequest.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerFileResponse.h>
#import <YYCategories/NSString+YYAdd.h>

NSString *const WebSourceOptionDownloadDirectoryPaths = @"Directories";

@interface DownloadService ()

@property (nonatomic, strong) GCDWebServer *server;

/// 配置信息
@property (nonatomic, copy) NSDictionary *options;

/// 文件列表信息
@property (nonatomic, copy) NSArray<DownloadFile *> *fileList;

/// 文件 map 映射表
@property (nonatomic, copy) NSDictionary<NSString *, DownloadFile *> *fileDic;

/// 文件列表 JSON 数据
@property (nonatomic, strong) NSData *fileListJSONData;

@end

@implementation DownloadService

+ (instancetype)registWithServer:(GCDWebServer *)server options:(NSDictionary *)options {
    DownloadService *service = [[DownloadService alloc] init];
    service.server = server;
    service.options = options;
    [service registServices];
    [service loadFilesInofs];
    return service;
}

- (void)registServices {
    __weak typeof(self) ws = self;
    
    [_server addHandlerForMethod:@"GET" path:@"/filelist" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        NSData *data = ws.fileListJSONData ?: [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"data: %@  %@", data, ws.fileListJSONData);
        completionBlock([GCDWebServerDataResponse responseWithData:data contentType:@"application/json"]);
    }];
    
    
    [_server addHandlerForMethod:@"GET" pathRegex:@"/download/[0-9a-zA-Z]+" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        /// 获取文件名
        NSString *token = [[request.URL.lastPathComponent componentsSeparatedByString:@"/"] lastObject];
        NSString *filePath = ws.fileDic[token].filePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            completionBlock([GCDWebServerFileResponse responseWithFile:filePath]);
        } else {
            completionBlock([GCDWebServerFileResponse responseWithStatusCode:404]);
        }
    }];
    
}

/// 加载本地文件信息
- (void)loadFilesInofs {
    NSArray<NSString *> *paths = _options[WebSourceOptionDownloadDirectoryPaths];
    if ([paths isKindOfClass:[NSArray class]] == NO) {
        return;
    }
    
    NSMutableArray<DownloadFile *> *fileList = [NSMutableArray new];
    for (NSString *path in paths) {
        if ([path isKindOfClass:[NSString class]] == NO) {
            continue;
        }
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] == NO || isDirectory == NO) {
            return;
        }
        NSArray<NSString *> *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        [fileList addObjectsFromArray:[DownloadFile filesWithDirectory:path names:fileNames]];
    }
    
    NSMutableArray *jsonObject = [NSMutableArray new];
    NSMutableDictionary<NSString *, DownloadFile *> *fileDic = [NSMutableDictionary new];
    for (DownloadFile *file in fileList) {
        fileDic[file.token] = file;
        [jsonObject addObject:@{
            @"name" : file.fileName,
            @"token": file.token
        }];
    }
    
    self.fileList = fileList;
    self.fileDic = fileDic;
    
    self.fileListJSONData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
}

@end




@implementation DownloadFile

#pragma mark - Init

+ (instancetype)fileWithDirectory:(NSString *)directory name:(NSString *)name {
    DownloadFile *file = [[DownloadFile alloc] init];
    file.fileName = name;
    file.filePath = [directory stringByAppendingPathComponent:name];
    return file;
}

+ (NSArray<DownloadFile *> *)filesWithDirectory:(NSString *)directory names:(NSArray<NSString *> *)names {
    NSMutableArray<DownloadFile *> *files = [NSMutableArray new];
    for (NSString *name in names) {
        [files addObject:[DownloadFile fileWithDirectory:directory name:name]];
    }
    return files;
}

#pragma mark - Getter

- (NSString *)token {
    if (_token == nil) {
        self.token = [_filePath md5String];
    }
    return _token;
}

@end
