//
//  LineNumberview.m
//  TeXtended
//
//  Created by Max Bannach on 26.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import "LineNumberView.h"
#import "HighlightingTextView.h"
#import "MessageCollection.h"
#import "TrackingMessage.h"
#import "MessageViewController.h"

/* Size of the small line borders */
#define BORDER_SIZE 4.0

/* Sie of the line along the line numbers */
#define BORDER_LINE_SIZE 1.0

/* Distance of the line numbers to the line */
#define NUMBER_DISTANCE_TO_LINE 2

/** Distance that the number "howers" over the next one */
#define NUMBER_DISTANCE_TO_NEXTLINE 3.5

/* Minimum width of the ruler view */
#define START_THICKNESS 16.0

/** Height of symbols like anchors */
#define SYMBOL_SIZE 10.0

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
 * Draws a info for a selected line.
 * @param dirtyRect the rect where the anchor should be drawn in (rect of the rulerview)
 * @param visibleRect the currently visbile rect
 * @param lineHight the hight of the current line
 */
- (void) drawInfoIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight;

/**
 * Draws a debug for a selected line.
 * @param dirtyRect the rect where the anchor should be drawn in (rect of the rulerview)
 * @param visibleRect the currently visbile rect
 * @param lineHight the hight of the current line
 */
- (void) drawDebugIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight;

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
 * Calculates all messages for a given line.
 * @param line the line number
 * @return NSMutabelSet a set with the messages
 */
- (NSMutableSet*) messagesForLine:(NSUInteger)line;

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
    
    /* message controlling */
    [self addObserver:self
           forKeyPath:@"messageCollection"
              options: NSKeyValueObservingOptionInitial
              context:NULL];
    messageWindow = [[NSPopover alloc] init];
    [messageWindow setAnimates:YES];
    [messageWindow setBehavior:NSPopoverBehaviorTransient];
    
    /* load images */
    errorImage = [NSImage imageNamed:@"error.png"];
    warningImage = [NSImage imageNamed:@"warning.png"];
    infoImage = [NSImage imageNamed:@"info.png"];
    
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
 * Called if observed values did change.
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void*)context {
    [self setNeedsDisplay:YES];
}

/**
 * Called if the bounds of the scrollView did change (i.e. resize or scroll)-
 * @param notification send from the scrollView
 */
- (void)contentBoundsDidChange:(NSNotification *)notification {
    [messageWindow close];
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
    
    NSMutableSet* messages = [self messagesForLine:current];
    if ([messages count] > 0) {
        NSRect rec = NSMakeRect(4,
                                [[lineHights objectAtIndex:current-lineLabel-1] integerValue] - visibleRect.origin.y + 0.75 * SYMBOL_SIZE,
                                1,
                                1);
        
        MessageViewController *mvc = [[MessageViewController alloc] initWithTrackingMessages:messages];
        [messageWindow setContentViewController:mvc];
        
        [messageWindow showRelativeToRect:rec ofView:self.scrollView preferredEdge:NSMinXEdge];
    } else if (![self hasAnchor:current]) {
        [self addAnchorToLine:current];
    } else {
        [self removeAnchorFromLine:current];
    }
    
    [self setNeedsDisplay:YES];
}

- (void) addAnchorToLine:(NSUInteger)line {
    [lineAnchors setObject:[NSNumber numberWithInteger:1] forKey:[NSNumber numberWithInteger:line]];
}

- (void) removeAnchorFromLine:(NSUInteger)line {
    [lineAnchors removeObjectForKey:[NSNumber numberWithInteger:line]];
}

- (BOOL) hasAnchor:(NSUInteger)line {
    return [[lineAnchors objectForKey:[NSNumber numberWithInteger:line]] integerValue];
}

- (NSMutableSet*) messagesForLine:(NSUInteger)line {
    NSMutableSet *messages = [[NSMutableSet alloc] init];
    for (TrackingMessage *m in [self.messageCollection errorMessages]) {
        if (m.line == line) {
            [messages addObject:m];
        }
    }
    for (TrackingMessage *m in [self.messageCollection warningMessages]) {
        if (m.line == line) {
            [messages addObject:m];
        }
    }
    for (TrackingMessage *m in [self.messageCollection infoMessages]) {
        if (m.line == line) {
            [messages addObject:m];
        }
    }
    for (TrackingMessage *m in [self.messageCollection debugMessages]) {
        if (m.line == line) {
            [messages addObject:m];
        }
    }
    return messages;
}

