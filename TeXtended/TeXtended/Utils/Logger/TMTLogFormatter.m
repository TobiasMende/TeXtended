//
//  TMTLogFormatter.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTLogFormatter.h"

@implementation TMTLogFormatter


- (id)initExtended:(BOOL)isExtended {
    self = [self init];
    if (self) {
        self.extended = isExtended;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.extended = NO;
    }
    return self;
}


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
    if (self.extended) {
        if (logMessage->threadName.length >0) {
            output = [NSString stringWithFormat:@"%@ - %@| %@.%s (%@) | %@", logMessage->timestamp, logLevel,file, logMessage->function, logMessage->threadName, logMessage->logMsg];
        } else {
            output = [NSString stringWithFormat:@"%@ - %@| %@.%s | %@", logMessage->timestamp, logLevel,file, logMessage->function, logMessage->logMsg];
        }
    } else {
        if (logMessage->threadName.length >0) {
            output = [NSString stringWithFormat:@"%@| %@ (%@) | %@", logLevel,file, logMessage->threadName, logMessage->logMsg];
        } else {
            output = [NSString stringWithFormat:@"%@| %@ | %@", logLevel,file, logMessage->logMsg];
        }
    }
    
    return output;
}

@end
