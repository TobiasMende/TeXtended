//
//  ForwardSynctex.m
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ForwardSynctex.h"
#import "Constants.h"
#import "PathFactory.h"
#import <TMTHelperCollection/TMTLog.h>

@interface ForwardSynctex ()

/**
 * Method for parsing the output string of the synctex task.
 *
 * @param output the tasks answer.
 */
- (void)parseOutput:(NSString*) output;
@end

@implementation ForwardSynctex

- (id)initWithInputPath:(NSString *)inPath outputPath:(NSString *)outPath row:(NSUInteger)row andColumn:(NSUInteger)col {
    self = [super init];
    if (!inPath || !outPath) {
        return nil;
    }
    if (self) {
        NSTask *task = [[NSTask alloc] init];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *path = [outPath stringByDeletingLastPathComponent];
        if (pathVariables) {
            [task setEnvironment:@{@"PATH": pathVariables}];
        }
        [task setLaunchPath:[PathFactory synctex]];
        NSString *inArg = [NSString stringWithFormat:@"%li:%li:%@", row, col, inPath];
        NSString *outArg = [NSString stringWithFormat:@"%@",outPath];
        [task setCurrentDirectoryPath:path];
        
        [task setArguments:@[@"view",@"-i",inArg,@"-o",outArg]];
        
        NSPipe *outPipe = [NSPipe pipe];
        [task setStandardOutput:outPipe];
        [task setTerminationHandler:^(NSTask *task) {
            
            NSFileHandle * read = [outPipe fileHandleForReading];
            NSData * dataRead = [read readDataToEndOfFile];
            NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
            NSMutableString *command = [NSMutableString stringWithString:[PathFactory synctex]];
            for (NSString *arg in task.arguments) {
                [command appendFormat:@" %@", arg];
            }
            [self parseOutput:stringRead];
        }];
        @try {
            [task launch];
        }
        @catch (NSException *exception) {
            DDLogError(@"Cant'start forward synctex task %@. Exception: %@ (%@)", task, exception.reason, exception.name);
            DDLogVerbose(@"%@", [NSThread callStackSymbols]);
        }
       
        
        
    }
    return self;
}

- (void)parseOutput:(NSString *)output {
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *comps = [line componentsSeparatedByString:@":"];
        if (comps.count < 2) {
            continue;
        }
    NSString *key = comps[0];
    NSString *value = comps[1];
    if ([key isEqualToString:@"Page"]) {
        self.page = [value floatValue];
    } else if([key isEqualToString:@"x"]) {
        self.x = [value floatValue];
    } else if([key isEqualToString:@"y"]) {
        self.y = [value floatValue];
    } else if([key isEqualToString:@"h"]) {
        self.h = [value floatValue];
    } else if([key isEqualToString:@"v"]) {
        self.v = [value floatValue];
    } else if([key isEqualToString:@"W"]) {
        self.width = [value floatValue];
    } else if([key isEqualToString:@"H"]) {
        self.height = [value floatValue];
    }
        if (self.page > 0 && self.x > 0 && self.y > 0 && self.h >0 && self.v >0 && self.width >0 && self.height >0) {
            break;
        }
    }
    
}

- (NSString *)description {
    NSMutableString *output = [NSMutableString stringWithFormat:@"Page:%li",self.page];
    [output appendFormat:@"\nx:%lf",self.x];
    [output appendFormat:@"\ny:%lf",self.y];
    [output appendFormat:@"\nh:%lf",self.h];
    [output appendFormat:@"\nv:%lf",self.v];
    [output appendFormat:@"\nW:%lf",self.width];
    [output appendFormat:@"\nH:%lf",self.height];
    return output;
}

@end
