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
#import "PageNumberViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ApplicationController.h"
#import "TMTNotificationCenter.h"

static const NSSet *KEYS_TO_UNBIND;

@interface ExtendedPdf ()
- (void)unbindAll;
@end

@implementation ExtendedPdf

+(void)initialize {
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"drawHorizotalLines",@"gridHorizontalSpacing",@"gridHorizontalOffset",@"drawVerticalLines",@"gridVerticalSpacing",@"gridVerticalOffset", @"gridColor", @"drawPageNumbers", @"gridUnit", @"pageAlpha", nil];
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
    [self setGridColor:[NSColor colorWithCalibratedRed:0.5f green:0.5f blue:0.5f alpha:0.25f]];
    [self setDrawPageNumbers:NO];
    
    // link horizontal line propertys to application shared
    [self bind:@"drawHorizotalLines" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTdrawHGrid"] options:nil];
    [self bind:@"gridHorizontalSpacing" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTHGridSpacing"] options:nil];
    [self bind:@"gridHorizontalOffset" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTHGridOffset"] options:nil];
    
    // link line color propertys to application shared
    [self bind:@"gridColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTGridColor"] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
    // link vertical line propertys to application shared
    [self bind:@"drawVerticalLines" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTdrawVGrid"] options:nil];
    [self bind:@"gridVerticalSpacing" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTVGridSpacing"] options:nil];
    [self bind:@"gridVerticalOffset" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTVGridOffset"] options:nil];
    
    // link page number propertys to application shared
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"TMTGridColor" options:0 context:NULL];
    [self bind:@"drawPageNumbers" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTPageNumbers"] options:nil];
    
    // link grid unit to application shared
    [self bind:@"gridUnit" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTGridUnit"] options:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"TMTGridUnit" options:0 context:NULL];
    
    // link preference of transparent pdf pages
    [self bind:@"pageAlpha" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:@"TMTPdfPageAlpha"] options:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"TMTPdfPageAlpha" options:0 context:NULL];
    
    // to init things at the first draw
    firstDraw = true;
    
    [self initSubViews];
}

/** Needed to redraw page if grid color changes or units */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay:YES];
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
        
        if ([[[controllsView view] animator] alphaValue] == 0) {
            [[[controllsView view] animator] setAlphaValue:0.9f];
        }
    } else {
        [[[controllsView view] animator] setAlphaValue:0.0f];
    }
}

- (void) beginGestureWithEvent:(NSEvent *)event {
    [super beginGestureWithEvent:event];
    if (!self.drawPageNumbers) return;
    
    if ([self.displayPageNumbersTimer isValid]) {
        [self.displayPageNumbersTimer invalidate];
    } else {
        [[[pageNumbers view] animator] setAlphaValue:0.9f];
    }
}

- (void) deactivatePageNumbers {
    [[[pageNumbers view] animator] setAlphaValue:0.0f];
}

- (void) endGestureWithEvent:(NSEvent *)event {
    [super endGestureWithEvent:event];
    if (!self.drawPageNumbers) return;
    
    if ([self.displayPageNumbersTimer isValid]) {
        [self.displayPageNumbersTimer invalidate];
    }
    
    [self setDisplayPageNumbersTimer:[NSTimer scheduledTimerWithTimeInterval:2
                                                                      target: self
                                                                      selector:@selector(deactivatePageNumbers)
                                                                      userInfo: nil
                                                                      repeats: NO]];
}

- (void) initSubViews {
    // add the controlls
    [self addControlls];
    [self addSubview:[controllsView view]];
    [self setAutoScales:YES];
    [[[controllsView view] animator] setAlphaValue:0.0f];
    
    // add page numbers
    pageNumbers = [[PageNumberViewController alloc] initInPdfView:self];
    [self addSubview:[pageNumbers view]];
    [[pageNumbers view] setAlphaValue:0.0f];
    [[pageNumbers view] setFrameOrigin:NSMakePoint(0, 0)];
}

- (NSImage *)flipImage:(NSImage *)image
{
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.width, existingSize.height);
    NSImage *flipedImage = [[NSImage alloc] initWithSize:newSize];
    
    [flipedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy:existingSize.width yBy:0];
    [t scaleXBy:-1 yBy:1];
    [t concat];
    
    [existingImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1.0];
    
    [flipedImage unlockFocus];
    
    return flipedImage;
}


- (void) drawPage:(PDFPage *) page
{
    

//    if (firstDraw) {
//        firstDraw = false;
//        [self initSubViews];
//    }
    
    [super drawPage:page];
    
    // draw the next or prev page
    if (self.pageAlpha) {
        NSInteger i = [self.document indexForPage:page];
        PDFPage* nextPage = nil;
        if (i % 2 != 0) {
            if( i > 0) {
                nextPage = [self.document pageAtIndex:i-1];
            }
        } else if (i < [self.document pageCount]-1) {
            nextPage = [self.document pageAtIndex:i+1];
        }
        if (nextPage) {
            NSData* data = [nextPage dataRepresentation];
            NSImage* img = [[NSImage alloc] initWithData:data];
            img = [self flipImage:img];
            
            [img drawInRect:[page boundsForBox:kPDFDisplayBoxMediaBox]
                   fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.2f];
        }
    }
    
    
//    [[controllsView view] setFrameOrigin:
//     NSMakePoint((int)self.frame.size.width/2  - controllsView.view.frame.size.width/2,
//                 (int)self.frame.size.height/6 - controllsView.view.frame.size.height/2
//                 )];
    [controllsView update:self];
    
//    [[pageNumbers view] setFrameOrigin:
//     NSMakePoint((int)self.frame.size.width  - 1.25 * pageNumbers.view.frame.size.width,
//                 (int)self.frame.size.height - 1.25 * pageNumbers.view.frame.size.height
//                 )];
    [pageNumbers update];
    
    /* get the size of the current page */
    NSSize size = [page boundsForBox:kPDFDisplayBoxMediaBox].size;
    
    /* eventualy draw a grid */
    if (self.drawHorizotalLines || self.drawVerticalLines) {
        [self drawGrid:size];
    }

}

- (void) drawGrid:(NSSize) size {
    int width = size.width;
    int height = size.height;
    int i = 0 ;
    float scaling = [self getScalingFactor];
    if (scaling < 1 && [self gridVerticalSpacing] == 1) scaling = 1;
    
    /* use the given color */
    [[self gridColor] setStroke];
    
    /* Create our drawing path */
    NSBezierPath* drawingPath = [NSBezierPath bezierPath];
        
    /* first the vertical lines */
    if (scaling < 1 && [self gridVerticalSpacing] == 1) scaling = 1;
    if (self.drawVerticalLines && [self gridVerticalSpacing] > 0) {
        for( i = [self gridVerticalOffset] ; i <= width ; i = i + [self gridVerticalSpacing]*scaling) {
            [drawingPath moveToPoint:NSMakePoint(i, 0)];
            [drawingPath lineToPoint:NSMakePoint(i, height)];
        }
    }
    
    /* then the horizontal lines */
    scaling = [self getScalingFactor];
    if (scaling < 1 && [self gridHorizontalSpacing] == 1) scaling = 1;
    if (self.drawHorizotalLines && [self gridHorizontalSpacing] > 0) {
        for( i = height - [self gridHorizontalOffset]; i > 0 ; i = i - [self gridHorizontalSpacing]*scaling) {
            [drawingPath moveToPoint:NSMakePoint(0,i)];
            [drawingPath lineToPoint:NSMakePoint(width, i)];
        }
    }
    
    /* actual draw it */
    [drawingPath stroke];
}

/** which unit should be used? */
- (float) getScalingFactor {

    if ([self.gridUnit isEqualToString:@"pt"]) {
        return 1;
    }
    if ([self.gridUnit isEqualToString:@"q"]) {
        return 0.709;
    }
    if ([self.gridUnit isEqualToString:@"mm"]) {
        return 2.835;
    }
    if ([self.gridUnit isEqualToString:@"cm"]) {
        return 28.35;
    }

    return 1;
}

- (void) addControlls {
    controllsView = [[ExtendedPdfControlls alloc] initWithExtendedPdf:self];
    [controllsView setPdfView:self];
    [[controllsView view] setFrameOrigin:NSMakePoint((int)self.frame.size.width/2 - controllsView.view.frame.size.width/2, (int)self.frame.size.height/6 - controllsView.view.frame.size.height/2)];
    [controllsView.theBox setBorderWidth:0];
    [controllsView.theBox setCornerRadius:10];
}
#pragma mark -
#pragma mark First Responder Chain

- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if (result && self.firstResponderDelegate) {
        [[TMTNotificationCenter centerForCompilable:self.firstResponderDelegate.model] postNotificationName:TMTFirstResponderDelegateChangeNotification object:nil userInfo:@{TMTFirstResponderKey: self.firstResponderDelegate}];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTFirstResponderDelegateChangeNotification object:nil userInfo:@{TMTFirstResponderKey: self.firstResponderDelegate}];
    }
    return result;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (aSelector == @selector(print:)) {
        return self.document != nil;
    }
    return [super respondsToSelector:aSelector] || (self.firstResponderDelegate && [self.firstResponderDelegate respondsToSelector:aSelector]);
    #pragma clang diagnostic pop
}
- (id)performSelector:(SEL)aSelector withObject:(id)object {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([super respondsToSelector:aSelector]) {
        [super performSelector:aSelector withObject:object];
    } else if(self.firstResponderDelegate && [self.firstResponderDelegate respondsToSelector:aSelector]) {
        [self.firstResponderDelegate performSelector:aSelector withObject:object];
    }
#pragma clang diagnostic pop
    return nil;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"TMTGridColor"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"TMTGridUnit"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"TMTPdfPageAlpha"];
    [self unbindAll];
    
}

- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
}

@end
