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
#import "TMTLog.h"
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

- (id)init {
    if (sharedInstance) {
        return sharedInstance;
    }
    self = [super init];
    DDLogError(@"Init");
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingDidChange:) name:NSApplicationDidUpdateNotification object:nil];
    }
    return self;
}

- (void)somethingDidChange:(NSNotification *)note {
    // ATTENTION: This method is called after every fucking message passed through the notification center. So it need's to be very fast!
    NSResponder *firstResponder = [[[NSApplication sharedApplication] keyWindow] firstResponder];
    if ([firstResponder respondsToSelector:@selector(firstResponderDelegate)]) {
        id<FirstResponderDelegate> del = [firstResponder performSelector:@selector(firstResponderDelegate)];
        if (![del isEqual:self.currentFirstResponderDelegate] && [del conformsToProtocol:@protocol(FirstResponderDelegate)]) {
            self.currentFirstResponderDelegate = del;
        }
    }
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
                              [NSArchiver archivedDataWithRootObject:[NSColor blueColor]], TMT_TEXDOC_LINK_COLOR,
                              
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
                              [NSNumber numberWithBool:NO], TMTLiveCompileBib,
                              [NSNumber numberWithBool:NO], TMTDraftCompileBib,
                              [NSNumber numberWithBool:YES], TMTFinalCompileBib,
                              [NSNumber numberWithBool:YES], TMTDocumentEnableLiveCompile,
                              [NSNumber numberWithBool:YES], TMTDocumentEnableLiveScrolling,
                              [NSNumber numberWithBool:YES], TMTDocumentAutoOpenOnExport,
                              [NSNumber numberWithInt:NSOnState], TMT_LEFT_TABVIEW_COLLAPSED,
                              [NSNumber numberWithInt:NSOnState], TMT_RIGHT_TABVIEW_COLLAPSED,
                              [NSNumber numberWithInt:TMTVertical], TMTViewOrderAppearance,
                              [NSNumber numberWithInt:1], TMTLiveCompileIterations,
                              [NSNumber numberWithInt:2], TMTDraftCompileIterations,
                              [NSNumber numberWithInt:3], TMTFinalCompileIterations,
                              [NSNumber numberWithInt:4], TMT_EDITOR_NUM_TAB_SPACES,
                              [NSNumber numberWithInt:4], TMT_EDITOR_NUM_TAB_SPACES,
                              [NSNumber numberWithInt:80], TMT_EDITOR_HARD_WRAP_AFTER,
                              [NSNumber numberWithInt:WARNING], TMTLatexLogLevelKey,
                              [NSNumber numberWithInt:SoftWrap], TMT_EDITOR_LINE_WRAP_MODE,
                              @"/usr/local/bin:/usr/bin:/usr/texbin", TMT_ENVIRONMENT_PATH,
                              @"/usr/texbin", TMT_PATH_TO_TEXBIN,
                              @"pdflatex.rb", TMTLiveCompileFlow,
                              @"pdflatex.rb", TMTDraftCompileFlow,
                              @"pdflatex.rb", TMTFinalCompileFlow,
                              @"",TMTLiveCompileArgs,
                              @"",TMTDraftCompileArgs,
                              @"",TMTFinalCompileArgs,
                              @"Source Code Pro", TMT_EDITOR_FONT_NAME,
                              [NSNumber numberWithFloat:12.0], TMT_EDITOR_FONT_SIZE,
                              [NSNumber numberWithBool:NO], TMT_EDITOR_FONT_ITALIC,
                              [NSNumber numberWithBool:NO], TMT_EDITOR_FONT_BOLD,
                              nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
}

+ (void)mergeCompileFlows {
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
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init]; [dict setObject:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions];
            for(NSString *path in files) {
                NSString* srcPath = [bundlePath stringByAppendingPathComponent:path];
                NSString* destPath = [flowPath stringByAppendingPathComponent:path];
                NSError *copyError;
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
    DDLogVerbose(@"ApplicationController dealloc");
}

@end
