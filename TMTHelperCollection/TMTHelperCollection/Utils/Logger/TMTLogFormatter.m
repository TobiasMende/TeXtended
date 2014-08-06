//
//  TMTLogFormatter.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTLogFormatter.h"

NSUInteger MAX_CLASS_NAME_LENGTH = 20;

@implementation TMTLogFormatter


    - (id)initExtended:(BOOL)isExtended
    {
        self = [self init];
        if (self) {
            self.extended = isExtended;
        }
        return self;
    }

    - (id)init
    {
        self = [super init];
        if (self) {
            self.extended = NO;
        }
        return self;
    }


    - (NSString *)formatLogMessage:(DDLogMessage *)logMessage
    {
        NSString *logLevel;
        switch (logMessage->logFlag) {
            case LOG_FLAG_FATAL:
                logLevel = @"FATAL\t";
                break;
            case LOG_FLAG_ERROR :
                logLevel = @"ERROR\t";
                break;
            case LOG_FLAG_WARN  :
                logLevel = @"WARN\t";
                break;
            case LOG_FLAG_NOTICE :
                logLevel = @"NOTICE\t";
                break;
            case LOG_FLAG_INFO  :
                logLevel = @"INFO\t";
                break;
            case LOG_FLAG_DEBUG :
                logLevel = @"DEBUG\t";
                break;
            case LOG_FLAG_TRACE  :
                logLevel = @"TRACE\t";
                break;
            default             :
                logLevel = @"UNKNOWN\t";
                break;
        }

        NSString *tmp = [NSString stringWithFormat:@"%s", logMessage->file];
        NSString *file = [[tmp lastPathComponent] stringByDeletingPathExtension];
        


        NSString *output;
        if (self.extended) {
            if (logMessage->threadName.length > 0) {
                output = [NSString stringWithFormat:@"%@ - %@| %@.%s (%@) | %@", logMessage->timestamp, logLevel, file, logMessage->function, logMessage->threadName, logMessage->logMsg];
            } else {
                output = [NSString stringWithFormat:@"%@ - %@| %@.%s | %@", logMessage->timestamp, logLevel, file, logMessage->function, logMessage->logMsg];
            }
        } else {
            NSString *classPart;
            if (logMessage->logFlag == LOG_FLAG_TRACE) {
                file = [file stringByAppendingFormat:@" %s [%d]", logMessage->function, logMessage->lineNumber];
            }
            if (logMessage->threadName.length > 0) {
                classPart = [NSString stringWithFormat:@"%@ (%@)", file, logMessage->threadName];
            } else {
                classPart = file;
            }
             if (logMessage->logFlag != LOG_FLAG_TRACE) {
            [TMTLogFormatter updateMaxLength:classPart.length];
            classPart = [TMTLogFormatter extendClassPart:classPart];
             }
            output = [NSString stringWithFormat:@"%@| %@ | %@", logLevel, classPart, logMessage->logMsg];
        }

        return output;
    }


    + (void)updateMaxLength:(NSUInteger)length
    {
        if (length > MAX_CLASS_NAME_LENGTH) {
            MAX_CLASS_NAME_LENGTH = length;
        }
    }

    + (NSString *)extendClassPart:(NSString *)classPart
    {
        //NSUInteger diff = MAX_CLASS_NAME_LENGTH - classPart.length;
        if (MAX_CLASS_NAME_LENGTH > classPart.length) {
            return [classPart stringByPaddingToLength:MAX_CLASS_NAME_LENGTH withString:@" " startingAtIndex:0];
        }
        return classPart;
    }

@end
