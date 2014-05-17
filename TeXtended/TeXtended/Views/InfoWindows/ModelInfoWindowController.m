//
//  ModelInfoWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "ModelInfoWindowController.h"
#import "Compilable.h"
#import "CompilerPreferencesViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "DocumentModel.h"
#import "ProjectModel.h"
#import "ProjectInfoViewController.h"
#import "DocumentInfoViewController.h"
@interface ModelInfoWindowController ()
- (void)buildInfoView;
@end

@implementation ModelInfoWindowController

- (id)init{
    self = [super initWithWindowNibName:@"ModelInfoWindow"];
    if (self) {
        self.liveCompilePrefs = [CompilerPreferencesViewController new];
        self.draftCompilePrefs = [CompilerPreferencesViewController new];
        self.finalCompilePrefs = [CompilerPreferencesViewController new];
    }
    return self;
}

- (void)setModel:(Compilable *)model {
    _model = model;
    if (self.model) {
        self.liveCompilePrefs.compiler = model.liveCompiler;
        self.draftCompilePrefs.compiler = model.draftCompiler;
        self.finalCompilePrefs.compiler = model.finalCompiler;
        [self.liveCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasLiveCompiler" options:nil];
        [self.draftCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasDraftCompiler" options:nil];
        [self.finalCompilePrefs bind:@"enabled" toObject:self.model withKeyPath:@"hasFinalCompiler" options:nil];
        [self buildInfoView];
    }
}

- (void)buildInfoView {
    if ([self.model isKindOfClass:[ProjectModel class]]) {
        self.infoViewController = [ProjectInfoViewController new];
    } else if([self.model isKindOfClass:[DocumentModel class]]) {
        self.infoViewController = [DocumentInfoViewController new];
    } else {
        self.infoViewController = nil;
    }
    [self.infoViewController setModel:self.model];
    [self.infoView setContentView:self.infoViewController.view];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.liveCompilerView setContentView:self.liveCompilePrefs.view];
    [self.draftCompilerView setContentView:self.draftCompilePrefs.view];
    [self.finalCompilerView setContentView:self.finalCompilePrefs.view];
    [self.infoView setContentView:self.infoViewController.view];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void)dealloc {
    DDLogVerbose(@"dealloc");
}


- (IBAction)addMainDocument:(id)sender {
    NSOpenPanel *addPanel = [NSOpenPanel openPanel];
    addPanel.message = NSLocalizedString(@"Choose a tex document", @"chooseTexPath");
    addPanel.canCreateDirectories = YES;
    addPanel.canSelectHiddenExtension = YES;
    addPanel.allowsMultipleSelection = YES;
    addPanel.allowedFileTypes = @[@"tex"];
    
    NSURL *url= [NSURL fileURLWithPath:[self.model.path stringByDeletingLastPathComponent]];
    [addPanel setDirectoryURL:url];
    [addPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for(NSURL *file in addPanel.URLs) {
                DocumentModel *m = [self.model modelForTexPath:file.path byCreating:YES];
                [self.model addMainDocument:m];
            }
            [self.mainDocuments reloadData];
        }
    }];
    
}


- (BOOL)canRemoveMainDocument {
    return self.model.mainDocuments.count > self.mainDocumentsController.selectionIndexes.count && self.mainDocumentsController.selectionIndexes.count > 0;
}

- (IBAction)addBibFiles:(id)sender {
    NSOpenPanel *addPanel = [NSOpenPanel openPanel];
    addPanel.message = NSLocalizedString(@"Choose a bib document", @"chooseBibPath");
    addPanel.canCreateDirectories = YES;
    addPanel.canSelectHiddenExtension = YES;
    addPanel.allowsMultipleSelection = YES;
    addPanel.allowedFileTypes = @[@"bib"];
    
    NSURL *url= [NSURL fileURLWithPath:[self.model.path stringByDeletingLastPathComponent]];
    [addPanel setDirectoryURL:url];
    [addPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for(NSURL *file in addPanel.URLs) {
                [self.model addBibFileWithPath:file.path];
            }
            [self.bibFiles reloadData];
        }
        
    }];
}




+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"canRemoveMainDocument"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"model.mainDocuments.@count", @"mainDocumentsController.selectionIndexes.@count"]];
    }
    return keys;
}
@end
