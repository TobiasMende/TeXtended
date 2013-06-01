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
#import "DocumentCreationController.h"
#import "CompletionsController.h"
#import "CompileFlowHandler.h"
ApplicationController *sharedInstance;
@interface ApplicationController ()

+ (void)registerDefaults;
+ (void)mergeCompileFlows;

@end

@implementation ApplicationController
+ (void)initialize {
    //Register default user defaults
    [self registerDefaults];
    // Merging compile flows
    [self mergeCompileFlows];
}


+ (ApplicationController *)sharedApplicationController {
    if (!sharedInstance) {
        sharedInstance = [[ApplicationController alloc] init];
    }
    return sharedInstance;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    sharedInstance = self;
    documentCreationController = [[DocumentCreationController alloc] init];
    preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];

    
}


- (void)applicationWillTerminate:(NSNotification *)notification {
    [preferencesController applicationWillTerminate:(NSNotification *)notification];
}

- (CompletionsController *)completionsController {
    return [preferencesController completionsController];
}

- (IBAction)showPreferences:(id)sender {
    if (!preferencesController) {
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [preferencesController showWindow:self];
}


+ (NSString *)userApplicationSupportDirectoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSURL *applicationSupport = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (applicationSupport && !error) {
        NSString *directoryPath = [[applicationSupport path] stringByAppendingPathComponent:@"de.uni-luebeck.isp.tmtproject.TeXtended"];
        if ([self checkForAndCreateFolder:directoryPath]) {
            return directoryPath;
        }
    }
    return nil;
}

+ (void)registerDefaults {
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
                              [NSArchiver archivedDataWithRootObject:[NSColor selectedMenuItemColor]], TMT_TEXDOC_LINK_COLOR,
                              
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_INLINE_MATH,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_COMMANDS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_COMMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_BRACKETS,
                              [NSNumber numberWithBool:NO], TMT_SHOULD_HIGHLIGHT_ARGUMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_CURRENT_LINE,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS,
                              [NSNumber numberWithBool:NO], TMT_SHOULD_HIGHLIGHT_CARRET,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_AUTO_INDENT_LINES,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_USE_SPACES_AS_TABS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_COMPLETE_COMMANDS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_COMPLETE_ENVIRONMENTS,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_LINK_TEXDOC,
                              [NSNumber numberWithBool:YES], TMT_SHOULD_UNDERLINE_TEXDOC_LINKS,
                              [NSNumber numberWithInt:4], TMT_EDITOR_NUM_TAB_SPACES,
                              [NSNumber numberWithInt:80], TMT_EDITOR_HARD_WRAP_AFTER,
                              [NSNumber numberWithInt:HardWrap], TMT_EDITOR_LINE_WRAP_MODE,
                              @"/usr/local/bin:/usr/bin:/usr/texbin", TMT_ENVIRONMENT_PATH,
                              @"/usr/texbin/texdoc", TMT_PATH_TO_TEXDOC,
                              @"pdflatex.sh", TMTLiveCompileFlow,
                              @"pdflatex.sh", TMTDraftCompileFlow,
                              @"pdflatex.sh", TMTFinalCompileFlow,                              
                              [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"SourceCodePro-Regular" size:12.0]], TMT_EDITOR_FONT,
                              nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (void)mergeCompileFlows {
    NSString* flowPath = [CompileFlowHandler path];
    BOOL exists = [self checkForAndCreateFolder:flowPath];
    if (exists) {
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"CompileFlows" ofType:nil];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSError* error;
        NSArray *files = [fm contentsOfDirectoryAtPath:bundlePath error:&error];
        if (error) {
            NSLog(@"Can't read compile flows from %@. Error: %@", bundlePath, [error userInfo]);
        } else {
            for(NSString *path in files) {
                NSString* srcPath = [bundlePath stringByAppendingPathComponent:path];
                NSString* destPath = [flowPath stringByAppendingPathComponent:path];
                NSError *copyError;
                [fm copyItemAtPath:srcPath toPath:destPath error:&copyError];
                if (copyError) {
                    NSError* underlying = [[copyError userInfo] valueForKey:NSUnderlyingErrorKey];
                    if (underlying && [underlying code] != 17) {
                        NSLog(@"Can't merge flow %@:\t %@", path, [copyError userInfo]);
                        
                    }
                }
            }
        }
    }
}


+ (BOOL)checkForAndCreateFolder:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDirectory = NO;
    BOOL exists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
    if (exists && isDirectory) {
        return YES;
    } else if(exists && !isDirectory) {
        NSLog(@"Path exists but isn't a directory!: %@", path);
        return NO;
    }else {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            return  YES;
        } else {
            NSLog(@"Can't create directory %@. Error: %@", path, [error userInfo]);
            return NO;
        }
    }
}

@end
