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
#import "TexdocPanelController.h"
#import "PathFactory.h"
#import "FirstResponderDelegate.h"
#import "ConsoleWindowController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "LatexSpellChecker.h"
#import "CompletionManager.h"
#import "TemplateController.h"
#import "Template.h"
#import <Quartz/Quartz.h>
#import "StartScreenWindowController.h"
#import "CompileFlowMerger.h"


@interface ApplicationController ()

+ (void)registerDefaults;

+ (NSDictionary *)defaults;

@end

@implementation ApplicationController {
    /** references to the controller which handels the preferences window. */
    PreferencesController *preferencesController;

    /** reference to the controller handling the creation and management of all documents in this application */
    DocumentCreationController *documentCreationController;

    /** reference to the texdoc panel controller handling the app wide texdoc support */
    TexdocPanelController *texdocPanelController;

    ConsoleWindowController *consoleWindowController;

    TemplateController *templateController;

    StartScreenWindowController *startScreenController;
}

+ (void)initialize {
    [self registerDefaults];
    [LatexSpellChecker sharedSpellChecker];
    [DocumentCreationController sharedDocumentController];
    [CompletionManager sharedInstance];
    [TMTLog customizeLogger];
    [[CompileFlowMerger new] mergeCompileFlows:NO];
}


+ (ApplicationController *)sharedApplicationController {
    static dispatch_once_t pred;
    static ApplicationController *applicationController = nil;

    dispatch_once(&pred, ^{
        applicationController = [[ApplicationController alloc] init];
    });
    return applicationController;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    documentCreationController = [[DocumentCreationController alloc] init];
    preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [preferencesController applicationWillTerminate:(NSNotification *) notification];
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
        NSArray * windows = [[NSApplication sharedApplication] orderedWindows];
        if (windows.count > 1) {
            [windows[1] makeKeyAndOrderFront:self];
        }
    } else {
        [consoleWindowController showWindow:self];
    }
}

- (void)showNewFromTemplate:(id)sender {
    templateController = [TemplateController new];
    templateController.loadHandler = ^(Template *template, BOOL success) {
        if (success) {
            NSSavePanel *panel = [NSSavePanel savePanel];
            panel.canCreateDirectories = YES;
            panel.title = NSLocalizedString(@"Choose Destination Folder", @"Choose Destination Folder");
            panel.prompt = NSLocalizedString(@"Choose", @"Choose");
            panel.message = NSLocalizedString(@"Please choose a folder to copy the template to.", "Choose a folder to copy the template to.");
            [panel beginWithCompletionHandler:^(NSInteger result) {
                if (result == NSFileHandlingPanelOKButton) {
                    NSString * path = panel.URL.path;
                    NSString * name = path.lastPathComponent.stringByDeletingPathExtension;
                    NSString * dir = path.stringByDeletingLastPathComponent;
                    NSError * error = nil;
                    Compilable *compilable = [template createInstanceWithName:name inDirectory:dir withError:&error];
                    if (error) {
                        [[NSAlert alertWithError:error] runModal];
                    } else {
                        error = nil;
                        [[DocumentCreationController sharedDocumentController] openDocumentForCompilable:compilable display:YES completionHandler:^(BOOL loadSuccess, NSError *loadError) {
                            if (loadError) {
                                [[NSAlert alertWithError:loadError] runModal];
                            }
                        }];

                    }
                }
            }];
        }
    };
    [templateController openLoadWindow];
}

+ (NSString *)userApplicationSupportDirectoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError * error;
    NSURL * applicationSupport = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (applicationSupport && !error) {
        NSString * directoryPath = [[applicationSupport path] stringByAppendingPathComponent:@"de.uni-luebeck.isp.tmtproject.TeXtended"];
        if ([PathFactory checkForAndCreateFolder:directoryPath]) {
            return directoryPath;
        }
    }
    return nil;
}

