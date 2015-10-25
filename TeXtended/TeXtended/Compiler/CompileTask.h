//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class DocumentModel;
@protocol CompileTaskDelegate;

@interface CompileTask : NSObject

- (id)initWithDocument:(DocumentModel *)model forMode:(CompileMode)mode withDelegate:(id<CompileTaskDelegate>)delegate;

- (void)execute;
- (BOOL)isRunning;
- (void)abort;
- (BOOL)shouldOpenPDF;
- (NSString *)pdfPath;
@end