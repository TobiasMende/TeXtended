//
//  LineNumberview.m
//  TeXtended
//
//  Created by Max Bannach on 26.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import "LineNumberView.h"

/* Size of the small line borders */
#define BORDER_SIZE 4.0

/* Sie of the line along the line numbers */
#define BORDER_LINE_SIZE 1.0

/* Distance of the line numbers to the line */
#define NUMBER_DISTANCE_TO_LINE 2

/** Distance that the number "howers" over the next one */
#define NUMBER_DISTANCE_TO_NEXTLINE 3.5

/* Minimum width of the ruler view */
#define START_THICKNESS 22.0

/** Height of symbols like anchors */
#define SYMBOL_HEIGHT 14.0

@interface LineNumberView (private)

/**
 * Called from init methods, will set internal variables.
 */
- (void) initVariables;

/**
 * Override the set client view method, so that the changes on the text view
 * will inform the LineNumber View.
 * @param aView the client view
 */
- (void)setClientView:(NSView *)aView;

/**
 * Finds the line number for a given statring index of a line.
 * This is needed, to find the first line that is visible.
 * @param index the line index
 * @param text to find the line number in
 * @return the line number
 *
 */
- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index inText:(NSString *)text;

/**
 * Calculate the thickness that the view needs to display all line numbers.
 * @return the thickness
 */
- (CGFloat)requiredThickness;

/**
 * Calculates the index of each line;
 * therefore also the number of lines will be calculates.
 * Result will be stored in lines.
 *
 * @warning This method scanns the hole text, call carefully.
 */
- (void) calculateLines;

/**
 * Calculate the heights of the lines starting at the given point,
 * until the first line who outraches the visible area.
 * @param startLine first line to look at
 * @return NSMutableArray of the hights
 * 
 * @note The calculation of the line heights is intensive, since the layout managet
 * has to line up all the glyphs for every line. Anyway, this method calculates only 
 * the heights for visibily lines and is therefore fast. It can and should be called 
 * more oft then [calculateLines](calculateLines:), likewise everytime the view has to be redrawn.
 */
- (NSMutableArray*) calculateLineHeights:(NSUInteger) startLine;

/**
 * Getter for the array with the line indices.
 * If the array is nil, this method will call the calculation function.
 * @return NSMutableArray the array of line indices
 * @see [method calculateLines]([calculateLines:])
 */
- (NSMutableArray*)lines;

/**
 * Draws a anchor for a selected line.
 * @param dirtyRect the rect where the anchor should be drawn in (rect of the rulerview)
 * @param visibleRect the currently visbile rect
 * @param lineHight the hight of the current line
 */
- (void) drawAnchorIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight;

/**
 * Draws a error for a selected line.
 * @param dirtyRect the rect where the anchor should be drawn in (rect of the rulerview)
 * @param visibleRect the currently visbile rect
 * @param lineHight the hight of the current line
 */
- (void) drawErrorIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight;

/**
 * Draws a warning for a selected line.
 * @param dirtyRect the rect where the anchor should be drawn in (rect of the rulerview)
 * @param visibleRect the currently visbile rect
 * @param lineHight the hight of the current line
 */
- (void) drawWarningIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getAnchorColor;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getAnchorBorderColor;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getWarningColor;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getWarningBorderColor;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getErrorColor;

/**
 * Since we cant init a NSColor with customs color, this method will return the default color until
 * the proeprty will be overriden.
 */
- (NSColor *) getErrorBorderColor;


@end

@implementation LineNumberView


- (id) initWithScrollView:(NSScrollView *)scrollView {
    if ((self = [super initWithScrollView:scrollView orientation:NSVerticalRuler]) != nil)
    {
        [self initVariables];
        [self observeScrolling:scrollView];
        [self setClientView:[scrollView documentView]];
    }
    return self;
}

