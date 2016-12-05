//
//  MCClient.h
//  MCClient
//
//  Created by 常峻玮 on 16/11/30.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCClient;

typedef NS_ENUM(NSUInteger,MCClientConnectState){
    MCClientConnectStateDisconnect,
    MCClientConnectStateConnecting,
    MCClientConnectStateConnected,
};

@protocol MCClientDelegate <NSObject>

- (void)mc_clientConnectSuccess:(MCClient *)client;
- (void)mc_clientConnectFailed:(MCClient *)client;
- (void)mc_client:(MCClient *)client receiveData:(NSData *)data;

@end

@interface MCClient : NSObject

@property(nonatomic, strong, readonly)NSInputStream *inputStream;
@property(nonatomic, strong, readonly)NSOutputStream *outputStream;

@property(nonatomic, assign, readonly)MCClientConnectState state;

@property(nonatomic, assign)id<MCClientDelegate> delegate;

-(void)mc_connect:(NSString *)host port:(NSInteger)port;
-(void)mc_disconnect;
-(void)mc_sendData:(NSData *)data;
-(void)mc_sendBytes:(const uint8_t *)buffer maxLength:(NSUInteger)len;
@end
