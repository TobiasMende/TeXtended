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

@interface CompilerSettingsViewController ()

@end

@implementation CompilerSettingsViewController

- (id)init {
    self = [super initWithNibName:@"CompilerSettingsView" bundle:nil];
    if (self) {
        context = [NSManagedObjectContext new];
        context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
    self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
    self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
}


- (void)configureProjectModel:(ProjectModel *)project {
    if (self.hasLiveCompiler) {
        project.liveCompiler = [self.liveCompiler copy];
    }
    if (self.hasFinalCompiler) {
        project.finalCompiler = [self.finalCompiler copy];
    }
    if (self.hasDraftCompiler) {
        project.draftCompiler = [self.draftCompiler copy];
    }
}
@end
