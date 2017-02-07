//
//  AppDelegate.m
//  CrashDemo
//
//  Created by Lix on 17/2/7.
//  Copyright © 2017年 Lix. All rights reserved.
//

#import "AppDelegate.h"
#import "CatchCrash.h"
#import "CocoaLumberjack.h"
#import <Bugly/Bugly.h>

@interface AppDelegate () <BuglyDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerDebugLog];
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.debugMode = YES;
    config.unexpectedTerminatingDetectionEnable = YES;
    config.blockMonitorEnable = YES;
    config.viewControllerTrackingEnable = YES;
    config.reportLogLevel = BuglyLogLevelVerbose;
    config.consolelogEnable = YES;
    config.delegate = self;
    [Bugly startWithAppId:@"7903903560" config:config];

    return YES;
}

#pragma mark - Bugly代理 - 捕获异常,回调(@return 返回需上报记录，随 异常上报一起上报)
- (NSString *)attachmentForException:(NSException *)exception {
#ifdef DEBUG // 调试
    return [NSString stringWithFormat:@"我是携带信息:%@",[self redirectNSLogToDocumentFolder]];
#endif
    return nil;
}

#pragma mark - 保存日志文件
- (NSString *)redirectNSLogToDocumentFolder {
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return nil;
    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){
        //在模拟器不保存到文件中
        return nil;
    }
    //获取Document目录下的Log文件夹，若没有则新建
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.txt",dateStr];
    // freopen 重定向输出输出流，将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    return [[NSString alloc] initWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)registerDebugLog {
    //注册CocoaLumberjack日志框架
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    //注册消息处理函数的处理方法
    //如此一来，程序崩溃时会自动进入CatchCrash.m的uncaughtExceptionHandler()方法
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    //检测是否有Crash文件，则写入log并上传，然后删掉crash文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
    NSLog(@"path = %@", errorLogPath);
    if ([fileManager fileExistsAtPath:errorLogPath]) {
        [fileLogger.logFileManager createNewLogFile];
        NSString *newLogFilePath = [fileLogger.logFileManager sortedLogFilePaths].firstObject;
        NSError *error = nil;
        NSString *errorLogContent = [NSString stringWithContentsOfFile:errorLogPath encoding:NSUTF8StringEncoding error:nil];
        BOOL isSuccess = [errorLogContent writeToFile:newLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!isSuccess) {
            NSLog(@"crash文件写入log失败: %@", error.userInfo);
        } else {
            NSLog(@"crash文件写入log成功");
            NSError *error = nil;
            BOOL isSuccess = [fileManager removeItemAtPath:errorLogPath error:&error];
            if (!isSuccess) {
                NSLog(@"删除本地的crash文件失败: %@", error.userInfo);
            }
        }
        NSArray *logFilePaths = [fileLogger.logFileManager sortedLogFilePaths];
        NSUInteger logCounts = logFilePaths.count;
        if (logCounts >= 3) {
            for (NSUInteger i = 0; i < 3; i++) {
                NSString *logFilePath = logFilePaths[i];
                //上传服务器
                //                ...
            }
        } else {
            for (NSUInteger i = 0; i < logCounts; i++) {
                NSString *logFilePath = logFilePaths[i];
                //上传服务器
                //                ...
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
