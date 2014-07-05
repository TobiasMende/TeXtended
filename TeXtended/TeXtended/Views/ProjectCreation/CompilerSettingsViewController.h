//
//  CompilerSettingsViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectCreationAssistantViewController.h"

@class CompileSetting,CompilerPreferencesViewController;

@interface CompilerSettingsViewController : NSViewController <ProjectCreationAssistantViewController>
    {
        NSManagedObjectContext *context;
    }
@property (strong) IBOutlet NSBox *liveBox;
@property (strong) IBOutlet NSBox *draftBox;
@property (strong) IBOutlet NSBox *finalBox;


@property CompilerPreferencesViewController *liveCompilePrefs;

@property CompilerPreferencesViewController *draftCompilePrefs;

@property CompilerPreferencesViewController *finalCompilePrefs;

    @property CompileSetting *liveCompiler;

    @property CompileSetting *draftCompiler;

    @property CompileSetting *finalCompiler;

    @property BOOL hasLiveCompiler;

    @property BOOL hasDraftCompiler;

    @property BOOL hasFinalCompiler;

@end
