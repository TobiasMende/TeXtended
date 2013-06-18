//
//  ChktexParser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ChktexParser.h"
#import "Constants.h"
#import "PathFactory.h"

static const NSDictionary *WARNING_NUMBERS;
static const NSDictionary *INFO_NUMBERS;
static const NSDictionary *DEBUG_NUMBERS;

@implementation ChktexParser

+ (void)initialize {
    if (self == [ChktexParser class]) {
        //FIXME: initialize the number sets according to texdoc chktex (continue with number 11)
        
        WARNING_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexWarningNumbers" ofType:@"plist"]];
        INFO_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexInfoNumbers" ofType:@"plist"]];
        DEBUG_NUMBERS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChktexDebugNumbers" ofType:@"plist"]];
        
    }
}


- (NSSet *)parseDocument:(NSString *)path {
    if (!path) {
        return nil;
    }
    NSTask *task = [[NSTask alloc] init];
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    
    [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
    [task setLaunchPath:[PathFactory chktex]];
    [task setCurrentDirectoryPath:dirPath];
    // TODO: customize arguments
    [task setArguments:[NSArray arrayWithObjects:@"-qv0", path, nil]];
    
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
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByString:@":"];
        if (components.count < 4) {
            continue;
        }
        NSString *path = [self absolutPath:[components objectAtIndex:0] withBaseDir:base];
        NSUInteger line = [[components objectAtIndex:1] integerValue];
        NSUInteger column = [[components objectAtIndex:2] integerValue];
        NSInteger warning = [[components objectAtIndex:3] integerValue];
        
        //FIXME: check message type and create matching TrackingMessage. Maybe handle the current loglevel first.
    }

    return messages;
}
@end
