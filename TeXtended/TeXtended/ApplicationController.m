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
#import "TexdocPanelController.h"
#import "PathFactory.h"
#import "FirstResponderDelegate.h"
#import "ConsoleWindowController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "LatexSpellChecker.h"

static ApplicationController *sharedInstance;


@interface ApplicationController ()

+ (void)registerDefaults;


@end

@implementation ApplicationController
+ (void)initialize {
    //Register default user defaults
    [self registerDefaults];
    [LatexSpellChecker sharedSpellChecker];
    // Merging compile flows
    [self mergeCompileFlows:NO];
}

- (id)init {
    self = [super init];
    if (self) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidChangeNotification:) name:TMTFirstResponderDelegateChangeNotification object:nil];
    }
    return self;
}

- (void)firstResponderDidChangeNotification:(NSNotification *)note {
    self.currentFirstResponderDelegate = (note.userInfo)[TMTFirstResponderKey];
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
    [TMTLog customizeLogger];
    
}



- (void)applicationWillTerminate:(NSNotification *)notification {
    [preferencesController applicationWillTerminate:(NSNotification *)notification];
}

- (CompletionsController *)completionsController {
    return [preferencesController completionsController];
}

- (IBAction)showTexdocPanel:(id)sender {
    if (!texdocPanelController) {
        texdocPanelController = [[TexdocPanelController alloc] init];
    }
    [texdocPanelController showWindow:self];
}

- (IBAction)showPreferences:(id)sender {
    if (!preferencesController) {
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [preferencesController showWindow:self];
}

- (void)showConsoles:(id)sender {
    if (!consoleWindowController) {
        consoleWindowController = [ConsoleWindowController new];
    }
    if ([consoleWindowController.window isKeyWindow]) {
        NSArray *windows = [[NSApplication sharedApplication] orderedWindows];
        if (windows.count > 1) {
            [windows[1] makeKeyAndOrderFront:self];
        }
    } else {
        [consoleWindowController showWindow:self];
    }
}


+ (NSString *)userApplicationSupportDirectoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSURL *applicationSupport = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (applicationSupport && !error) {
        NSString *directoryPath = [[applicationSupport path] stringByAppendingPathComponent:@"de.uni-luebeck.isp.tmtproject.TeXtended"];
        if ([PathFactory checkForAndCreateFolder:directoryPath]) {
            return directoryPath;
        }
    }
    return nil;
}