- (BOOL) hasWarning:(NSUInteger)line {
    for (TrackingMessage *m in [self.messageCollection warningMessages]) {
        if (m.line == line) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) hasError:(NSUInteger)line {
    for (TrackingMessage *m in [self.messageCollection errorMessages]) {
        if (m.line == line) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) hasInfo:(NSUInteger)line {
    for (TrackingMessage *m in [self.messageCollection infoMessages]) {
        if (m.line == line) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) hasDebug:(NSUInteger)line {
    for (TrackingMessage *m in [self.messageCollection debugMessages]) {
        if (m.line == line) {
            return YES;
        }
    }
    
    return NO;
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
    return ceilf(MAX(START_THICKNESS, stringSize.width + 2*BORDER_SIZE + BORDER_LINE_SIZE)) + SYMBOL_SIZE;
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
    
    
    HighlightingTextView *view = [[self scrollView] documentView];
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
    
    
    /*
     * Calculate the current line and the first visible line, this is needed from other views
     * and set here, because the lines are allready calculated.
     */
    NSInteger currentLine = [self lineNumberForCharacterIndex:[view selectedRange].location inText:text]+1;
    if (view.currentRow != currentLine) {
        [view setCurrentRow:currentLine];
    }
    if (view.firstVisibleRow != lineLabel+1) {
        [view setFirstVisibleRow:lineLabel+1];
    }
    
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
        } else if ([self hasWarning:lineLabel+i+1]) {
            [self drawWarningIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
        } else if ([self hasInfo:lineLabel+i+1]) {
            [self drawInfoIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
        } else if ([self hasDebug:lineLabel+i+1]) {
            [self drawDebugIn:dirtyRect withVisibleRect:visibleRect forLineHigh:[[lineHights objectAtIndex:i] integerValue]];
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
    [line lineToPoint: NSMakePoint(dirtyRect.size.width, lineHight - visibleRect.origin.y + 0.75*SYMBOL_SIZE + 0.5)];
    [line lineToPoint: NSMakePoint(dirtyRect.size.width - 2*BORDER_SIZE, lineHight - visibleRect.origin.y + 1.5*SYMBOL_SIZE - 1)];
    [line lineToPoint: NSMakePoint(0, lineHight - visibleRect.origin.y + 1.5*SYMBOL_SIZE - 1)];
    
    [[self getAnchorColor] set];
    [line fill];
    [[self getAnchorBorderColor] set];
    [line stroke];
}

- (void) drawErrorIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSRect pos = NSMakeRect(0,
                            lineHight - visibleRect.origin.y + SYMBOL_SIZE/4,
                            SYMBOL_SIZE,
                            SYMBOL_SIZE);
    
    [errorImage setFlipped:YES];
    [errorImage drawInRect:pos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [errorImage setFlipped:NO];
}

- (void) drawWarningIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSRect pos = NSMakeRect(0,
                            lineHight - visibleRect.origin.y + SYMBOL_SIZE/4,
                            SYMBOL_SIZE,
                            SYMBOL_SIZE);
    
    [warningImage setFlipped:YES];
    [warningImage drawInRect:pos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [warningImage setFlipped:NO];
}

- (void) drawInfoIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSRect pos = NSMakeRect(0,
                            lineHight - visibleRect.origin.y + SYMBOL_SIZE/4,
                            SYMBOL_SIZE,
                            SYMBOL_SIZE);
    
    [infoImage setFlipped:YES];
    [infoImage drawInRect:pos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [infoImage setFlipped:NO];
}

- (void) drawDebugIn: (NSRect) dirtyRect withVisibleRect:(NSRect) visibleRect forLineHigh:(NSUInteger) lineHight {
    NSRect pos = NSMakeRect(0,
                            lineHight - visibleRect.origin.y + SYMBOL_SIZE/4,
                            SYMBOL_SIZE,
                            SYMBOL_SIZE);
    
    [infoImage setFlipped:YES];
    [infoImage drawInRect:pos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [infoImage setFlipped:NO];
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

- (NSArray*) anchoredLines {
    return [lineAnchors allValues];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"LineNumberView dealloc");
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"messageCollection"];
    [self unbind:@"messageCollection"];
}

@end
