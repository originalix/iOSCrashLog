//
//  CatchCrash.h
//  CrashDemo
//
//  Created by Lix on 17/2/7.
//  Copyright © 2017年 Lix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatchCrash : NSObject

void uncaughtExceptionHandler(NSException *exception);

+ (void)registerDebugLog;

@end
