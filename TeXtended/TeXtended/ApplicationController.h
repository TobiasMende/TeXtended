//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PreferencesController,DocumentController;
@interface ApplicationController : NSObject <NSApplicationDelegate> {
    PreferencesController *preferencesController;
    DocumentController *documentController;
}
- (IBAction)showPreferences:(id)sender;
+ (ApplicationController*) sharedApplicationController;
@property (strong) NSMutableArray* systemCommandCompletions;
@property (strong) NSMutableArray* systemEnvironmentCompletions;
@end
