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
    self.liveCompiler = [CompileSetting defaultLiveCompileSettingIn:context];
    self.draftCompiler = [CompileSetting defaultDraftCompileSettingIn:context];
    self.finalCompiler = [CompileSetting defaultFinalCompileSettingIn:context];
}


- (void)configureProjectModel:(ProjectModel *)project {
    if (![self.liveCompiler isEqualTo:[CompileSetting defaultLiveCompileSettingIn:context]]) {
        project.liveCompiler = [self.liveCompiler copy:project.managedObjectContext];
    }
    if (![self.draftCompiler isEqualTo:[CompileSetting defaultDraftCompileSettingIn:context]]) {
        project.draftCompiler = [self.draftCompiler copy:project.managedObjectContext];
    }
    if (![self.finalCompiler isEqualTo:[CompileSetting defaultFinalCompileSettingIn:context]]) {
        project.finalCompiler = [self.finalCompiler copy:project.managedObjectContext];
    }
}
@end
