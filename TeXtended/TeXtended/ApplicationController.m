//
//  ApplicationController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ApplicationController.h"
#import "Constants.h"
#import "PreferencesController.h"
#import "DocumentController.h"

@implementation ApplicationController
+ (void)initialize {
    //Register default user defaults
    
    [NSColor colorWithCalibratedRed:36.0/255.0 green:80.0/255 blue:123.0 alpha:1];
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.106 green:0.322 blue:0.482 alpha:1.0]],TMT_COMMAND_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:158.0/255.0 green:30.0/255 blue:44.0/255.0 alpha:1.0]],TMT_INLINE_MATH_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:85.0/255.0 green:169.0/255.0 blue:219.0/255.0 alpha:1.0]],TMT_COMMENT_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0/255.0 green:198.0/255 blue:50.0/255.0 alpha:1.0]],TMT_BRACKET_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0/255.0 green:198.0/255 blue:50.0/255.0 alpha:1.0]],TMT_ARGUMENT_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:236.0/255.0 green:218.0/255 blue:136.0/255.0 alpha:0.9]],TMT_CURRENT_LINE_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:250.0/255.0 green:187.0/255 blue:0.0/255.0 alpha:0.8]],TMT_CARRET_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],TMT_EDITOR_BACKGROUND_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor blackColor]],TMT_EDITOR_FOREGROUND_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor selectedTextBackgroundColor]],TMT_EDITOR_SELECTION_BACKGROUND_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],TMT_EDITOR_SELECTION_FOREGROUND_COLOR,
                              [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],TMT_CURRENT_LINE_TEXT_COLOR,
                              
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_INLINE_MATH,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_COMMANDS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_COMMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_BRACKETS,
                              [NSNumber numberWithBool:NO], TMT_SHOULD_HIGHLIGHT_ARGUMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_CURRENT_LINE,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_CARRET,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_AUTO_INDENT_LINES,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_USE_SPACES_AS_TABS,
                              
                              [NSNumber numberWithInt:4], TMT_EDITOR_NUM_TAB_SPACES,
                              
                              [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"SourceCodePro-Regular" size:12.0]], TMT_EDITOR_FONT,
                              nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    documentController = [[DocumentController alloc] init];
}

- (IBAction)showPreferences:(id)sender {
    if (!preferencesController) {
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [preferencesController showWindow:self];
}

@end
