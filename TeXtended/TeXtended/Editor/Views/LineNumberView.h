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
}

/** The background color of the whole ruler. */
@property (nonatomic, assign) NSColor *backgroundColor;

/** Color of the small line beside the numbers */
@property (nonatomic, assign) NSColor *lineColor;

/** Color for the border of even line numbers. */
@property (nonatomic, assign) NSColor *borderColorA;

/** Color for the border of odd line numbers */
@property (nonatomic, assign) NSColor *borderColorB;

/** Color of the line numbers. */
@property (nonatomic, assign) NSColor *textColor;

/**
 * Init the LineNumberView with a scrolView.
 * RulerView will then automaticly update, when the
 * content of the scrolLView changes.
 * @param aScrollView to show the line numbers in
 */
- (id)initWithScrollView:(NSScrollView *)aScrollView;

@end
