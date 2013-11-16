//
//  CompilerSettingsViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompilerSettingsViewController.h"
#import "CompileSetting.h"

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

@end
