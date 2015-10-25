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


    + (void)customizeLogger
    {
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setLogFormatter:[[TMTLogFormatter alloc] initExtended:NO]];
        [[DDASLLogger sharedInstance] setLogFormatter:[[TMTLogFormatter alloc] initExtended:YES]];
        //[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithCalibratedRed:0.30f green:0.75f blue:0.34f alpha:1.00f] backgroundColor:Nil forFlag:LOG_FLAG_INFO];
        [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithCalibratedRed:0.31f green:0.51f blue:0.53f alpha:1.00f] backgroundColor:nil forFlag:DDLogFlagDebug];
        [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor colorWithCalibratedRed:0.05 green:0.4 blue:0.73 alpha:1] backgroundColor:nil forFlag:DDLogFlagVerbose];
    }

@end
