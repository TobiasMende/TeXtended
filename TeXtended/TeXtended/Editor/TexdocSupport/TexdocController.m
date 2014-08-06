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
#import "PathFactory.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT_DYNAMIC

@interface TexdocController ()

/**
 Method called when the task terminates
 
 @param notification the NSFileHandleReadToEndOfFileCompletionNotification notification
 @param package the package name
 @param info the additional user info
 @param handler the callback handler
 */
    - (void)texdocReadComplete:(NSNotification *)notification withPackageName:(NSString *)package info:(NSDictionary *)info andHandler:(id <TexdocHandlerProtocol>)handler;

/**
 Parser method for extracting TexdocEntry objects from the tasks output
 
 @param texdocList the task output to parse
 
 @return an array of TexdocEntry objects.
 */
    - (NSMutableArray *)parseTexdocList:(NSString *)texdocList;
@end

@implementation TexdocController

+ (void)initialize {
    LOGGING_LOAD
}
    - (void)texdocReadComplete:(NSNotification *)notification withPackageName:(NSString *)package info:(NSDictionary *)info andHandler:(id <TexdocHandlerProtocol>)handler
    {
        NSData *data = [notification userInfo][NSFileHandleNotificationDataItem];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableArray *texdocArray = [self parseTexdocList:string];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
        [handler texdocReadComplete:texdocArray withPackageName:package andInfo:info];


    }

    - (NSMutableArray *)parseTexdocList:(NSString *)texdocList
    {
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

    - (void)executeTexdocForPackage:(NSString *)name withInfo:(NSDictionary *)info andHandler:(id <TexdocHandlerProtocol>)handler
    {
        if (task) {
            if (task.isRunning) {
                [task interrupt];
            }
        }
        task = [NSTask new];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *command = [PathFactory texdoc];
        [task setEnvironment:@{@"PATH" : pathVariables}];
        [task setLaunchPath:command];
        NSArray *args = @[@"-l", @"-M", name];
        NSPipe *outputPipe = [NSPipe pipe];
        [task setCurrentDirectoryPath:[@"~" stringByExpandingTildeInPath]];

        [task setStandardOutput:outputPipe];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
        {
            [self texdocReadComplete:note withPackageName:name info:info andHandler:handler];
        }];
        [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
        [task setArguments:args];
        @try {
            [task launch];
        }
        @catch (NSException *exception) {
            DDLogError(@"Cant'start texdoc task %@. Exception: %@ (%@)", task, exception.reason, exception.name);
            DDLogDebug(@"%@", [NSThread callStackSymbols]);
        }
    }

    - (void)dealloc
    {
        if (task && task.isRunning) {
            [task interrupt];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

@end
