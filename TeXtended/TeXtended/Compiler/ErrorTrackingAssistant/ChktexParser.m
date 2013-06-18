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
#import "MessageCollection.h"

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


- (MessageCollection *)parseDocument:(NSString *)path {
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

- (MessageCollection *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    TMTTrackingMessageType thresh = [[[NSUserDefaults standardUserDefaults] valueForKey:TMTLatexLogLevelKey] intValue];
    MessageCollection *collection = [MessageCollection new];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByString:@":"];
        if (components.count < 5) {
            continue;
        }
        NSString *path = [self absolutPath:[components objectAtIndex:0] withBaseDir:base];
        NSUInteger line = [[components objectAtIndex:1] integerValue];
        NSUInteger column = [[components objectAtIndex:2] integerValue];
        NSInteger warning = [[components objectAtIndex:3] integerValue];
        NSString *info = [components objectAtIndex:4];
        TMTTrackingMessageType type = [self typeForChktexNumber:warning];
        
        if (type <= thresh) {
            TrackingMessage *m = [[TrackingMessage alloc] initMessage:type inDocument:path inLine:line withTitle:@"Chktex Warning" andInfo:info];
            m.furtherInfo = [self messageForChktexNumber:warning ofType:type];
            m.column = column;
            [collection addMessage:m];
        }
    }

    return collection;
}

- (TMTTrackingMessageType)typeForChktexNumber:(NSInteger)number {
    NSNumber *key = [NSNumber numberWithInteger:number];
    if ([WARNING_NUMBERS objectForKey:key]) {
        return TMTWarningMessage;
    }
    if ([INFO_NUMBERS objectForKey:key]) {
        return TMTInfoMessage;
    }
    if ([DEBUG_NUMBERS objectForKey:key]) {
        return TMTDebugMessage;
    }
    NSLog(@"WARNING: Unknown message type for %li", number);
    return TMTDebugMessage;
}

- (NSString *)messageForChktexNumber:(NSInteger)number ofType:(TMTTrackingMessageType)type {
    NSNumber *key = [NSNumber numberWithInteger:number];
    switch (type) {
        case TMTWarningMessage:
            return [WARNING_NUMBERS objectForKey:key];
            break;
        case TMTInfoMessage:
            return [INFO_NUMBERS objectForKey:key];
            break;
        case TMTDebugMessage:
            return [DEBUG_NUMBERS objectForKey:key];
            break;
            
        default:
            return nil;
            break;
    }
}
@end
