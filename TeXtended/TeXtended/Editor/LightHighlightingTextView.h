//
//  LightHighlightingTextView.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SyntaxHighlighter.h"

@interface LightHighlightingTextView : NSTextView {
    BOOL stopTextDidChangeNotifications;
    BOOL viewStateInitialized;
}

#pragma mark - Syntax Highlighting
/** The syntax highlighter */
@property (strong) id <SyntaxHighlighter> syntaxHighlighter;

- (void)updateSyntaxHighlighting;
- (NSRange)extendedVisibleRange;



#pragma mark - Getter & Setter
/**
 Getter for a line range for a given line index.
 
 @param index the lines 1-based index
 
 @return the range of the given line
 */
- (NSRange)rangeForLine:(NSUInteger)index;


#pragma mark - Commenting Text

/** Method for toggling the comment state for the selected lines
 
 @param sender the sender
 */
- (IBAction)toggleComment:(id)sender;

/**
 Method for adding a comment sign (%) at the beginning of every selected line
 
 @param sender the sender
 */
- (IBAction)commentSelection:(id)sender;

/**
 Method for deleting a comment sign (%) at the beginning of every selected line
 
 @param sender the sender
 */
- (IBAction)uncommentSelection:(id)sender;

#pragma mark - Moving Lines

/**
 Method can be called to delete the lines containing the selected text.
 
 @param sender the calling object
 */
- (IBAction)deleteLines:(id)sender;

/**
 Method moves the lines containing the selected text downwards
 
 @param sender the method caller
 */
- (IBAction)moveLinesDown:(id)sender;

/**
 Method moves the lines containing the selected text upwards
 
 @param sender the method caller
 */
- (IBAction)moveLinesUp:(id)sender;


@end
