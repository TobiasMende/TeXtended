//
//  ModelInfoWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/TMTLog.h>

#import "Compilable.h"
#import "CompilerPreferencesViewController.h"
#import "DocumentInfoViewController.h"
#import "DocumentModel.h"
#import "ModelInfoWindowController.h"
#import "ProjectInfoViewController.h"
#import "ProjectModel.h"

LOGGING_DEFAULT


@interface ModelInfoWindowController ()

    - (void)buildInfoView;

@end

@implementation ModelInfoWindowController




#pragma mark - Init & Dealloc

    - (void)dealloc
    {
        TMT_TRACE
        [self.liveCompilePrefs removeObserver:self forKeyPath:@"enabled"];
        [self.draftCompilePrefs removeObserver:self forKeyPath:@"enabled"];
        [self.finalCompilePrefs removeObserver:self forKeyPath:@"enabled"];
    }

    - (id)init
    {
        self = [super initWithWindowNibName:@"ModelInfoWindow"];
        if (self) {
            self.liveCompilePrefs = [CompilerPreferencesViewController new];
            self.draftCompilePrefs = [CompilerPreferencesViewController new];
            self.finalCompilePrefs = [CompilerPreferencesViewController new];
        }
        return self;
    }


#pragma mark - Window & View Lifecycle

    - (void)windowDidLoad
    {
        [super windowDidLoad];
        [self.liveCompilerView setContentView:self.liveCompilePrefs.view];
        [self.draftCompilerView setContentView:self.draftCompilePrefs.view];
        [self.finalCompilerView setContentView:self.finalCompilePrefs.view];
        [self.infoView setContentView:self.infoViewController.view];
        
        [self.liveCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [self.draftCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [self.finalCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    - (void)buildInfoView
    {
        if ([self.model isKindOfClass:[ProjectModel class]]) {
            self.infoViewController = [ProjectInfoViewController new];
        }
        else if ([self.model isKindOfClass:[DocumentModel class]]) {
            self.infoViewController = [DocumentInfoViewController new];
        }
        else {
            self.infoViewController = nil;
        }
        [self.infoViewController setModel:self.model];
        [self.infoView setContentView:self.infoViewController.view];
    }


#pragma mark - Getter & Setter

    - (void)setModel:(Compilable *)model
    {
        _model = model;
        if (self.model) {
            self.liveCompilePrefs.compiler = model.liveCompiler;
            self.draftCompilePrefs.compiler = model.draftCompiler;
            self.finalCompilePrefs.compiler = model.finalCompiler;
            
            NSDictionary *options = @{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValidatesImmediatelyBindingOption:@(YES)};
            [self.liveCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasLiveCompiler" options:options];
            [self.draftCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasDraftCompiler" options:options];
            [self.finalCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasFinalCompiler" options:options];
            [self buildInfoView];
        }
    }


#pragma mark - Actions

    - (IBAction)addBibFiles:(id)sender
    {
        NSOpenPanel *addPanel = [NSOpenPanel openPanel];

        addPanel.message = NSLocalizedString(@"Choose a bib document", @"chooseBibPath");
        addPanel.canCreateDirectories = YES;
        addPanel.canSelectHiddenExtension = YES;
        addPanel.allowsMultipleSelection = YES;
        addPanel.allowedFileTypes = @[@"bib"];

        NSURL *url = [NSURL fileURLWithPath:[self.model.path stringByDeletingLastPathComponent]];
        [addPanel setDirectoryURL:url];
        [addPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                for (NSURL *file in addPanel.URLs) {
                    [self.model addBibFileWithPath:file.path];
                }
            }
        }];
    }

    - (IBAction)addMainDocument:(id)sender
    {
        NSOpenPanel *addPanel = [NSOpenPanel openPanel];

        addPanel.message = NSLocalizedString(@"Choose a tex document", @"chooseTexPath");
        addPanel.canCreateDirectories = YES;
        addPanel.canSelectHiddenExtension = YES;
        addPanel.allowsMultipleSelection = YES;
        addPanel.allowedFileTypes = @[@"tex"];

        NSURL *url = [NSURL fileURLWithPath:[self.model.path stringByDeletingLastPathComponent]];
        [addPanel setDirectoryURL:url];
        [addPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                for (NSURL *file in addPanel.URLs) {
                    DocumentModel *m = [self.model modelForTexPath:file.path byCreating:YES];
                    [self.model addMainDocument:m];
                }
            }
        }];
    }

    - (BOOL)canRemoveMainDocument
    {
        return self.model.mainDocuments.count > self.mainDocumentsController.selectionIndexes.count && self.mainDocumentsController.selectionIndexes.count > 0;
    }


#pragma mark - Key Value Observing

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];

        if ([key isEqualToString:@"canRemoveMainDocument"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"mainDocumentsController.selectionIndexes.@count", @"mainDocumentsController.selectionIndexes"]];
        }
        return keys;
    }

    + (ModelInfoWindowController *)sharedInstance
    {
        static ModelInfoWindowController *_instance = nil;

        @synchronized (self) {
            if (_instance == nil) {
                _instance = [[self alloc] init];
            }
        }

        return _instance;
    }


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.liveCompilePrefs) {
        self.model.hasLiveCompiler = self.liveCompilePrefs.enabled;
    } else if (object == self.draftCompilePrefs) {
        self.model.hasDraftCompiler = self.draftCompilePrefs.enabled;
    } else if (object == self.finalCompilePrefs) {
        self.model.hasFinalCompiler = self.finalCompilePrefs.enabled;
    }
}

@end
