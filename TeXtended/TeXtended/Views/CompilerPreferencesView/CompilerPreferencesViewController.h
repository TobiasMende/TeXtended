//
//  CompilerPreferencesViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CompileSetting;

@interface CompilerPreferencesViewController : NSViewController

    @property CompileSetting *compiler;

    @property BOOL enabled;

    - (NSColor *)defaultTextColor;
@end
