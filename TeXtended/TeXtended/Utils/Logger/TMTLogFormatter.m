//
//  TMTLogFormatter.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTLogFormatter.h"

@implementation TMTLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"ALARM\t"; break;
        case LOG_FLAG_WARN  : logLevel = @"WARN\t"; break;
        case LOG_FLAG_INFO  : logLevel = @"INFO\t"; break;
        default             : logLevel = @"VERBOSE\t"; break;
    }
    
    NSString *tmp = [NSString stringWithFormat:@"%s", logMessage->file];
    NSString *file = [[tmp lastPathComponent] stringByDeletingPathExtension];
    
    NSString *output;
    if (logMessage->threadName.length >0) {
        output = [NSString stringWithFormat:@"%@| %@ (%@) | %@", logLevel,file, logMessage->threadName, logMessage->logMsg];
    } else {
        output = [NSString stringWithFormat:@"%@| %@ | %@", logLevel,file, logMessage->logMsg];
    }
    
    return output;
}

@end
