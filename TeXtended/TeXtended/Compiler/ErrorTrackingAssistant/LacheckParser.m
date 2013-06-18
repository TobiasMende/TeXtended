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


@implementation LacheckParser


- (NSSet *)parseDocument:(NSString *)path {
    if (!path) {
        return nil;
    }
    NSTask *task = [[NSTask alloc] init];
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    
    [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
    [task setLaunchPath:[PathFactory lacheck]];
    [task setCurrentDirectoryPath:dirPath];
    
    [task setArguments:[NSArray arrayWithObjects:path, nil]];
    
    NSPipe *outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    [task launch];
    
    [task waitUntilExit];
    NSFileHandle * read = [outPipe fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    NSMutableString *command = [NSMutableString stringWithString:[PathFactory synctex]];
    for (NSString *arg in task.arguments) {
        [command appendFormat:@" %@", arg];
    }
    return [self parseOutput:stringRead withBaseDir:dirPath];
}

- (NSSet *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    NSMutableSet *messages= [NSMutableSet new];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\"(.*)\",\\sline\\s(.*):\\s(.*)$" options:NSRegularExpressionAnchorsMatchLines error:&error];
    if (error) {
        NSLog(@"Lacheck Regex Invalid: %@", [error userInfo]);
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
                [messages addObject:m];
            }
        }
    }
    
    return messages;
    
}

- (BOOL)infoValid:(NSString *)info {
    if (!info) {
        return NO;
    }
    NSRange unmatchedRange = [[info lowercaseString] rangeOfString:@"unmatched"];
    NSRange eofRange = [[info lowercaseString] rangeOfString:@"end of file"];
    if (unmatchedRange.location != NSNotFound && eofRange.location == NSNotFound) {
        return YES;
    }
    
    //TODO: further warnings
    
    return NO;
    
}
@end
