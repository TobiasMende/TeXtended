//
//  ModelInfoWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelInfoViewController.h"
@class Compilable, CompilerPreferencesViewController;
@interface ModelInfoWindowController : NSWindowController

@property (nonatomic) Compilable *model;

@property (strong) IBOutlet NSBox *infoView;
@property CompilerPreferencesViewController *liveCompilePrefs;
@property CompilerPreferencesViewController *draftCompilePrefs;
@property CompilerPreferencesViewController *finalCompilePrefs;
@property NSViewController<ModelInfoViewController> *infoViewController;
@property (strong) IBOutlet NSBox *liveCompilerView;
@property (strong) IBOutlet NSBox *draftCompilerView;
@property (strong) IBOutlet NSBox *finalCompilerView;


- (id)init;

@end
