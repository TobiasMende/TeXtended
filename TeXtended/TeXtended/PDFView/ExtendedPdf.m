//
//  ExtendedPdf.m
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import "ExtendedPdf.h"
#import "ExtendedPdfControlls.h"
#import "ExtendedPDFViewController.h"

static const NSSet *KEYS_TO_UNBIND;

@interface ExtendedPdf ()
- (void)unbindAll;
@end

@implementation ExtendedPdf

+(void)initialize {
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"drawHorizotalLines",@"gridHorizontalSpacing",@"gridHorizontalOffset",@"drawVerticalLines",@"gridVerticalSpacing",@"gridVerticalOffset", nil];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVariables];
    }
    
    return self;
}

- (void) initVariables {
    // init variables
    [self setGridHorizontalSpacing:1];
    [self setGridVerticalSpacing:1];
    [self setGridHorizontalOffset:0];
    [self setGridVerticalOffset:0];
    
    [self setGridColor:[NSColor lightGrayColor]];
    
    // set attributes for the page numbers
    pageNumberFont = [NSFont fontWithName:@"SourceCodePro-Regular" size:16.0];
    pageNumberStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [pageNumberStyle setAlignment:NSCenterTextAlignment];
    
    attributesForPageNumbers = [NSDictionary dictionaryWithObjectsAndKeys:
                                              pageNumberFont,
                                              NSFontAttributeName,
                                              pageNumberStyle,
                                              NSParagraphStyleAttributeName,
                                              [NSColor whiteColor],
                                              NSForegroundColorAttributeName, nil];
    
    // link propertys to application shared
    [self bind:@"drawHorizotalLines" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTdrawHGrid"] options:nil];
    [self bind:@"gridHorizontalSpacing" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTHGridSpacing"] options:nil];
    [self bind:@"gridHorizontalOffset" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTHGridOffset"] options:nil];
    
    [self bind:@"drawVerticalLines" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTdrawVGrid"] options:nil];
    [self bind:@"gridVerticalSpacing" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTVGridSpacing"] options:nil];
    [self bind:@"gridVerticalOffset" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTVGridOffset"] options:nil];
    
    // add the controlls
   [self addControlls];
   [self addSubview:[controllsView view]];
    [self setAutoScales:YES];
   [[controllsView view] setHidden:YES];
}

- (void) startBackwardSynctex:(id)sender {
    [self.controller startBackwardSynctex:sender];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSMenu *menu = [super menuForEvent:event];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Show Selection In Text", @"Show selection in text") action:@selector(startBackwardSynctex:) keyEquivalent:@"j"];
    [item setKeyEquivalentModifierMask:NSCommandKeyMask | NSShiftKeyMask];
    [menu insertItem:item atIndex:0];
    return menu;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint p2 = NSMakePoint((int)self.frame.size.width/2 - controllsView.view.frame.size.width/2, (int)self.frame.size.height/6 - controllsView.view.frame.size.height/2);
    
    if (p.x >= p2.x
        && p.x <= p2.x + controllsView.view.frame.size.width
        && p.y >= p2.y
        && p.y <= p2.y + controllsView.view.frame.size.height) {
        
        if ([[controllsView view] isHidden]) {
            [[controllsView view] setHidden:NO];
            [self setNeedsDisplay:YES];
        }
        
    } else {
        if ([[self subviews] count] > 1) {
            [[controllsView view] setHidden:YES];
            [self setNeedsDisplay:YES];
        }
    }
}

- (void) beginGestureWithEvent:(NSEvent *)event {
    [super beginGestureWithEvent:event];
    showPageNumbers = YES;
}

- (void) endGestureWithEvent:(NSEvent *)event {
    [super beginGestureWithEvent:event];
    showPageNumbers = NO;
}

- (void) drawPage:(PDFPage *) page
{
    [super drawPage:page];
    
    [[controllsView view] setFrameOrigin:NSMakePoint((int)self.frame.size.width/2  - controllsView.view.frame.size.width/2,
                                                     (int)self.frame.size.height/6 - controllsView.view.frame.size.height/2)];
    [controllsView update:self];
    
    /* get the size of the current page */
    NSSize size = [page boundsForBox:kPDFDisplayBoxMediaBox].size;
    
    /* eventualy draw a grid */
    if (self.drawHorizotalLines || self.drawVerticalLines) {
        [self drawGrid:size];
    }
    
    /** may draw a hud with the page numbers */
    if (showPageNumbers) {
        [self drawPageNumber:page];
    }
    
    /* draw pdf content */
    [page drawWithBox:[self displayBox]];
}

- (void) drawGrid:(NSSize) size {
    int width = size.width;
    int height = size.height;
    int i = 0 ;
    
    /* use the given color */
    [[self gridColor] setStroke];
    
    /* Create our drawing path */
    NSBezierPath* drawingPath = [NSBezierPath bezierPath];
        
    /* first the vertical lines */
    if (self.drawVerticalLines && [self gridVerticalSpacing] > 0) {
        for( i = [self gridVerticalOffset] ; i <= width ; i = i + [self gridVerticalSpacing]) {
            [drawingPath moveToPoint:NSMakePoint(i, 0)];
            [drawingPath lineToPoint:NSMakePoint(i, height)];
        }
    }
    
    /* then the horizontal lines */
    if (self.drawHorizotalLines && [self gridHorizontalSpacing] > 0) {
        for( i = height - [self gridHorizontalOffset]; i > 0 ; i= i - [self gridHorizontalSpacing]) {
            [drawingPath moveToPoint:NSMakePoint(0,i)];
            [drawingPath lineToPoint:NSMakePoint(width, i)];
        }
    }
    
    /* actual draw it */
    [drawingPath stroke];
}

/**
 * Draws the number of the current page and the total number of pages of the document.
 * @param page is the current page of the pdf
 */
- (void) drawPageNumber:(PDFPage *) page {
    NSSize size = [page boundsForBox:kPDFDisplayBoxMediaBox].size;
    
    // draw the hud
    NSRect rect = {size.width - 100, size.height - 149, 100, 29};
    [[NSColor darkGrayColor] set];
    NSRectFill(rect);
    
    NSRect line = {size.width - 100, size.height - 150, 100, 1};
    [[NSColor orangeColor] set];
    NSRectFill(line);
    
    // draw the line numbers to the hud
    NSString* pageNumber = [NSString stringWithFormat:@"%lu/%lu", [self.document indexForPage:page]+1, [page.document pageCount]];
    [pageNumber drawInRect:rect withAttributes:attributesForPageNumbers];
}

- (void) addControlls {
    controllsView = [[ExtendedPdfControlls alloc] initWithNibName:@"ExtendedPdfControlls" bundle:nil];
    [controllsView setPdfView:self];
    [[controllsView view] setFrameOrigin:NSMakePoint((int)self.frame.size.width/2 - controllsView.view.frame.size.width/2, (int)self.frame.size.height/6 - controllsView.view.frame.size.height/2)];
    [controllsView.theBox setBorderWidth:0];
    [controllsView.theBox setCornerRadius:10];
}
#pragma mark -
#pragma mark Responder Chain

- (BOOL)respondsToSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (aSelector == @selector(print:)) {
        return self.document != nil;
    }
    return [super respondsToSelector:aSelector];
    #pragma clang diagnostic pop
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ExtendedPDF dealloc");
     
#endif
    [self unbindAll];
    
}

- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
}

@end
