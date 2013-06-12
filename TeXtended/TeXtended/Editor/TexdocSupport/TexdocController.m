//
//  TexdocController.m
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocController.h"
#import "TexdocEntry.h"
#import "Constants.h"

@interface TexdocController ()
- (void)texdocReadComplete:(NSNotification *)notification withPackageName:(NSString*) package info:(NSDictionary*)info andHandler:(id<TexdocHandlerProtocol>)handler;
- (NSMutableArray *)parseTexdocList:(NSString *)texdocList;
@end

@implementation TexdocController

- (void)texdocReadComplete:(NSNotification *)notification withPackageName:(NSString*) package info:(NSDictionary *)info andHandler:(id<TexdocHandlerProtocol>) handler {
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *texdocArray = [self parseTexdocList:string];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
    [handler texdocReadComplete:texdocArray withPackageName:package andInfo:info];
 
    
}

- (NSMutableArray *)parseTexdocList:(NSString *)texdocList {
    if (texdocList.length == 0) {
        return nil;
    }
    NSArray *lines = [texdocList componentsSeparatedByString:@"\n"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:lines.count];
    for (NSString *line in lines) {
        NSArray *entry = [line componentsSeparatedByString:@"\t"];
        TexdocEntry *e = [[TexdocEntry alloc] initWithArray:entry];
        if (e) {
            [result addObject:e];
        }
    }
    
    
    return result;
}

- (void)executeTexdocForPackage:(NSString *)name withInfo:(NSDictionary *)info andHandler:(id<TexdocHandlerProtocol>)handler{
    NSTask *task = [[NSTask alloc] init];
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
    NSString *command = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_PATH_TO_TEXDOC]];
    [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
    [task setLaunchPath:command];
    NSArray	*args = [NSArray arrayWithObjects:@"-l", @"-M", name,
                     nil];
    NSPipe *outputPipe = [NSPipe pipe];
    
    [task setStandardOutput:outputPipe];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self texdocReadComplete:note withPackageName:name info:info andHandler:handler];
    }];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    [task setArguments: args];
    [task launch];
}

@end
