//
//  TMTLog.h
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>


#pragma mark - TMTLog Statements

#define TMT_TRACE DDLogVerbose(@"");
#define TMT_LOG_LEVEL_KEY @"TMT_LOG_LEVEL"

#define LOGGING(level) static const DDLogLevel ddLogLevel = level;

#define LOGGING_DYNAMIC(level) static DDLogLevel ddLogLevel = level;

#ifdef DEBUG
#define LOGGING_DEFAULT LOGGING(DDLogLevelVerbose)
#define LOGGING_DEFAULT_DYNAMIC LOGGING_DYNAMIC(DDLogLevelVerbose)
#else
#define LOGGING_DEFAULT LOGGING(DDLogLevelInfo)
#define LOGGING_DEFAULT_DYNAMIC LOGGING_DYNAMIC(DDLogLevelInfo)
#endif


#define LOGGING_LOAD NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:TMT_LOG_LEVEL_KEY]; \
    if (logLevel) {\
        ddLogLevel = [logLevel intValue];\
    }


@interface TMTLog : NSObject

    + (void)customizeLogger;

@end