+ (void)registerDefaults {
    [NSColor colorWithCalibratedRed:36.0 / 255.0 green:80.0 / 255 blue:123.0 alpha:1];
    NSDictionary * defaults = [self defaults];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - QuickLook

- (IBAction)togglePreviewPanel:(id)previewPanel {
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
    else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

#pragma mark - Open Recent Menu Hack

- (void)updateRecentDocuments {

    NSMenuItem *openRecent = self.openRecentMenuItem;
    if (openRecent && openRecent.hasSubmenu) {
        // Creating a new OpenRecent menu with custom entries
        NSMenu *openRecentItems = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Open Recent", @"")];

        // Get the "Clear Recent" item (add it later)
        NSMenuItem *clearRecentItem = [openRecent.submenu.itemArray lastObject];
        [openRecent.submenu removeItem:clearRecentItem];

        if ([self addRecentSimpleDocumentsTo:openRecentItems].count > 0) {
            [openRecentItems addItem:[NSMenuItem separatorItem]];
        }

        // Add section for Project Documents:

        if ([self addRecentProjectDocumentsTo:openRecentItems].count > 0) {
            [openRecentItems addItem:[NSMenuItem separatorItem]];
        }

        // Add "Clear Recent" from old menu and set new submenu:
        [openRecentItems addItem:clearRecentItem];
        [openRecent setSubmenu:openRecentItems];

    }
}

- (NSArray *)addRecentSimpleDocumentsTo:(NSMenu *)menu {
    // Add section for Simple Documents:
    DocumentCreationController *dc = [DocumentCreationController sharedDocumentController];
    NSArray * recentSimpleDocumentURLs = dc.recentSimpleDocumentsURLs;
    NSImage *image = [NSImage imageNamed:@"texicon"];
    image.size = NSMakeSize(16, 16);
    for (NSURL *url in recentSimpleDocumentURLs) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[[url path] lastPathComponent] action:@selector(openRecent:) keyEquivalent:@""];
        item.representedObject = url;
        item.target = self;
        item.image = image;
        item.toolTip = url.path;
        [menu addItem:item];
    }
    return recentSimpleDocumentURLs;
}

- (NSArray *)addRecentProjectDocumentsTo:(NSMenu *)menu {
    DocumentCreationController *dc = [DocumentCreationController sharedDocumentController];
    NSArray * recentProjectDocumentURLs = dc.recentProjectDocumentsURLs;
    NSImage *image = [NSImage imageNamed:@"projecticon"];
    image.size = NSMakeSize(16, 16);
    for (NSURL *url in recentProjectDocumentURLs) {
        NSString * title = [[[url path] lastPathComponent] stringByDeletingPathExtension];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(openRecent:) keyEquivalent:@""];
        item.representedObject = url;
        item.target = self;
        item.image = image;
        [menu addItem:item];
    }
    return recentProjectDocumentURLs;
}

- (NSMenu *)fileMenu {
    return [[[[NSApplication sharedApplication] mainMenu] itemAtIndex:1] submenu];
}

- (NSMenuItem *)openRecentMenuItem {
    NSMenu *fileMenu = self.fileMenu;
    NSInteger openDocumentMenuItemIndex = [fileMenu indexOfItemWithTarget:nil andAction:@selector(openDocument:)];

    if (openDocumentMenuItemIndex >= 0) {
        // APPLE'S COMMENT: We'll presume it's the Open Recent menu item, because this is
        // APPLE'S COMMENT: the heuristic that NSDocumentController uses to add it to the
        // APPLE'S COMMENT: File menu
        return [fileMenu itemAtIndex:openDocumentMenuItemIndex + 1];
    }
    return nil;
}

- (void)openRecent:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSURL * url = [((NSMenuItem *) sender) representedObject];
        [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:nil];
    } else {
        NSBeep();
    }
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender {
    if (!startScreenController) {
        startScreenController = [StartScreenWindowController new];
    }
    [startScreenController showWindow:self];
    return YES;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return [[NSUserDefaults standardUserDefaults] boolForKey:TMTShouldShowStartScreen];
}

