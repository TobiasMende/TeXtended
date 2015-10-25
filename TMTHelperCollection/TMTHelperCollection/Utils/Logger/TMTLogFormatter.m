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
        switch (logMessage->_flag) {
            case DDLogFlagError:
                logLevel = @"ERROR\t";
                break;
            case DDLogFlagWarning  :
                logLevel = @"WARN\t";
                break;
            case DDLogFlagInfo  :
                logLevel = @"INFO\t";
                break;
            case DDLogFlagDebug :
                logLevel = @"DEBUG\t";
                break;
            case DDLogFlagVerbose  :
                logLevel = @"VERBOSE\t";
                break;
            default             :
                logLevel = @"UNKNOWN\t";
                break;
        }

        NSString *tmp = [NSString stringWithFormat:@"%@", logMessage->_file];
        NSString *file = [[tmp lastPathComponent] stringByDeletingPathExtension];
        


        NSString *output;
        if (self.extended) {
            if (logMessage->_threadName.length > 0) {
                output = [NSString stringWithFormat:@"%@ - %@| %@.%@ (%@) | %@", logMessage->_timestamp, logLevel, file, logMessage->_function, logMessage->_threadName, logMessage->_message];
            } else {
                output = [NSString stringWithFormat:@"%@ - %@| %@.%@ | %@", logMessage->_timestamp, logLevel, file, logMessage->_function, logMessage->_message];
            }
        } else {
            NSString *classPart;
            if (logMessage->_flag == DDLogFlagVerbose) {
                file = [file stringByAppendingFormat:@" %@ [%li]", logMessage->_function, logMessage->_line];
            }
            if (logMessage->_threadName.length > 0) {
                classPart = [NSString stringWithFormat:@"%@ (%@)", file, logMessage->_threadName];
            } else {
                classPart = file;
            }
             if (logMessage->_flag != DDLogFlagVerbose) {
            [TMTLogFormatter updateMaxLength:classPart.length];
            classPart = [TMTLogFormatter extendClassPart:classPart];
             }
            output = [NSString stringWithFormat:@"%@| %@ | %@", logLevel, classPart, logMessage->_message];
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
