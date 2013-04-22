//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PreferencesController,DocumentController, CompletionsController;
@interface ApplicationController : NSObject <NSApplicationDelegate> {
    PreferencesController *preferencesController;
    DocumentController *documentController;
}
- (IBAction)showPreferences:(id)sender;
- (CompletionsController*) completionsController;
+ (ApplicationController*) sharedApplicationController;
+ (NSString*) userApplicationSupportDirectoryPath;
@end
