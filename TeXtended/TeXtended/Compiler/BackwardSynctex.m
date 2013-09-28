//
//  BackwardSynctex.m
//  TeXtended
//
//  Created by Tobias Mende on 26.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BackwardSynctex.h"
#import "Constants.h"
#import "PathFactory.h"
#import "TMTLog.h"

static const NSRegularExpression *SYNCTEX_REGEX;

@interface BackwardSynctex ()
- (void) parseOutput:(NSString*)output;
@end

@implementation BackwardSynctex

+(void)initialize {
    if (self == [BackwardSynctex class]) {
        NSString *pattern = @"Output:(?:.*)\\sInput:(.*)\\sLine:(.*)\\sColumn:(.*)\\sOffset:(.*)\\sContext:(.*)\\s";
        NSError *error;
        SYNCTEX_REGEX = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        
        if (error) {
            DDLogError(@"BackwardSynctex: %@",error.userInfo);
        }
    }
}
- (id)initWithOutputPath:(NSString *)outPath page:(NSUInteger)page andPosition:(NSPoint)position {
    self = [super init];
    if (!outPath) {
        return nil;
    }
    if (self) {
        NSTask *task = [[NSTask alloc] init];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *path = [outPath stringByDeletingLastPathComponent];
        if (pathVariables) {
            [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
        }
        [task setLaunchPath:[PathFactory synctex]];
        NSString *outArg = [NSString stringWithFormat:@"%li:%lf:%lf:%@", page,position.x, position.y, outPath];
        [task setCurrentDirectoryPath:path];
        
        [task setArguments:[NSArray arrayWithObjects:@"edit",@"-o",outArg, nil]];
        
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
        [self parseOutput:stringRead];
    }
    return self;
}

- (void)parseOutput:(NSString *)output {
    NSArray *results = [SYNCTEX_REGEX matchesInString:output options:0 range:NSMakeRange(0, output.length)];
    if (results.count > 0) {
        NSTextCheckingResult *result = [results objectAtIndex:0];
        if (result.numberOfRanges > 4) {
            self.inputPath = [output substringWithRange:[result rangeAtIndex:1]];
            NSInteger line = [[output substringWithRange:[result rangeAtIndex:2]] integerValue];
            NSInteger column = [[output substringWithRange:[result rangeAtIndex:3]] integerValue];
            self.offset = [[output substringWithRange:[result rangeAtIndex:4]] integerValue];
            if (result.numberOfRanges > 5) {
                self.context = [output substringWithRange:[result rangeAtIndex:5]];
            }
            self.line = (line >= 1 ? line : 1);
            self.column = (column >= 0 ? column : 0);
        }
    } else {
        DDLogError(@"BackwardSynctex: Can't extract information from %@", output);
    }
}

@end
