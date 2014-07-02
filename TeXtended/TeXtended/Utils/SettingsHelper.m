//
// Created by Tobias Mende on 02.07.14.
// Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "SettingsHelper.h"
#import "Constants.h"


@implementation SettingsHelper

+ (SettingsHelper *) sharedInstance {
    static dispatch_once_t pred;
    static SettingsHelper *instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[SettingsHelper alloc] init];
    });
    return instance;
}


- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        self.shouldUseSpacesAsTabs = [[[defaults values] valueForKey:TMT_SHOULD_USE_SPACES_AS_TABS] boolValue];
        [self bind:@"shouldUseSpacesAsTabs" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_USE_SPACES_AS_TABS] options:NULL];
        self.numberOfSpacesForTab = [[defaults values] valueForKey:TMT_EDITOR_NUM_TAB_SPACES];
        [self bind:@"numberOfSpacesForTab" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_NUM_TAB_SPACES] options:NULL];
        self.shouldAutoIndentLines = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INDENT_LINES] boolValue];
        [self bind:@"shouldAutoIndentLines" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INDENT_LINES] options:NULL];
    }
    return self;
}

- (void)dealloc {
    [self unbind:@"numberOfSpacesForTab"];
    [self unbind:@"shouldUseSpacesAsTabs"];
}
@end