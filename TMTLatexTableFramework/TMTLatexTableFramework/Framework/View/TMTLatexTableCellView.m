//
//  TMTLatexTableCellView.m
//  TMTLatexTableFramework
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableCellView.h"
#import "TMTLatexTableCellModel.h"

static const CGFloat INSET = 2.5;
static const CGFloat OUTER = 1;
static const CGFloat LINE_WIDTH = 1;
static const NSArray *OBSERVED_MODEL_KEYPATHS;

@interface TMTLatexTableCellView ()

- (void)drawBorders:(NSRect)dirtyRect;
- (void)removeModelObservers;
- (void)addModelObservers;
@end

@implementation TMTLatexTableCellView

+ (void)initialize {
    if ([self class] == [TMTLatexTableCellView class]) {
        OBSERVED_MODEL_KEYPATHS = @[@"backgroundColor", @"topBorder", @"bottomBorder", @"leftBorder", @"rightBorder"];
    }
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"model"]) {
        keys = [keys setByAddingObject:@"objectValue"];
    }
    return keys;
}

- (void)setObjectValue:(id)objectValue {
    [self removeModelObservers];
    super.objectValue = objectValue;
    [self addModelObservers];
}


- (BOOL)isFlipped {
    return YES;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    
    [super drawRect:dirtyRect];
    [NSBezierPath setDefaultLineWidth:LINE_WIDTH];
    if (self.model.backgroundColor) {
        [self.model.backgroundColor set];
        [NSBezierPath fillRect:dirtyRect];
    }
    [self drawBorders:dirtyRect];
    // Drawing code here.
}

- (void)drawBorders:(NSRect)dirtyRect {
    TMTLatexTableCellModel *m = self.model;

    NSRect bounds = self.bounds;
    bounds.origin.x += OUTER; bounds.origin.y += OUTER; bounds.size.width -= 2*OUTER;; bounds.size.height -= 2*OUTER;
    NSRect inner = NSMakeRect(bounds.origin.x+INSET, bounds.origin.y+INSET, bounds.size.width-2*INSET, bounds.size.height-2*INSET);
    
    NSPoint outerTopLeft = bounds.origin;
    NSPoint outerTopRight = NSMakePoint(NSMaxX(bounds), bounds.origin.y);
    NSPoint outerBottomLeft = NSMakePoint(bounds.origin.x, NSMaxY(bounds));
    NSPoint outerBottomRight = NSMakePoint(NSMaxX(bounds), NSMaxY(bounds));
    
    NSPoint innerTopLeft = outerTopLeft;
    NSPoint innerTopRight = outerTopRight;
    NSPoint innerBottomLeft = outerBottomLeft;
    NSPoint innerBottomRight = outerBottomRight;
    
    if (m.topBorder == DOUBLE) {
        innerTopLeft.y = inner.origin.y;
        innerTopRight.y = inner.origin.y;
    }
    if (m.bottomBorder == DOUBLE) {
        innerBottomLeft.y = NSMaxY(inner);
        innerBottomRight.y = NSMaxY(inner);
    }
    if (m.leftBorder == DOUBLE) {
        innerBottomLeft.x = inner.origin.x;
        innerTopLeft.x = inner.origin.x;
    }
    if (m.rightBorder == DOUBLE) {
        innerBottomRight.x = NSMaxX(inner);
        innerTopRight.x = NSMaxX(inner);
    }
    
    [[NSColor blackColor] set];
    if (m.topBorder != NONE) {
         [NSBezierPath strokeLineFromPoint:outerTopLeft toPoint:outerTopRight];
        if (m.topBorder == DOUBLE) {
            [NSBezierPath strokeLineFromPoint:innerTopLeft toPoint:innerTopRight];
        }
    }
    if (m.bottomBorder != NONE) {
         [NSBezierPath strokeLineFromPoint:outerBottomLeft toPoint:outerBottomRight];
        if (m.bottomBorder == DOUBLE) {
            [NSBezierPath strokeLineFromPoint:innerBottomLeft toPoint:innerBottomRight];
        }
    }
    if (m.leftBorder != NONE) {
        [NSBezierPath strokeLineFromPoint:outerTopLeft toPoint:outerBottomLeft];
        if (m.leftBorder == DOUBLE) {
            [NSBezierPath strokeLineFromPoint:innerTopLeft toPoint:innerBottomLeft];
        }
    }
    if (m.rightBorder != NONE) {
        [NSBezierPath strokeLineFromPoint:outerTopRight toPoint:outerBottomRight];
        if (m.rightBorder == DOUBLE) {
            [NSBezierPath strokeLineFromPoint:innerTopRight toPoint:innerBottomRight];
        }
    }
    
}


- (TMTLatexTableCellModel *)model {
    return self.objectValue;
}

# pragma mark - Key Value Observing

- (void)addModelObservers {
    if (self.objectValue) {
        for (NSString *key in OBSERVED_MODEL_KEYPATHS) {
            [self.objectValue addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

- (void)removeModelObservers {
    if (self.objectValue) {
        for (NSString *key in OBSERVED_MODEL_KEYPATHS) {
            [self.objectValue removeObserver:self forKeyPath:key];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.objectValue) {
        self.needsDisplay = YES;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self removeModelObservers];
}
@end
