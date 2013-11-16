//
//  CompilerSettingsViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CompileSetting;

@interface CompilerSettingsViewController : NSViewController

@property CompileSetting *liveCompiler;
@property CompileSetting *draftCompiler;
@property CompileSetting *finalCompiler;

@end
