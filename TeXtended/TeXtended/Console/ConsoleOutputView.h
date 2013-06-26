//
//  ConsoleView.h
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DocumentModel, ConsoleViewController;
/**
 An extended NSTextView for handling console specific layout of the text.
 
 **Author:** Tobias Mende
 
 */
@interface ConsoleOutputView : NSTextView
@property NSColor *linkColor;
@property BOOL shouldUnderlineLinks;

@property ConsoleViewController *controller;

/** The document model currently handled by the DocumentController */
@property DocumentModel *documentsModel;

/** The document model whichs texPath was compiled */
@property DocumentModel *compiledModel;

@end
