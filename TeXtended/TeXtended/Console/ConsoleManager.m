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
    }
    
    return self;
}

+ (ConsoleManager *)sharedConsoleManager {
    if (!sharedInstance) {
        sharedInstance = [ConsoleManager new];
    }
    return sharedInstance;
}


- (void)removeConsoleForModel:(DocumentModel *)model {
    [self.consoles removeObjectForKey:model.identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_MANAGER_CHANGED object:self];
}

- (ConsoleData *)consoleForModel:(DocumentModel *)model {
    return [self consoleForModel:model byCreating:YES];
}

- (ConsoleData *)consoleForModel:(DocumentModel *)model byCreating:(BOOL)create {
    ConsoleData *data = [self.consoles objectForKey:model.identifier];
    if (create && !data) {
        data = [ConsoleData new];
        data.model = model;
        [self.consoles setObject:data forKey:model.identifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_MANAGER_CHANGED object:self];
    }
    return data;
}


@end
