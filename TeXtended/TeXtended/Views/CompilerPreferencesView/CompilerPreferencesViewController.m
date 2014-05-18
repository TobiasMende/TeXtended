//
//  CompilerPreferencesViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "CompilerPreferencesViewController.h"

@interface CompilerPreferencesViewController ()

@end

@implementation CompilerPreferencesViewController


    - (id)init
    {
        self = [super initWithNibName:@"CompilerPreferencesView" bundle:nil];
        return self;
    }

    - (void)dealloc
    {
        [self unbind:@"enabled"];
    }


    - (NSColor *)defaultTextColor
    {
        if (!self.enabled) {
            return [NSColor disabledControlTextColor];
        }
        return [NSColor textColor];
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];

        if ([key isEqualToString:@"defaultTextColor"]) {
            keys = [keys setByAddingObject:@"enabled"];
        }
        return keys;
    }
@end