- (void) initVariables {
    _backgroundColor    = [NSColor windowBackgroundColor];
    _lineColor          = [NSColor blackColor];
    _borderColorA       = [NSColor lightGrayColor];
    _borderColorB       = [NSColor grayColor];
    _textColor          = [NSColor darkGrayColor];
    
    lines = [[NSMutableArray alloc] init];
    numberFont = [NSFont fontWithName:@"SourceCodePro-Regular" size:10.0];
    numberStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [numberStyle setAlignment:NSRightTextAlignment];
    
    attributesForNumbers = [NSDictionary dictionaryWithObjectsAndKeys:
                            numberFont, NSFontAttributeName,
                            numberStyle, NSParagraphStyleAttributeName,
                            [self textColor], NSForegroundColorAttributeName,
                            nil];

    lineAnchors   = [[NSMutableDictionary alloc] init];
    lineWarnings  = [[NSMutableDictionary alloc] init];
    lineErrors    = [[NSMutableDictionary alloc] init];
    
    [self setRuleThickness:START_THICKNESS];
    [self calculateLines];
}

- (void)setClientView:(NSView *)aView
{
	
    if ((self.clientView != aView) && [self.clientView isKindOfClass:[NSTextView class]])
    {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:[(NSTextView *)self.clientView textStorage]];
    }
    [super setClientView:aView];
    if ((aView != nil) && [aView isKindOfClass:[NSTextView class]])
    {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextStorageDidProcessEditingNotification object:[(NSTextView *)aView textStorage]];
    }
}

/**
 * Will set the LineNumberView as observer for scrolling and reszise
 * changes of the given scrollView.
 * @param aScrollView the view to observe
 */
- (void) observeScrolling:(NSScrollView *) aScrollView {
    id	oldScrollView;
	
	oldScrollView = [self scrollView];
	
    if ((oldScrollView != aScrollView) && [oldScrollView isKindOfClass:[NSScrollView class]])
    {
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                              name:NSViewBoundsDidChangeNotification
                                              object:[aScrollView contentView]];
    }
    if ((aScrollView != nil) && [aScrollView isKindOfClass:[NSScrollView class]])
    {
		[[aScrollView contentView] setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(contentBoundsDidChange:)
                                              name:NSViewBoundsDidChangeNotification
                                              object:[aScrollView contentView]];
    }
}

/**
 * Called if the content of the scollView did change.
 * Will (recalculate and) redraw linenumbers.
 * @param notification send from the scrollView
 */
- (void)textDidChange:(NSNotification *)notification {
    lines = nil;
    [self setNeedsDisplay:YES];
}

/**
 * Called if the bounds of the scrollView did change (i.e. resize or scroll)-
 * @param notification send from the scrollView
 */
- (void)contentBoundsDidChange:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

- (NSMutableArray*)lines {
    if (lines == nil) {
        [self calculateLines];
    }
    return lines;
}

/**
 * Catch mouse events. Click on a line will add or remove a anchor to the line.
 * @param theEvent that was send
 */
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint					location;
	location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
    
    NSTextView *view                = [[self scrollView] documentView];
    NSRect visibleRect = [view visibleRect];
    NSLayoutManager	*manager        = [view layoutManager];
    NSTextContainer	*container      = [view textContainer];
    NSString *text                  = [view string];
    NSRange range, glyphRange;
    
    
    glyphRange = [manager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
    range = [manager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    range.length++;
    NSUInteger lineLabel = [self lineNumberForCharacterIndex:range.location inText:text];
    NSMutableArray *lineHights;
    lineHights = [self calculateLineHeights:lineLabel];
    
    
    /* calculate the clicked line */
    NSUInteger current = 0;
    for (int i = 0; i <[lineHights count]; i++) {
        
        if (location.y > [[lineHights objectAtIndex:i] unsignedIntegerValue] - visibleRect.origin.y) {
            current = lineLabel + i + 1;
        }
    }

    if (![self hasAnchor:current]) {
        [self addAnchorToLine:current];
    } else {
        [self removeAnchorFromLine:current];
    }
    
    [self setNeedsDisplay:YES];
}

- (void) addAnchorToLine:(NSUInteger)line {
    [lineAnchors setObject:[NSNumber numberWithInteger:1] forKey:[NSNumber numberWithInteger:line]];
}

- (void) addWarningToLine:(NSUInteger)line {
    [lineWarnings setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:line]];
}

