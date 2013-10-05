//
//  TMTLogFormatter.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTLogFormatter.h"

NSUInteger MAX_CLASS_NAME_LENGTH = 25;

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
        NSString *classPart;
        if (logMessage->threadName.length >0) {
            classPart = [NSString stringWithFormat:@"%@ (%@)", file, logMessage->threadName];
        } else {
            classPart = file;
        }
        [TMTLogFormatter updateMaxLength:classPart.length];
        classPart = [TMTLogFormatter extendClassPart:classPart];
        output = [NSString stringWithFormat:@"%@| %@ | %@", logLevel, classPart, logMessage->logMsg];
    }
    
    return output;
}

+ (void)updateMaxLength:(NSUInteger)length {
    if (length > MAX_CLASS_NAME_LENGTH) {
        MAX_CLASS_NAME_LENGTH = length;
    }
}

+ (NSString *)extendClassPart:(NSString *)classPart {
    NSUInteger diff = MAX_CLASS_NAME_LENGTH - classPart.length;
    if (MAX_CLASS_NAME_LENGTH > classPart.length) {
        return [classPart stringByPaddingToLength:MAX_CLASS_NAME_LENGTH withString:@" " startingAtIndex:0];
    }
    return classPart;
}

@end
