//
//  ConsoleManager.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleManager.h"
#import "DocumentModel.h"
#import "ConsoleData.h"
#import "Constants.h"
static ConsoleManager *sharedInstance;
@implementation ConsoleManager


- (id)init {
    if (sharedInstance) {
        return sharedInstance;
    }
    self = [super init];
    if (self) {
        self.consoles = [NSMutableDictionary new];
        sharedInstance = self;
    }
    
    return self;
}

+ (ConsoleManager *)sharedConsoleManager {
    if (!sharedInstance) {
       [ConsoleManager new];
    }
    return sharedInstance;
}


- (void)removeConsoleForModel:(DocumentModel *)model {
    ConsoleData *data = (self.consoles)[model.identifier];
    if (data) {
        [self.consoles removeObjectForKey:model.identifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_REMOVED_MANAGER_CHANGED object:self userInfo:@{TMTConsoleDataKey : data}];
    }
}

- (ConsoleData *)consoleForModel:(DocumentModel *)model {
    return [self consoleForModel:model byCreating:YES];
}

- (ConsoleData *)consoleForModel:(DocumentModel *)model byCreating:(BOOL)create {
    ConsoleData *data = (self.consoles)[model.identifier];
    if (create && !data) {
        data = [ConsoleData new];
        data.model = model;
        (self.consoles)[model.identifier] = data;
        [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_ADDED_MANAGER_CHANGED object:self userInfo:@{TMTConsoleDataKey: data}];
    }
    return data;
}


@end
