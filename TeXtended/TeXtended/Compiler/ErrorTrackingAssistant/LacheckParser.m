//
//  LacheckParser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LacheckParser.h"
#import "Constants.h"
#import "PathFactory.h"
#import "TrackingMessage.h"
#import <TMTHelperCollection/TMTLog.h>


@implementation LacheckParser

/**
 * This parses a document.
 *
 * @param path to the document
 */
    - (void)parseDocument:(NSString *)path callbackBlock:(void (^)(NSArray *))handler
    {
        completionHandler = handler;
        if (!path) {
            return;
        }
        TMTTrackingMessageType thresh = [[[NSUserDefaults standardUserDefaults] valueForKey:TMTLatexLogLevelKey] intValue];

        if (thresh < WARNING) {
            // ATM this object only creates warning objects. so nothing to do for ERROR or less.
            return;
        }
        NSTask *task = [NSTask new];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *dirPath = [path stringByDeletingLastPathComponent];

        [task setEnvironment:@{@"PATH" : pathVariables}];
        [task setLaunchPath:[PathFactory lacheck]];
        [task setCurrentDirectoryPath:dirPath];

        [task setArguments:@[path]];


        [task setStandardOutput:[NSPipe pipe]];
        [task setTerminationHandler:^(NSTask *t)
        {
            NSFileHandle *read = [t.standardOutput fileHandleForReading];
            NSData *dataRead = [read readDataToEndOfFile];
            NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
            NSArray *messages = [self parseOutput:stringRead withBaseDir:dirPath];
            if (self->completionHandler) {
                self->completionHandler(messages);
            }
            t.terminationHandler = nil;
        }];

        @try {
            [task launch];
        }
        @catch (NSException *exception) {
            DDLogError(@"Cant'start lacheck task %@. Exception: %@ (%@)", task, exception.reason, exception.name);
            DDLogVerbose(@"%@", [NSThread callStackSymbols]);
            completionHandler(nil);
        }

    }

/**
 * Parse the outbut of Lacheck.
 *
 * @param output of lacheck as NSString
 * @param base as NSString
 *
 * @return the output oas MessageCollection
 */
    - (NSArray *)parseOutput:(NSString *)output withBaseDir:(NSString *)base
    {
        NSMutableArray *collection = [NSMutableArray new];
        NSArray *lines = [output componentsSeparatedByString:@"\n"];
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\"(.*)\",\\sline\\s(.*):\\s(.*)$" options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            DDLogError(@"Lacheck Regex Invalid: %@", [error userInfo]);
            return nil;
        }

        for (NSString *line in lines) {
            NSArray *results = [regex matchesInString:line options:0 range:NSMakeRange(0, line.length)];
            if (results.count > 0) {
                NSTextCheckingResult *result = results[0];
                NSString *path = [line substringWithRange:[result rangeAtIndex:1]];

                NSUInteger lineNumber = [[line substringWithRange:[result rangeAtIndex:2]] integerValue];
                NSString *info = [line substringWithRange:[result rangeAtIndex:3]];
                if (path && [self infoValid:info] && lineNumber > 0) {
                    TrackingMessage *m = [TrackingMessage warningInDocument:[self absolutPath:path withBaseDir:base] inLine:lineNumber withTitle:@"Lacheck Warning" andInfo:info];
                    [collection addObject:m];
                }
            }
        }

        return collection;

    }

/**
 * Check if a given info is valid.
 *
 * @param info as NSString
 *
 * @return ´YES´ if the info is valid
 */
    - (BOOL)infoValid:(NSString *)info
    {
        if (!info) {
            return NO;
        }
        NSRange unmatchedRange = [[info lowercaseString] rangeOfString:@"unmatched"];
        NSRange unwantedRange = [[info lowercaseString] rangeOfString:@"unwanted"];
        NSRange eofRange = [[info lowercaseString] rangeOfString:@"end of file"];
        if (unmatchedRange.location != NSNotFound && eofRange.location == NSNotFound) {
            return YES;
        }
        if (unwantedRange.location != NSNotFound) {
            return YES;
        }

        //TODO: further warnings

        return NO;

    }

@end
