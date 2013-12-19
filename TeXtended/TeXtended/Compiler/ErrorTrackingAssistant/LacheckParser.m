//
//  LacheckParser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LacheckParser.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "PathFactory.h"
#import "TrackingMessage.h"
#import "MessageCollection.h"
#import <TMTHelperCollection/TMTLog.h>


@implementation LacheckParser

/**
 * This parses a document.
 *
 * @param path to the document
 * @param obj
 * @param action
 */
- (void)parseDocument:(NSString *)path forObject:(id)obj selector:(SEL)action{
    if (!path) {
        return;
    }
    TMTTrackingMessageType thresh = [[[NSUserDefaults standardUserDefaults] valueForKey:TMTLatexLogLevelKey] intValue];
    
    if (thresh < WARNING) {
        // ATM this object only creates warning objects. so nothing to do for ERROR or less.
        return;
    }
    NSTask *task = [[NSTask alloc] init];
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    
    [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
    [task setLaunchPath:[PathFactory lacheck]];
    [task setCurrentDirectoryPath:dirPath];
    
    [task setArguments:[NSArray arrayWithObjects:path, nil]];
    
    
    __block NSPipe *outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    __weak id weakObj = obj;
    [task setTerminationHandler:^(NSTask *task) {
        NSFileHandle * read = [outPipe fileHandleForReading];
        NSData * dataRead = [read readDataToEndOfFile];
        NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        MessageCollection *messages = [self parseOutput:stringRead withBaseDir:dirPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
         [weakObj performSelector:action withObject:messages];
#pragma clang diagnostic pop
        outPipe = nil;
    }];
    
    
    [task launch];
    
}

/**
 * Parse the outbut of Lacheck.
 *
 * @param output of lacheck as NSString
 * @param base as NSString
 *
 * @return the output oas MessageCollection
 */
- (MessageCollection *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    MessageCollection *collection = [MessageCollection new];
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
            NSTextCheckingResult *result = [results objectAtIndex:0];
            NSString *path = [line substringWithRange:[result rangeAtIndex:1]];
            
            NSUInteger lineNumber = [[line substringWithRange:[result rangeAtIndex:2]] integerValue];
            NSString *info = [line substringWithRange:[result rangeAtIndex:3]];
            if (path && [self infoValid:info] && lineNumber >0) {
                TrackingMessage *m = [TrackingMessage warningInDocument:[self absolutPath:path withBaseDir:base] inLine:lineNumber withTitle:@"Lacheck Warning" andInfo:info];
                [collection addMessage:m];
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
- (BOOL)infoValid:(NSString *)info {
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
