//
//  LineNumberView.h
//  TeXtended
//
//  Created by Max Bannach on 26.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * This class displays line numbers and markers at the side of 
 * a NSScrollView.
 * It is a extention of the NSRulerView and thus can be added as
 * such to a NSScrollView. It will then automaticly update its model
 * when the text in the NSSCrollViews documentView changes and will 
 * automaticly scroll with the NSScrollViews content.
 *
 * Implementation of this class is inspired and based on
 * the NoodleLineNumberView from Paul Kim provided by Noodlesoft,
 * which stands under MIT-license.
 * See there [blog entry](http://www.noodlesoft.com/blog/2008/10/05/displaying-line-numbers-with-nstextview/)
 * for more information.
 *
 * @author Max Bannach
 */
@class MessageCollection;
@interface LineNumberView : NSRulerView {
    
    /** Font of the line numbers. */
    NSFont *numberFont;
    
    /** Style for the line numbers. */
    NSMutableParagraphStyle *numberStyle;
    
    /**
     * Format for the line numbers based on
     * [numberFont](numberFont), [numberStyle](numberStyle) 
     * and [textColor](textColor).
     */
    NSDictionary *attributesForNumbers;
    
    /**
     * Holds the start index for every line,
     * can be used in NSRange.
     */
    NSMutableArray  *lines;
    
    /**
     * Holds a key for every line that is anchored.
     */
    NSMutableDictionary *lineAnchors;
    
    /**
     * Holds a key for every line that has a warning.
     */
    NSMutableDictionary *lineWarnings;
    
    /**
     * Holds a key for every line that has a error.
     */
    NSMutableDictionary *lineErrors;
    
    /**
     * Image shown if a error appears.
     */
    NSImage *errorImage;
    
    /**
     * Image shown if a warning appears.
     */
    NSImage *warningImage;
    
    /**
     * Image shown if a info appears.
     */
    NSImage *infoImage;
}

/**
 * This class holds all infos, warnings, errors and so on.
 */
@property (weak) MessageCollection *messageCollection;

/** The background color of the whole ruler. */
@property (nonatomic, strong) NSColor *backgroundColor;

/** Color of the small line beside the numbers */
@property (nonatomic, strong) NSColor *lineColor;

/** Color for the border of even line numbers. */
@property (nonatomic, strong) NSColor *borderColorA;

/** Color for the border of odd line numbers */
@property (nonatomic, strong) NSColor *borderColorB;

/** Color of the line numbers. */
@property (nonatomic, strong) NSColor *textColor;

/** Color for of line anchors */
@property (nonatomic, strong) NSColor *anchorColor;

/** Color for border of line anchors */
@property (nonatomic, strong) NSColor *anchorBorderColor;

/**
 * Init the LineNumberView with a scrolView.
 * RulerView will then automaticly update, when the
 * content of the scrolLView changes.
 * @param aScrollView to show the line numbers in
 */
- (id)initWithScrollView:(NSScrollView *)aScrollView;

/**
 * Adds a anchor to the given line.
 * @param line to add a anchor to
 */
- (void) addAnchorToLine: (NSUInteger) line;

/**
 * Removes a anchor from the given line.
 * @param line to remove a anchor from
 */
- (void) removeAnchorFromLine: (NSUInteger) line;

/**
 * Tests if the given line has a anchor.
 * @param line the line to test
 * @return YES if the line has a anchor
 */
- (BOOL) hasAnchor: (NSUInteger) line;

/**
 * Tests if the given line has a wanring.
 * @param line the line to test
 * @return YES if the line has a warning
 */
- (BOOL) hasWarning: (NSUInteger) line;

/**
 * Tests if the given line has a error.
 * @param line the line to test
 * @return YES if the line has a error
 */
- (BOOL) hasError: (NSUInteger) line;

/**
 * Tests if the given line has a info.
 * @param line the line to test
 * @return YES if the line has a error
 */
- (BOOL) hasInfo: (NSUInteger) line;

/**
 * Returns a array that holds the linenumbers of all lines with a anchor.
 * @return NSArray with NSUIntegers for the linenumbers
 */
- (NSArray*) anchoredLines;

@end
