//
//  CompletionsController.m
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionsController.h"
#import "CommandCompletion.h"
#import "EnvironmentCompletion.h"
#import "DropCompletion.h"
#import "ApplicationController.h"
#import "Constants.h"
#import <TMTHelperCollection/TMTLog.h>
#import "CompletionManager.h"



@interface CompletionsController()


@end
NSInteger commandTag = 1;
NSInteger environmentTag = 2;
NSInteger dropTag = 3;
CompletionsController *instance;
@implementation CompletionsController

- (id)init {
    if (instance) {
        return instance;
    }
    self = [super init];
    if (self) {
        self.manager = [CompletionManager sharedInstance];
        instance = self;
    }
    return self;
}

+ (CompletionsController *)sharedInstance {
    if (!instance) {
        instance = [CompletionsController new];
    }
    return instance;
}

- (void)addEntryIn:(NSTableView *)tableView withArrayController :(NSArrayController *)controller {
    [controller add:self];
    [tableView scrollRowToVisible:tableView.selectedRow];
    [tableView editColumn:0 row:tableView.selectedRow withEvent:nil select:YES];
}

@end
