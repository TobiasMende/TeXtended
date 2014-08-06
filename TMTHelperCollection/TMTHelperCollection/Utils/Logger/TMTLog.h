//
//  TMTLog.h
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"


#pragma mark - Cocoa Lumberjack Redefinitions

// First undefine the default stuff we don't want to use.

#undef LOG_FLAG_ERROR
#undef LOG_FLAG_WARN
#undef LOG_FLAG_INFO
#undef LOG_FLAG_DEBUG
#undef LOG_FLAG_VERBOSE

#undef LOG_LEVEL_ERROR
#undef LOG_LEVEL_WARN
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_DEBUG
#undef LOG_LEVEL_VERBOSE

#undef LOG_ERROR
#undef LOG_WARN
#undef LOG_INFO
#undef LOG_DEBUG
#undef LOG_VERBOSE

#undef DDLogError
#undef DDLogWarn
#undef DDLogInfo
#undef DDLogDebug
#undef DDLogVerbose

#undef DDLogCError
#undef DDLogCWarn
#undef DDLogCInfo
#undef DDLogCDebug
#undef DDLogCVerbose

// Now define everything how we want it

#define LOG_FLAG_FATAL   (1 << 0)  // 0...0000001 - 1
#define LOG_FLAG_ERROR   (1 << 1)  // 0...0000010 - 2
#define LOG_FLAG_WARN    (1 << 2)  // 0...0000100 - 4
#define LOG_FLAG_NOTICE  (1 << 3)  // 0...0001000 - 8
#define LOG_FLAG_INFO    (1 << 4)  // 0...0010000 - 16
#define LOG_FLAG_DEBUG   (1 << 5)  // 0...0100000 - 32
#define LOG_FLAG_TRACE   (1 << 6)  // 0...1000000 - 64

#define LOG_LEVEL_FATAL   (LOG_FLAG_FATAL)                     // 0...000001
#define LOG_LEVEL_ERROR   (LOG_FLAG_ERROR  | LOG_LEVEL_FATAL ) // 0...000011
#define LOG_LEVEL_WARN    (LOG_FLAG_WARN   | LOG_LEVEL_ERROR ) // 0...000111
#define LOG_LEVEL_NOTICE  (LOG_FLAG_NOTICE | LOG_LEVEL_WARN  ) // 0...001111
#define LOG_LEVEL_INFO    (LOG_FLAG_INFO   | LOG_LEVEL_NOTICE) // 0...011111
#define LOG_LEVEL_DEBUG   (LOG_FLAG_DEBUG  | LOG_LEVEL_INFO  ) // 0...111111
#define LOG_LEVEL_TRACE   (LOG_FLAG_TRACE  | LOG_LEVEL_DEBUG )

#define LOG_FATAL   (ddLogLevel & LOG_FLAG_FATAL )
#define LOG_ERROR   (ddLogLevel & LOG_FLAG_ERROR )
#define LOG_WARN    (ddLogLevel & LOG_FLAG_WARN  )
#define LOG_NOTICE  (ddLogLevel & LOG_FLAG_NOTICE)
#define LOG_INFO    (ddLogLevel & LOG_FLAG_INFO  )
#define LOG_DEBUG   (ddLogLevel & LOG_FLAG_DEBUG )
#define LOG_TRACE   (ddLogLevel & LOG_FLAG_TRACE )

#define DDLogFatal(frmt, ...)    SYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_FATAL,  0, frmt, ##__VA_ARGS__)
#define DDLogError(frmt, ...)    SYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_ERROR,  0, frmt, ##__VA_ARGS__)
#define DDLogWarn(frmt, ...)    ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_WARN,   0, frmt, ##__VA_ARGS__)
#define DDLogNotice(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_NOTICE, 0, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)    ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_INFO,   0, frmt, ##__VA_ARGS__)
#define DDLogDebug(frmt, ...)   ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_DEBUG,  0, frmt, ##__VA_ARGS__)
#define DDLogTrace(frmt, ...)   ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_TRACE,  0, frmt, ##__VA_ARGS__)

#define DDLogCFatal(frmt, ...)   SYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_FATAL,  0, frmt, ##__VA_ARGS__)
#define DDLogCError(frmt, ...)   SYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_ERROR,  0, frmt, ##__VA_ARGS__)
#define DDLogCWarn(frmt, ...)   ASYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_WARN,   0, frmt, ##__VA_ARGS__)
#define DDLogCNotice(frmt, ...) ASYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_NOTICE, 0, frmt, ##__VA_ARGS__)
#define DDLogCInfo(frmt, ...)   ASYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_INFO,   0, frmt, ##__VA_ARGS__)
#define DDLogCDebug(frmt, ...)  ASYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_DEBUG,  0, frmt, ##__VA_ARGS__)
#define DDLogCTrace(frmt, ...)  ASYNC_LOG_C_MAYBE(ddLogLevel, LOG_FLAG_TRACE,  0, frmt, ##__VA_ARGS__)


#pragma mark - TMTLog Statements

#define TMT_TRACE DDLogTrace(@"");
#define TMT_LOG_LEVEL_KEY @"TMT_LOG_LEVEL"

#define LOGGING(level) static const int ddLogLevel = level;

#define LOGGING_DYNAMIC(level) static int ddLogLevel = level;

#ifdef DEBUG
#define LOGGING_DEFAULT LOGGING(LOG_LEVEL_TRACE)
#define LOGGING_DEFAULT_DYNAMIC LOGGING_DYNAMIC(LOG_LEVEL_TRACE)
#else
#define LOGGING_DEFAULT LOGGING(LOG_LEVEL_NOTICE)
#define LOGGING_DEFAULT_DYNAMIC LOGGING_DYNAMIC(LOG_LEVEL_NOTICE)
#endif


#define LOGGING_LOAD NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:TMT_LOG_LEVEL_KEY]; \
    if (logLevel) {\
        ddLogLevel = [logLevel intValue];\
    }


@interface TMTLog : NSObject

    + (void)customizeLogger;

@end
