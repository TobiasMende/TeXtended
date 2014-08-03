//
//  FirstResponderDelegate.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentModel.h"

@class TextViewController;
@protocol FirstResponderDelegate <NSObject>

    - (DocumentModel *)model;


@optional
    - (BOOL)canShowQuickPreviewWindow;

/* Do a draft compile */
    - (void)draftCompile:(id)sender;

/* Show export window */
    - (void)finalCompile:(id)sender;

/* Refresh live compile */
    - (void)liveCompile:(id)sender;

/* Save Document */
    - (void)saveDocument:(id)sender;


    - (BOOL)isLiveCompileEnabled;

    - (void)setLiveCompileEnabled:(BOOL)enable;

- (IBAction)showInformation:(id)sender;
- (IBAction)showProjectInformation:(id)sender;
- (void)textViewControllerDidLoadView:(TextViewController *)controller;
@end
