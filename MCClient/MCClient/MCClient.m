//
//  MCClient.m
//  MCClient
//
//  Created by 常峻玮 on 16/11/30.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "MCClient.h"

#define MC_CLIENT_BUFFER_SIZE 4096

@interface MCClient ()<NSStreamDelegate>

@property(nonatomic, strong, readwrite)NSInputStream *inputStream;
@property(nonatomic, strong, readwrite)NSOutputStream *outputStream;

@property(nonatomic, assign, readwrite)MCClientConnectState state;

@end

@implementation MCClient
-(void)mc_connect:(NSString *)host port:(NSInteger)port{
    if (self.state!=MCClientConnectStateDisconnect) {
        [self mc_disconnect];
    }
    
    self.state=MCClientConnectStateConnecting;
    
    NSInputStream  *tempInput  = nil;
    NSOutputStream *tempOutput = nil;
    
    [NSStream getStreamsToHostWithName:host port:port inputStream:&tempInput outputStream:&tempOutput];
    self.inputStream  = tempInput;
    self.outputStream = tempOutput;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}
-(void)mc_disconnect {
    if (self.state == MCClientConnectStateDisconnect) {
        return;
    }
    
    self.state = MCClientConnectStateDisconnect;
    if (self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream=nil;
    }
    if (self.outputStream) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.outputStream=nil;
        
    }
}
-(void)mc_sendData:(NSData *)data {
    [self.outputStream write:[data bytes] maxLength:[data length]];
}
#pragma mark - Private
-(void)mc_handleStreamEventOpenCompleted:(NSStream *)stream{//连接成功
//    if (stream == self.outputStream) {
//        self.state = MCClientConnectStateConnected;
//        if ([self.delegate respondsToSelector:@selector(mc_clientConnectSuccess:)]) {
//            [self.delegate mc_clientConnectSuccess:self];
//        }
//    }
}
-(void)mc_handleStreamEventHasBytesAvailable:(NSStream *)stream{//接收数据
    NSInputStream *lInputStream = (NSInputStream *)stream;
    NSMutableData *lData = [NSMutableData data];
    NSInteger length = 0;
    do {
        uint8_t buffer[MC_CLIENT_BUFFER_SIZE];
        length = [lInputStream read:buffer maxLength:MC_CLIENT_BUFFER_SIZE];
        [lData appendBytes:buffer length:length];
    } while (length >= MC_CLIENT_BUFFER_SIZE);
    
    if ([self.delegate respondsToSelector:@selector(mc_client:receiveData:)]) {
        [self.delegate mc_client:self receiveData:[lData copy]];
    }
}
-(void)mc_handleStreamEventHasSpaceAvailable:(NSStream *)stream{//发送数据
//    NSOutputStream *lOutputStream = (NSOutputStream *)stream;
    if (self.state == MCClientConnectStateConnected) {
        return;
    }
    self.state = MCClientConnectStateConnected;
    if ([self.delegate respondsToSelector:@selector(mc_clientConnectSuccess:)]) {
        [self.delegate mc_clientConnectSuccess:self];
    }
}
-(void)mc_handleStreamEventErrorOccurred:(NSStream *)stream{//错误
    if (self.state == MCClientConnectStateDisconnect) {
        return;
    }
    [self mc_disconnect];
    if ([self.delegate respondsToSelector:@selector(mc_clientConnectFailed:)]) {
        [self.delegate mc_clientConnectFailed:self];
    }
}
-(void)mc_handleStreamEventEndEncountered:(NSStream *)stream{//inputStream接收到的末尾
    if (self.state == MCClientConnectStateDisconnect) {
        return;
    }
    [self mc_disconnect];
    if ([self.delegate respondsToSelector:@selector(mc_clientConnectFailed:)]) {
        [self.delegate mc_clientConnectFailed:self];
    }
}
#pragma mark - NSStream Delegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            [self mc_handleStreamEventOpenCompleted:aStream];
            break;
        case NSStreamEventHasBytesAvailable:
            [self mc_handleStreamEventHasBytesAvailable:aStream];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self mc_handleStreamEventHasSpaceAvailable:aStream];
            break;
        case NSStreamEventErrorOccurred:
            [self mc_handleStreamEventErrorOccurred:aStream];
            break;
        case NSStreamEventEndEncountered:
            [self mc_handleStreamEventEndEncountered:aStream];
            break;
        default:
            break;
    }
    NSLog(@"%@\n%lu",aStream,(unsigned long)eventCode);
}
@end
