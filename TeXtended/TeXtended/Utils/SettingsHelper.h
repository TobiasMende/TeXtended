//
// Created by Tobias Mende on 02.07.14.
// Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsHelper : NSObject

+ (SettingsHelper *) sharedInstance;


@property BOOL shouldUseSpacesAsTabs;
@property BOOL shouldAutoIndentLines;
@property NSUInteger numberOfSpacesForTab;
@end