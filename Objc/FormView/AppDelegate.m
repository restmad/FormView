//
//  AppDelegate.m
//  FormView
//
//  Created by 黄伯驹 on 2017/12/4.
//  Copyright © 2017年 黄伯驹. All rights reserved.
//

#import "AppDelegate.h"

#import <CommonCrypto/CommonDigest.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    NSMutableArray *results1 = [NSMutableArray array];
//    NSMutableArray *results2 = [NSMutableArray array];
//    NSMutableArray *results3 = [NSMutableArray array];
//    NSMutableArray *results4 = [NSMutableArray array];
//
//    NSRange range1 = NSMakeRange(1, 10);
//    NSRange range2 = NSMakeRange(21, 10);
//    NSRange range3 = NSMakeRange(41, 10);
//    NSRange range4 = NSMakeRange(61, 10);
//
//    for (int i = 0; i < 100000; i++) {
//        NSString *md5Str = [self strToMD5WithStr:[NSString stringWithFormat:@"%d", i]];
//        int result = [self calculateHexMod:md5Str] + 1;
//        if (NSLocationInRange(result, range1)) {
//            [results1 addObject:[NSNumber numberWithInt:result]];
//        } else if (NSLocationInRange(result, range2)) {
//            [results2 addObject:[NSNumber numberWithInt:result]];
//        } else if (NSLocationInRange(result, range3)) {
//            [results3 addObject:[NSNumber numberWithInt:result]];
//        } else if (NSLocationInRange(result, range4)) {
//            [results4 addObject:[NSNumber numberWithInt:result]];
//        }
//    }
//    NSLog(@"%zd", results1.count);
//    NSLog(@"%zd", results2.count);
//    NSLog(@"%zd", results3.count);
//    NSLog(@"%zd", results4.count);
    return YES;
}

- (NSString *)strToMD5WithStr:(NSString *)str {
    //转化为UTF8格式字符串
    const char *ptr = [str UTF8String];
    
    //开辟一个16字节数组
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    //调用官方封装的加密方法, 将ptr开始的字符串存储到md5Buffer[]中
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    //转换位NSString并返回
    NSMutableString *output = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [output appendFormat: @"%02x", md5Buffer[i]];
    }
    return output;
}

- (int)calculateHexMod:(NSString *)hexString {
    static NSArray <NSNumber *>*targets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        targets = @[
                    @76,
                    @16,
                    @56,
                    @96,
                    @36
                    ];
    });
    
    int result = 0;
    NSInteger strLength = hexString.length;
    for (int i = 0; i < strLength; i++) {
        NSString *subStr = [hexString substringWithRange:NSMakeRange(strLength - 1 - i, 1)];
        int number = (int)strtoull([subStr UTF8String], NULL, 16);
        if (i == 0) {
            result = number;
            continue;
        }
        int idx = i % 5;
        int n = targets[idx].intValue;
        result += (number * n);
    }

    result %= 100;

    return result;
}

- (void)loadAttachmentForUrlString:(NSString *)urlStr
                          withType:(NSString *)type {

    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        NSLog(@"%@", error.localizedDescription);
                    } else {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                        [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
                        NSError *attachmentError = nil;

                        if (attachmentError) {
                            NSLog(@"%@", attachmentError.localizedDescription);
                        }
                    }
                }] resume];
    
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
