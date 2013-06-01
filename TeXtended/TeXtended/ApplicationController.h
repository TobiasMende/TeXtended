//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PreferencesController,DocumentCreationController, CompletionsController;
@interface ApplicationController : NSObject <NSApplicationDelegate> {
    PreferencesController *preferencesController;
    DocumentCreationController *documentCreationController;
}
- (IBAction)showPreferences:(id)sender;
- (CompletionsController*) completionsController;
+ (ApplicationController*) sharedApplicationController;
+ (NSString*) userApplicationSupportDirectoryPath;
+ (BOOL)checkForAndCreateFolder:(NSString* )path;
@end
