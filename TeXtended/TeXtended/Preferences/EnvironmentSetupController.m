//
//  EnvironmentSetupController.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EnvironmentSetupController.h"
#import "PathFactory.h"
#import "Constants.h"

static const NSSet *TEXBIN_AFFECTED_KEYS;

@implementation EnvironmentSetupController


+ (void)initialize {
    if (self == [EnvironmentSetupController class]) {
        TEXBIN_AFFECTED_KEYS = [NSSet setWithObjects:@"synctexImage", @"lacheckImage", @"chktexImage", @"texdocImage", nil];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self bind:@"texbinPath" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_PATH_TO_TEXBIN] options:nil];
    }
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([TEXBIN_AFFECTED_KEYS containsObject:key]) {
        keys = [keys setByAddingObject:@"texbinPath"];
    }
    return keys;
}


- (NSImage *)imageForPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm isExecutableFileAtPath:path]) {
        return [NSImage imageNamed:@"check.png"];
    } else {
        return [NSImage imageNamed:@"error.png"];
    }
}

- (NSImage *)synctexImage {
    return [self imageForPath:[PathFactory synctex]];
}
- (NSImage *)lacheckImage {
    return [self imageForPath:[PathFactory lacheck]];
}
- (NSImage *)chktexImage {
    return [self imageForPath:[PathFactory chktex]];
}
- (NSImage *)texdocImage {
    return [self imageForPath:[PathFactory texdoc]];
}

- (void)dealloc {
    [self unbind:@"texbinPath"];
}
@end