- (void) addErrorToLine:(NSUInteger)line {
    [lineErrors setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:line]];
}

- (void) removeAnchorFromLine:(NSUInteger)line {
    [lineAnchors removeObjectForKey:[NSNumber numberWithInteger:line]];
}

- (void) removeWarningFromLine:(NSUInteger)line {
    [lineWarnings removeObjectForKey:[NSNumber numberWithInteger:line]];
}

- (void) removeErrorFromLine:(NSUInteger)line {
    [lineErrors removeObjectForKey:[NSNumber numberWithInteger:line]];
}

- (BOOL) hasAnchor:(NSUInteger)line {
    return [[lineAnchors objectForKey:[NSNumber numberWithInteger:line]] integerValue];
}

- (BOOL) hasWarning:(NSUInteger)line {
    return [[lineWarnings objectForKey:[NSNumber numberWithInteger:line]] integerValue];
}

- (BOOL) hasError:(NSUInteger)line {
    return [[lineErrors objectForKey:[NSNumber numberWithInteger:line]] integerValue];
}

- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index inText:(NSString *)text
{
    NSUInteger			left, right, mid, lineStart;
	NSMutableArray		*linesToTest;
    
	linesToTest = [self lines];
	
    // Binary search
    left = 0;
    right = [lines count];
    
    while ((right - left) > 1)
    {
        mid = (right + left) / 2;
        lineStart = [[linesToTest objectAtIndex:mid] unsignedIntValue];
        
        if (index < lineStart)
        {
            right = mid;
        }
        else if (index > lineStart)
        {
            left = mid;
        }
        else
        {
            return mid;
        }
    }
    return left;
}

- (CGFloat)requiredThickness
{
    NSUInteger			lineCount, digits, i;
    NSMutableString     *sampleString;
    NSSize              stringSize;
    
    lineCount = [[self lines] count];
    digits = (unsigned)log10(lineCount) + 1;
	sampleString = [NSMutableString string];
    for (i = 0; i < digits; i++)
    {
        // Use "8" since it is one of the fatter numbers. Anything but "1"
        // will probably be ok here. I could be pedantic and actually find the fattest
		// number for the current font but nah.
        [sampleString appendString:@"8"];
    }
    
    stringSize = [sampleString sizeWithAttributes:self->attributesForNumbers];
    
	// Round up the value. There is a bug on 10.4 where the display gets all wonky when scrolling if you don't
	// return an integral value here.
    return ceilf(MAX(START_THICKNESS, stringSize.width + 2*BORDER_SIZE + BORDER_LINE_SIZE));
}

- (void) calculateLines {
    
    lines = [[NSMutableArray alloc] init];
    NSTextView *view = [self.scrollView documentView];
    NSString *text = [view string];
    float index = 0;
    
    do {
        [lines addObject:[NSNumber numberWithUnsignedInteger:index]];
        index = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
    } while (index < [text length]);
    
    /* there is a problem, if the text ends withs a empty line */
    NSUInteger lineEnd, contentEnd;
    [text getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[lines lastObject] unsignedIntegerValue] , 0)];
    
    if (contentEnd < lineEnd)
    {
        [lines addObject:[NSNumber numberWithUnsignedInteger:index]];
    }

    CGFloat oldThickness, newThickness;
    oldThickness = [self ruleThickness];
    newThickness = [self requiredThickness];
    if (fabs(oldThickness - newThickness) > 1)
    {
        NSInvocation			*invocation;
        
        // Not a good idea to resize the view during calculations (which can happen during
        // display). Do a delayed perform (using NSInvocation since arg is a float).
        invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(setRuleThickness:)]];
        [invocation setSelector:@selector(setRuleThickness:)];
        [invocation setTarget:self];
        [invocation setArgument:&newThickness atIndex:2];
        
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.0];
    }
    
}

