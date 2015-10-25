//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CompileTask;

@protocol CompileTaskDelegate <NSObject>
- (void)compilationStarted:(CompileTask *)compileTask;
- (void)compilationFailed:(CompileTask *)compileTask;
- (void)compilationFinished:(CompileTask *)compileTask;
@end