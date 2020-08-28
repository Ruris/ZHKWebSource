//
//  ZHKViewController.m
//  ZHKWebSource
//
//  Created by Ruris on 08/28/2020.
//  Copyright (c) 2020 Ruris. All rights reserved.
//

#import "ZHKViewController.h"
#import <GCDWebServer/GCDWebServer.h>
#import <DownloadService.h>
#import <LLNetwork.h>

@interface ZHKViewController ()

@property (nonatomic, strong) GCDWebServer *server;
@property (nonatomic, strong) DownloadService *downloadService;

@end

@implementation ZHKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%d", [LLNetwork isPortCanUse:8080]);
    self.server = [[GCDWebServer alloc] init];
    
    self.downloadService = [DownloadService registWithServer:_server options:@{
        WebSourceOptionDownloadDirectoryPaths : @[
                NSTemporaryDirectory()
        ]
    }];
    
    
    int port = 8081;
    while ([LLNetwork isPortCanUse:port] == NO) {
        port++;
    }
    
    [_server startWithPort:port bonjourName:nil];
    NSLog(@"%@", NSTemporaryDirectory());
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
