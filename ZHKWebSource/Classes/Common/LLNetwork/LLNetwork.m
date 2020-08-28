//
//  LLNetwork.m
//  GCDWebServer
//
//  Created by ZHK on 2020/8/28.
//  
//

#import "LLNetwork.h"
#import <Network/Network.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ctype.h>

@implementation LLNetwork

+ (BOOL)isPortCanUse:(int)port {
    
    int skt = socket(AF_INET, SOCK_STREAM, 0);
    if (skt == -1) {
        return NO;
    }
    struct sockaddr_in addr;
    socklen_t len = sizeof(addr);
    
    memset(&addr, 0, len);
    
    addr.sin_len = len;
    addr.sin_family = AF_INET;  // 地址族
    addr.sin_addr.s_addr = htonl(INADDR_ANY);   // 监听本机所有 ip
    addr.sin_port = htons(port);    // 端口
    
    if (bind(skt, (struct sockaddr *)&addr, len) == -1) {
        return NO;
    }
    if (listen(skt, SOMAXCONN) == -1) {
        return NO;
    }
    shutdown(skt, SHUT_RDWR);
    close(skt);
    return YES;
}

@end