- (NSMutableArray*) calculateLineHeights:(NSUInteger) startLine {
    NSMutableArray *heights         = [[NSMutableArray alloc] init];
    NSMutableArray *currentLines    = [self lines];
    NSTextView *view                = [[self scrollView] documentView];
    NSLayoutManager	*manager        = [view layoutManager];
    NSTextContainer	*container      = [view textContainer];
    NSRect visibleRect              = [view visibleRect];
    NSRange nullRange;
    NSRect *rects;
    
    float height = 0; 
    NSUInteger index = 0, rectCount;
      
    for (NSUInteger line = startLine; height < (visibleRect.origin.y + visibleRect.size.height) && line < [lines count]; line++) {

        index = [[currentLines objectAtIndex:line] unsignedIntValue];
        
        rects = [manager rectArrayForCharacterRange:NSMakeRange(index, 0)
                             withinSelectedCharacterRange:nullRange
                                          inTextContainer:container
                                                rectCount:&rectCount];
        height = rects->origin.y;
        [heights addObject:[NSNumber numberWithFloat:height]];
    }
    
    // to draw the last line
    [heights addObject:[NSNumber numberWithFloat:rects->origin.y + visibleRect.size.height]];
    return heights;
}

- (void)drawRect:(NSRect)dirtyRect
{
    /* clear background */
    [[self backgroundColor] set]; //TODO background color as property
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)dirtyRect {
    NSRect visibleRect = [[[self scrollView] documentView] visibleRect ];
    
    /* draw small black line */
    [[self lineColor] set];
    NSRect rect = {dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE ,
        0,
        BORDER_LINE_SIZE,
        2*visibleRect.size.height,
    };
    NSRectFill(rect);
    
    NSTextView *view                = [[self scrollView] documentView];
    NSLayoutManager	*manager        = [view layoutManager];
    NSTextContainer	*container      = [view textContainer];
    NSString *text                  = [view string];
    NSRange range, glyphRange;

    /* 
     * Calculate the current line, this is needed from other views
     * and set here, because the lines are allready calculated.
     */
    //[self setCurrentLine:[self lineNumberForCharacterIndex:[view selectedRange].location inText:text]+1];
    
    glyphRange = [manager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
    range = [manager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    range.length++;
    NSUInteger lineLabel = [self lineNumberForCharacterIndex:range.location inText:text];
    NSMutableArray *lineHights;
    
    lineHights = [self calculateLineHeights:lineLabel];

    for (int i = 0; i < [lineHights count] - 1; i++) {

        /* draw rect for current line */
        NSRect rect = {dirtyRect.size.width - BORDER_SIZE ,
                       [[lineHights objectAtIndex:i] unsignedIntegerValue] - visibleRect.origin.y,
                       BORDER_SIZE,
                       [[lineHights objectAtIndex:i+1] unsignedIntegerValue] - [[lineHights objectAtIndex:i] unsignedIntegerValue]
                       };
        
        if ((lineLabel+i) % 2 == 0) {
            [[self borderColorA] set];
        } else {
            [[self borderColorB] set];
        }
        NSRectFill(rect);
        
        if ([self hasAnchor:lineLabel+i+1]) {
            [self drawAnchorIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
        }
        
        if ([self hasError:lineLabel+i+1]) {
            [self drawErrorIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
        }
        
        if ([self hasWarning:lineLabel+i+1]) {
            [self drawWarningIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
        }
        
        NSString *lineNumer = [NSString stringWithFormat:@"%li", lineLabel+i+1];
        NSRect rectFront = {0,
            [[lineHights objectAtIndex:i] unsignedIntegerValue] - visibleRect.origin.y - NUMBER_DISTANCE_TO_NEXTLINE,
            dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE - NUMBER_DISTANCE_TO_LINE,
            [[lineHights objectAtIndex:i+1] unsignedIntegerValue] - [[lineHights objectAtIndex:i] unsignedIntegerValue]
        };
        
        [lineNumer drawInRect:rectFront withAttributes:attributesForNumbers];
    }
}

- (void) drawAnchorIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    /* just move along the path */
    [line moveToPoint: NSMakePoint(0, lineHight - visibleRect.origin.y + 1)];
    [line lineToPoint: NSMakePoint(dirtyRect.size.width - 2*BORDER_SIZE, lineHight - visibleRect.origin.y + 1)];
    [line lineToPoint: NSMakePoint(dirtyRect.size.width, lineHight - visibleRect.origin.y + SYMBOL_HEIGHT/2)];
    [line lineToPoint: NSMakePoint(dirtyRect.size.width - 2*BORDER_SIZE, lineHight - visibleRect.origin.y + SYMBOL_HEIGHT - 1)];
    [line lineToPoint: NSMakePoint(0, lineHight - visibleRect.origin.y + SYMBOL_HEIGHT - 1)];
    
    [[self getAnchorColor] set];
    [line fill];
    [[self getAnchorBorderColor] set];
    [line stroke];
}

- (void) drawErrorIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    /* just draw a simple circle */
    [line appendBezierPathWithArcWithCenter: NSMakePoint((dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE)/2, lineHight- visibleRect.origin.y + SYMBOL_HEIGHT/2)
                                     radius: SYMBOL_HEIGHT/2 - 2
                                     startAngle: 0
                                     endAngle: 360];
    
    [[self getErrorColor] set];
    [line fill];
    [[self getErrorBorderColor] set];
    [line stroke];
}

- (void) drawWarningIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    /* draw a simple triangular */
    [line moveToPoint: NSMakePoint((dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE)/2, lineHight - visibleRect.origin.y + 2)];
    [line lineToPoint: NSMakePoint((dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE)/2 - SYMBOL_HEIGHT/2, lineHight - visibleRect.origin.y + SYMBOL_HEIGHT - 2)];
    [line lineToPoint: NSMakePoint((dirtyRect.size.width - BORDER_SIZE - BORDER_LINE_SIZE)/2 + SYMBOL_HEIGHT/2, lineHight - visibleRect.origin.y + SYMBOL_HEIGHT - 2)];
    [line closePath];
    
    [[self getWarningsColor] set];
    [line fill];
    [[self getWarningsBorderColor] set];
    [line stroke];
}


- (NSColor *) getAnchorColor {
    if ([self anchorColor] == nil) {
        return [NSColor colorWithCalibratedRed:0 green:0.29f blue:0.35f alpha:0.25f];
    }
    return [self anchorColor];
}

- (NSColor *) getAnchorBorderColor {
    if ([self anchorBorderColor] == nil) {
        return [NSColor colorWithCalibratedRed:0 green:0.29f blue:0.35f alpha:1.0f];
    }
    return [self anchorBorderColor];
}

- (NSColor *) getWarningsColor {
    if ([self warningColor] == nil) {
        return [NSColor colorWithCalibratedRed:0.98f green:0.733f blue:0.0f alpha:0.25f] ;
    }
    return [self warningColor];
}

- (NSColor *) getWarningsBorderColor {
    if ([self warningBorderColor] == nil) {
        return [NSColor colorWithCalibratedRed:0.98f green:0.733f blue:0.0f alpha:1.0f];
    }
    return [self warningBorderColor];
}

- (NSColor *) getErrorColor {
    if ([self errorColor] == nil) {
        return [NSColor colorWithCalibratedRed:0.89f green:0.125f blue:0.196f alpha:0.25f];
    }
    return [self errorColor];
}

- (NSColor *) getErrorBorderColor {
    if ([self errorBorderColor] == nil) {
        return [NSColor colorWithCalibratedRed:0.89f green:0.125f blue:0.196f alpha:1.0f];
    }
    return [self errorBorderColor];
}

- (NSArray*) anchoredLines {
    return [lineAnchors allValues];
}

- (NSArray*) linesWithErrors {
    return [lineErrors allValues];
}

- (NSArray*) linesWithWarnings {
    return [lineWarnings allValues];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"LineNumberView dealloc");
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