+ (void)registerDefaults {
    [NSColor colorWithCalibratedRed:36.0/255.0 green:80.0/255 blue:123.0 alpha:1];
    NSDictionary *defaults = @{TMT_COMMAND_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.106 green:0.322 blue:0.482 alpha:1.0]],
                              TMT_INLINE_MATH_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:158.0/255.0 green:30.0/255 blue:44.0/255.0 alpha:1.0]],
                              TMT_COMMENT_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:85.0/255.0 green:169.0/255.0 blue:219.0/255.0 alpha:1.0]],
                              TMT_BRACKET_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0/255.0 green:198.0/255 blue:50.0/255.0 alpha:1.0]],
                              TMT_ARGUMENT_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0/255.0 green:198.0/255 blue:50.0/255.0 alpha:1.0]],
                              TMT_CURRENT_LINE_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:236.0/255.0 green:218.0/255 blue:136.0/255.0 alpha:0.9]],
                              TMT_CARRET_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:250.0/255.0 green:187.0/255 blue:0.0/255.0 alpha:0.8]],
                              TMT_EDITOR_BACKGROUND_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],
                              TMT_EDITOR_FOREGROUND_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor blackColor]],
                              TMT_EDITOR_SELECTION_BACKGROUND_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor selectedTextBackgroundColor]],
                              TMT_EDITOR_SELECTION_FOREGROUND_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],
                              TMT_CURRENT_LINE_TEXT_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],
                              TMT_TEXDOC_LINK_COLOR: [NSArchiver archivedDataWithRootObject:[NSColor blueColor]],
                              
                              TMT_SHOULD_HIGHLIGHT_INLINE_MATH: @YES,
                              TMT_SHOULD_HIGHLIGHT_COMMANDS: @YES,
                              TMT_SHOULD_HIGHLIGHT_COMMENTS: @YES,
                              TMT_SHOULD_HIGHLIGHT_BRACKETS: @YES,
                              TMT_SHOULD_HIGHLIGHT_ARGUMENTS: @NO,
                              TMT_SHOULD_HIGHLIGHT_CURRENT_LINE: @YES,
                              TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS: @YES,
                              TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS: @YES,
                              TMT_SHOULD_HIGHLIGHT_CARRET: @NO,
                              TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT: @YES,
                              TMT_SHOULD_AUTO_INDENT_LINES: @YES,
                              TMT_SHOULD_USE_SPACES_AS_TABS: @YES,
                              TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS: @YES,
                              TMT_SHOULD_COMPLETE_COMMANDS: @YES,
                              TMT_SHOULD_COMPLETE_ENVIRONMENTS: @YES,
                               TMTShouldCompleteCites: @YES,
                              TMT_SHOULD_LINK_TEXDOC: @YES,
                              TMT_SHOULD_UNDERLINE_TEXDOC_LINKS: @YES,
                              TMT_REPLACE_INVISIBLE_SPACES: @NO,
                              TMT_REPLACE_INVISIBLE_LINEBREAKS: @NO,
                              TMTLiveCompileBib: @NO,
                              TMTDraftCompileBib: @NO,
                              TMTFinalCompileBib: @YES,
                              TMTDocumentEnableLiveCompile: @YES,
                              TMTDocumentEnableLiveScrolling: @YES,
                              TMTDocumentAutoOpenOnExport: @YES,
                              TMT_LEFT_TABVIEW_COLLAPSED: @(NSOnState),
                              TMT_RIGHT_TABVIEW_COLLAPSED: @(NSOnState),
                              TMTViewOrderAppearance: @(TMTVertical),
                              TMTLiveCompileIterations: @1,
                              TMTDraftCompileIterations: @2,
                              TMTFinalCompileIterations: @3,
                              TMT_EDITOR_NUM_TAB_SPACES: @4,
                              TMT_EDITOR_NUM_TAB_SPACES: @4,
                              TMT_EDITOR_HARD_WRAP_AFTER: @80,
                              TMTLatexLogLevelKey: @(WARNING),
                              TMTLineSpacing: @7.5f,
                              TMT_EDITOR_LINE_WRAP_MODE: @(SoftWrap),
                              TMT_ENVIRONMENT_PATH: @"/usr/local/bin:/usr/bin:/usr/texbin",
                              TMT_PATH_TO_TEXBIN: @"/usr/texbin",
                              TMTLiveCompileFlow: @"pdflatex.rb",
                              TMTDraftCompileFlow: @"pdflatex.rb",
                              TMTFinalCompileFlow: @"pdflatex.rb",
                              TMTLiveCompileArgs: @"",
                              TMTDraftCompileArgs: @"",
                              TMTFinalCompileArgs: @"",
                              TMT_EDITOR_FONT_NAME: @"Source Code Pro",
                              TMT_EDITOR_FONT_SIZE: @12.0f,
                              TMT_EDITOR_FONT_ITALIC: @NO,
                              TMT_EDITOR_FONT_BOLD: @NO,
                              TMTGridColor: [NSArchiver archivedDataWithRootObject:[NSColor grayColor]],
                              TMTGridUnit: @"pt",
                              TMTdrawHGrid: @NO,
                              TMTdrawVGrid: @NO,
                              TMTHGridSpacing: @1,
                              TMTVGridSpacing: @1,
                              TMTHGridOffset: @0,
                              TMTVGridOffset: @0,
                              TMTPageNumbers: @YES,
                              TMTPdfPageAlpha: @NO};
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
}

+ (void)mergeCompileFlows:(BOOL)force {
    NSString* flowPath = [CompileFlowHandler path];
    BOOL exists = [PathFactory checkForAndCreateFolder:flowPath];
    if (exists) {
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"CompileFlows" ofType:nil];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSError* error;
        NSArray *files = [fm contentsOfDirectoryAtPath:bundlePath error:&error];
        if (error) {
            DDLogError(@"Can't read compile flows from %@. Error: %@", bundlePath, [error userInfo]);
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init]; dict[NSFilePosixPermissions] = @511;
            for(NSString *path in files) {
                NSString* srcPath = [bundlePath stringByAppendingPathComponent:path];
                NSString* destPath = [flowPath stringByAppendingPathComponent:path];
                NSError *copyError;
                if(force && [fm fileExistsAtPath:destPath]) {
                    NSError *replaceError;
                    [fm removeItemAtPath:destPath error:&replaceError];
                    if (replaceError) {
                        DDLogError(@"Can't remove file %@: %@ (%li)", destPath, error.userInfo, error.code);
                    }
                }
                [fm copyItemAtPath:srcPath toPath:destPath error:&copyError];
                if (copyError) {
                    NSError* underlying = [[copyError userInfo] valueForKey:NSUnderlyingErrorKey];
                    if (underlying && [underlying code] != 17) {
                        DDLogError(@"Can't merge flow %@:\t %@", path, [copyError userInfo]);
                        
                    }
                } else {
                    [fm setAttributes:dict ofItemAtPath:destPath error:&error];
                    if (error) {
                        DDLogError(@"Error while setting permission: %@", [error userInfo]);
                    }
                }
            }
        }
    }
}




- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLogVerbose(@"dealloc");
}

@end
