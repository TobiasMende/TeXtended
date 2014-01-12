//
//  CompletionTableController.m
//  TeXtended
//
//  Created by Tobias Mende on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "CompletionTableController.h"
#import "ApplicationController.h"
#import "Completion.h"
#import <TMTHelperCollection/TMTLog.h>
static NSString *FILE_EXTENSION = @"plist";

@interface CompletionTableController ()
- (NSString *)totalFileName;

@end
@implementation CompletionTableController

- (id)initWithFileName:(NSString *)name andContentType:(Class)class {
    self = [super init];
    if (self) {
        self.completions = [NSMutableArray new];
        fileName = name;
        type = class;
    }
    return self;
}

#pragma mark - Loading & Saving

- (void)loadCompletions {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    
    
    NSString *path;
    if (applicationSupport) {
        path = [applicationSupport stringByAppendingPathComponent:self.totalFileName];

        if (![fm fileExistsAtPath:path]) {
            path = nil;
        }
       
    }
    
    if(!path) {
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:FILE_EXTENSION];
    }
    
    
    [self loadCompletionsWithPath:path];
}


- (void)saveCompletions {
    NSString *path;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    if (applicationSupport) {
        path = [applicationSupport stringByAppendingPathComponent:self.totalFileName];
        if (![fm fileExistsAtPath:path]) {
            [fm createFileAtPath:path contents:nil attributes:nil];
        }
        // Storing Completions:
        [self.completions writeToFile:path atomically:YES];
      
    } else {
        DDLogWarn(@"Can't store user completions");
    }
    
}

- (void)loadCompletionsWithPath:(NSString *)path {
    NSArray *dict = [NSArray arrayWithContentsOfFile:path];
    
    assert([type instancesRespondToSelector:@selector(initWithDictionary:)]);
    for(NSDictionary *d in dict) {
        id object = [[type alloc] initWithDictionary:d];
        [self.completions addObject:object];
    }
}


#pragma mark - Actions

- (void)resetRanking {
    for(Completion *completion in self.completions) {
        completion.counter = 0;
    }
}


- (void)resetDefaults {
    [self.completions removeAllObjects];
    [self loadCompletionsWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:FILE_EXTENSION]];
}

#pragma mark - Private Methods

- (NSString *)totalFileName {
    return [fileName stringByAppendingPathExtension:FILE_EXTENSION];
}
@end
