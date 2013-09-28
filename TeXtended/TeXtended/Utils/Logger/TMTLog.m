//
//  TMTLog.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "TMTLogFormatter.h"
@implementation TMTLog

+ (void)customizeLogger {
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setLogFormatter:[TMTLogFormatter new]];
    [[DDASLLogger sharedInstance] setLogFormatter:[TMTLogFormatter new]];
    [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithCalibratedRed:0.00f green:0.52f blue:0.00f alpha:1.00f] backgroundColor:Nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithCalibratedRed:0.31f green:0.51f blue:0.53f alpha:1.00f] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
}

@end