+ (NSDictionary *)defaults {
    return @{TMT_COMMAND_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.106 green:0.322 blue:0.482 alpha:1.0]],
            TMT_INLINE_MATH_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:158.0 / 255.0 green:30.0 / 255 blue:44.0 / 255.0 alpha:1.0]],
            TMT_COMMENT_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:85.0 / 255.0 green:169.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]],
            TMT_BRACKET_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0 / 255.0 green:198.0 / 255 blue:50.0 / 255.0 alpha:1.0]],
            TMT_ARGUMENT_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:171.0 / 255.0 green:198.0 / 255 blue:50.0 / 255.0 alpha:1.0]],
            TMT_CURRENT_LINE_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:236.0 / 255.0 green:218.0 / 255 blue:136.0 / 255.0 alpha:0.9]],
            TMT_CARRET_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:250.0 / 255.0 green:187.0 / 255 blue:0.0 / 255.0 alpha:0.8]],
            TMT_EDITOR_BACKGROUND_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],
            TMT_EDITOR_FOREGROUND_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor blackColor]],
            TMT_EDITOR_SELECTION_BACKGROUND_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor selectedTextBackgroundColor]],
            TMT_EDITOR_SELECTION_FOREGROUND_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],
            TMT_CURRENT_LINE_TEXT_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor selectedTextColor]],
            TMT_TEXDOC_LINK_COLOR : [NSArchiver archivedDataWithRootObject:[NSColor blueColor]],

            TMT_SHOULD_HIGHLIGHT_INLINE_MATH : @YES,
            TMT_SHOULD_HIGHLIGHT_COMMANDS : @YES,
            TMT_SHOULD_HIGHLIGHT_COMMENTS : @YES,
            TMT_SHOULD_HIGHLIGHT_BRACKETS : @YES,
            TMT_SHOULD_HIGHLIGHT_ARGUMENTS : @NO,
            TMT_SHOULD_HIGHLIGHT_CURRENT_LINE : @YES,
            TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS : @YES,
            TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS : @YES,
            TMT_SHOULD_HIGHLIGHT_CARRET : @NO,
            TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT : @YES,
            TMT_SHOULD_AUTO_INDENT_LINES : @YES,
            TMT_SHOULD_USE_SPACES_AS_TABS : @YES,
            TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS : @YES,
            TMT_SHOULD_COMPLETE_COMMANDS : @YES,
            TMT_SHOULD_COMPLETE_ENVIRONMENTS : @YES,
            TMTShouldShowStartScreen : @YES,
            TMTShouldCompleteCites : @YES,
            TMTShouldCompleteRefs : @YES,
            TMTAutomaticSpellingCorrection : @NO,
            TMT_SHOULD_LINK_TEXDOC : @YES,
            TMT_SHOULD_UNDERLINE_TEXDOC_LINKS : @YES,
            TMT_REPLACE_INVISIBLE_SPACES : @NO,
            TMT_REPLACE_INVISIBLE_LINEBREAKS : @NO,
            TMTLiveCompileBib : @NO,
            TMTDraftCompileBib : @NO,
            TMTFinalCompileBib : @YES,
            TMTDocumentEnableLiveCompile : @YES,
            TMTDocumentEnableLiveScrolling : @YES,
            TMTDocumentAutoOpenOnExport : @YES,
            TMT_LEFT_TABVIEW_COLLAPSED : @(NSOnState),
            TMT_RIGHT_TABVIEW_COLLAPSED : @(NSOnState),
            TMTViewOrderAppearance : @(TMTVertical),
            TMTLiveCompileIterations : @1,
            TMTDraftCompileIterations : @2,
            TMTFinalCompileIterations : @3,
            TMT_EDITOR_NUM_TAB_SPACES : @4,
            TMT_EDITOR_NUM_TAB_SPACES : @4,
            TMT_EDITOR_HARD_WRAP_AFTER : @80,
            TMTLatexLogLevelKey : @(WARNING),
            TMTLineSpacing : @0.0f,
            TMT_EDITOR_LINE_WRAP_MODE : @(SoftWrap),
            TMT_ENVIRONMENT_PATH : @"/usr/local/bin:/usr/bin:/Library/TeX/Distributions/Programs/texbin",
            TMT_PATH_TO_TEXBIN : @"/Library/TeX/Distributions/Programs/texbin",
            TMTLiveCompileFlow : @"pdflatex.rb",
            TMTDraftCompileFlow : @"pdflatex.rb",
            TMTFinalCompileFlow : @"pdflatex.rb",
            TMTLiveCompileArgs : @"",
            TMTDraftCompileArgs : @"",
            TMTFinalCompileArgs : @"",
            TMT_EDITOR_FONT_NAME : @"Source Code Pro",
            TMT_EDITOR_FONT_SIZE : @12.0f,
            TMT_EDITOR_FONT_ITALIC : @NO,
            TMT_EDITOR_FONT_BOLD : @NO,
            TMT_LOG_LEVEL_KEY : @(DDLogLevelWarning),
            TMTGridColor : [NSArchiver archivedDataWithRootObject:[NSColor grayColor]],
            TMTGridUnit : @"pt",
            TMTdrawHGrid : @NO,
            TMTdrawVGrid : @NO,
            TMTTemporaryFileExtensions : @[@"log", @"gz", @"synctex", @"aux", @"gz(busy)", @"bbl"],
            TMTHGridSpacing : @1,
            TMTVGridSpacing : @1,
            TMTHGridOffset : @0,
            TMTVGridOffset : @0,
            TMTPageNumbers : @YES,
            TMTPdfPageAlpha : @NO};
}

@end
