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
    [self.consoles removeObjectForKey:model.dictionaryKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_MANAGER_CHANGED object:self];
}

- (ConsoleData *)consoleForModel:(DocumentModel *)model {
    ConsoleData *data = [self.consoles objectForKey:model.dictionaryKey];
    if (!data) {
        data = [ConsoleData new];
        data.model = model;
        [self.consoles setObject:data forKey:model.dictionaryKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_MANAGER_CHANGED object:self];
    }
    return data;
}


@end
