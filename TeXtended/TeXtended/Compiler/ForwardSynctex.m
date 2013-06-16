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

@interface ForwardSynctex ()
- (void)parseOutput:(NSString*) output;
@end

@implementation ForwardSynctex

- (id)initWithInputPath:(NSString *)inPath outputPath:(NSString *)outPath row:(NSUInteger)row andColumn:(NSUInteger)col {
    self = [super init];
    if (self) {
        NSTask *task = [[NSTask alloc] init];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *path = [outPath stringByDeletingLastPathComponent];
        
        [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
        [task setLaunchPath:[PathFactory synctex]];
        NSString *inArg = [NSString stringWithFormat:@"%li:%li:%@", row, col, inPath];
        NSString *outArg = [NSString stringWithFormat:@"%@",outPath];
        [task setCurrentDirectoryPath:path];
        
        [task setArguments:[NSArray arrayWithObjects:@"view",@"-i",inArg,@"-o",outArg, nil]];
        
        NSPipe *outPipe = [NSPipe pipe];
        [task setStandardOutput:outPipe];
        [task launch];
        
        [task waitUntilExit];
        NSFileHandle * read = [outPipe fileHandleForReading];
        NSData * dataRead = [read readDataToEndOfFile];
        NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        [self parseOutput:stringRead];
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
    NSString *key = [comps objectAtIndex:0];
    NSString *value = [comps objectAtIndex:1];
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
    }
    
}

@end
