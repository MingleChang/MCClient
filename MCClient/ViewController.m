//
//  ViewController.m
//  MCClient
//
//  Created by 常峻玮 on 16/11/30.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "ViewController.h"
#import "MCClient.h"
@interface ViewController ()<MCClientDelegate>
@property(nonatomic,strong)MCClient *client;

- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.client = [[MCClient alloc] init];
//    [self.client mc_connect:@"www.baidu.com" port:80];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonClick:(UIButton *)sender {
    self.client = [[MCClient alloc] init];
    self.client.delegate = self;
    [self.client mc_connect:@"www.baidu.com" port:80];
}

#pragma mark - MCClient Delegate
- (void)mc_clientConnectSuccess:(MCClient *)client {
    
    NSString *lString= @"GET / HTTP/1.1\r\n";
    lString = [lString stringByAppendingString:@"Host: www.baidu.com\r\n"];
    lString = [lString stringByAppendingString:@"Content-Type: text/html\r\n"];
    lString = [lString stringByAppendingString:@"\r\n"];
    [self.client mc_sendData:[lString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)mc_clientConnectFailed:(MCClient *)client {
    
}

- (void)mc_client:(MCClient *)client receiveData:(NSData *)data {
//    "HTTP 1.1没有C-L"的意思是"HTTP1.1标准已经废除了C-L这个field"还是"如果是HTTP1.1, 如果没有C-L, 应当要有T-E"? 也就是接收response是这样的流程对不对:
//    
//    先把header直到\r\n\r\n整个地收下来;
//    如果Connection: Keep-Alive:
//    
//    if T-E: chunked, 就读, 直到流里有\r\n0\r\n\r\n
//        else if Content-Length存在, 就从头的末尾开始计算C-L个字节.
//            else 就这么一直读等服务器断开连接就好.
    NSData *lData = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSRange lRange = [data rangeOfData:lData options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
    NSString *lString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lString);
}

@end
