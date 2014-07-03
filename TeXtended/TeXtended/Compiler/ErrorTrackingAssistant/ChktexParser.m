//
//  ChktexParser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ChktexParser.h"
#import "PathFactory.h"
#import <TMTHelperCollection/TMTLog.h>

static const NSDictionary *WARNING_NUMBERS;

static const NSDictionary *INFO_NUMBERS;

static const NSDictionary *DEBUG_NUMBERS;

@implementation ChktexParser

    + (void)initialize
    {
        NSLog(@"%@", self);


        if (self == [ChktexParser class]) {
            //FIXME: initialize the number sets according to texdoc chktex (continue with number 11)

            WARNING_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexWarningNumbers" ofType:@"plist"]];
            INFO_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexInfoNumbers" ofType:@"plist"]];
            DEBUG_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexDebugNumbers" ofType:@"plist"]];

        }
    }

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
        DDLogInfo(@"Parsing %@", path);
        NSTask *task = [NSTask new];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *dirPath = [path stringByDeletingLastPathComponent];

        [task setEnvironment:@{@"PATH" : pathVariables}];
        [task setLaunchPath:[PathFactory chktex]];
        [task setCurrentDirectoryPath:dirPath];
        // TODO: customize arguments
        [task setArguments:@[@"-qv0", path]];

        [task setStandardOutput:[NSPipe pipe]];
        [task setStandardError:[NSPipe pipe]];
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
            DDLogError(@"Cant'start chktex task %@. Exception: %@ (%@)", task, exception.reason, exception.name);
            DDLogVerbose(@"%@", [NSThread callStackSymbols]);
            completionHandler(nil);
        }

    }

/**
 * Parse the outbut of Chtex.
 *
 * @param output of lacheck as NSString
 * @param base as NSString
 *
 * @return the output oas MessageCollection
 */
    - (NSArray *)parseOutput:(NSString *)output withBaseDir:(NSString *)base
    {
        TMTTrackingMessageType thresh = [[[NSUserDefaults standardUserDefaults] valueForKey:TMTLatexLogLevelKey] intValue];
        NSMutableArray *collection = [NSMutableArray new];
        NSArray *lines = [output componentsSeparatedByString:@"\n"];

        for (NSString *line in lines) {
            NSArray *components = [line componentsSeparatedByString:@":"];
            if (components.count < 5) {
                continue;
            }
            NSString *path = [self absolutPath:components[0] withBaseDir:base];
            NSUInteger lineNumber = [components[1] integerValue];
            NSUInteger column = [components[2] integerValue];
            NSInteger warning = [components[3] integerValue];
            NSString *info = components[4];
            TMTTrackingMessageType type = [self typeForChktexNumber:warning];

            if (type <= thresh) {
                TrackingMessage *m = [[TrackingMessage alloc] initMessage:type inDocument:path inLine:lineNumber withTitle:@"Chktex Warning" andInfo:info];
                m.furtherInfo = [self messageForChktexNumber:warning ofType:type];
                m.column = column;
                [collection addObject:m];
            }
        }

        return collection;
    }

/**
 * Transform a chtexnumber to a TrackingMessageType.
 *
 * @param number a chtexnumber as NSInteger
 *
 * @return the corresponding TMTTrackingMessageType
 */
    - (TMTTrackingMessageType)typeForChktexNumber:(NSInteger)number
    {
        NSString *key = [NSString stringWithFormat:@"%li", number];
        if (WARNING_NUMBERS[key]) {
            return TMTWarningMessage;
        }
        if (INFO_NUMBERS[key]) {
            return TMTInfoMessage;
        }
        if (DEBUG_NUMBERS[key]) {
            return TMTDebugMessage;
        }
        DDLogWarn(@"Unknown message type for %li", number);
        return TMTDebugMessage;
    }

/**
 * Transform a chtexnumber and a TrackingmessageType to a message as String.
 *
 * @param number a chtexnumber as NSInteger
 * @param type the type of the TMTTrackingMessageType
 *
 * @return the corresponding message as NSString
 */
    - (NSString *)messageForChktexNumber:(NSInteger)number ofType:(TMTTrackingMessageType)type
    {
        NSString *key = [NSString stringWithFormat:@"%li", number];
        switch (type) {
            case TMTWarningMessage:
                return WARNING_NUMBERS[key];
                break;
            case TMTInfoMessage:
                return INFO_NUMBERS[key];
                break;
            case TMTDebugMessage:
                return DEBUG_NUMBERS[key];
                break;

            default:
                return nil;
                break;
        }
    }

@end
