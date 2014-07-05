//
//  CompilerSettingsViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompilerSettingsViewController.h"
#import "CompileSetting.h"
#import "ProjectModel.h"
#import "CompilerPreferencesViewController.h"

@interface CompilerSettingsViewController ()

@end

@implementation CompilerSettingsViewController

    - (id)init
    {
        self = [super initWithNibName:@"CompilerSettingsView" bundle:nil];
        if (self) {
            context = [NSManagedObjectContext new];
            context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
            self.liveCompilePrefs = [CompilerPreferencesViewController new];
            self.draftCompilePrefs = [CompilerPreferencesViewController new];
            self.finalCompilePrefs = [CompilerPreferencesViewController new];
        }
        return self;
    }

    - (void)loadView
    {
        [super loadView];
        self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
        self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
        self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
        [self.liveBox setContentView:self.liveCompilePrefs.view];
        [self.draftBox setContentView:self.draftCompilePrefs.view];
        [self.finalBox setContentView:self.finalCompilePrefs.view];
        
        [self.liveCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [self.draftCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [self.finalCompilePrefs addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        self.liveCompilePrefs.compiler = self.liveCompiler;
        self.draftCompilePrefs.compiler = self.draftCompiler;
        self.finalCompilePrefs.compiler = self.finalCompiler;
    }


    - (void)configureProjectModel:(ProjectModel *)project
    {
        if (self.hasLiveCompiler) {
            project.liveCompiler = [self.liveCompiler copy];
            project.hasLiveCompiler = YES;
        }
        if (self.hasFinalCompiler) {
            project.finalCompiler = [self.finalCompiler copy];
            project.hasFinalCompiler = YES;
        }
        if (self.hasDraftCompiler) {
            project.draftCompiler = [self.draftCompiler copy];
            project.hasDraftCompiler = YES;
        }
    }

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.liveCompilePrefs) {
        self.hasLiveCompiler = self.liveCompilePrefs.enabled;
    } else if (object == self.draftCompilePrefs) {
        self.hasDraftCompiler = self.draftCompilePrefs.enabled;
    } else if (object == self.finalCompilePrefs) {
        self.hasFinalCompiler = self.finalCompilePrefs.enabled;
    }
}



- (void)dealloc {
    [self.liveCompilePrefs removeObserver:self forKeyPath:@"enabled"];
    [self.draftCompilePrefs removeObserver:self forKeyPath:@"enabled"];
    [self.finalCompilePrefs removeObserver:self forKeyPath:@"enabled"];
}
@end
