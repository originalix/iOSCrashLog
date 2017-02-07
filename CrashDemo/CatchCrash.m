//
//  CatchCrash.m
//  CrashDemo
//
//  Created by Lix on 17/2/7.
//  Copyright © 2017年 Lix. All rights reserved.
//

#import "CatchCrash.h"
#import "CocoaLumberjack.h"

@implementation CatchCrash

//在AppDelegate中注册后，程序崩溃时会执行的方法
void uncaughtExceptionHandler(NSException *exception) {
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    NSArray *stackArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"crashTime: %@ Exception reason: %@\nException name: %@\nException stack:%@", crashTime, name, reason, stackArray];

    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
    NSError *error = nil;
    BOOL isSuccess = [exceptionInfo writeToFile:errorLogPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isSuccess) {
        NSLog(@"将crash信息保存到本地失败: %@", error.userInfo);
    }
}

+ (void)registerDebugLog {
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

@end
