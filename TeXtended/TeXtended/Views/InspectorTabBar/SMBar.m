//
//  SMBar.m
//  InspectorTabBar
//
//  Created by Stephan Michels on 12.02.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMBar.h"

@implementation SMBar

- (BOOL)allowsVibrancy {
    return YES;
}

// using app and window notifications to change gradient for inactive windows, see
// http://code.google.com/p/tlanimatingoutlineview/source/browse/trunk/Classes/TLGradientView.m
    - (void)viewWillMoveToWindow:(NSWindow *)newWindow
    {
        [super viewWillMoveToWindow:newWindow];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        NSWindow *oldWindow = self.window;

        if (!oldWindow && newWindow) {
            [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
            [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidResignActiveNotification object:NSApp];
        } else if (oldWindow && !newWindow) {
            [center removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
            [center removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
        }

        if (oldWindow) {
            [center removeObserver:self name:NSWindowDidResignKeyNotification object:oldWindow];
            [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:oldWindow];
        }

        if (newWindow) {
            [center addObserver:self selector:@selector(windowDidChange:) name:NSWindowDidResignKeyNotification object:newWindow];
            [center addObserver:self selector:@selector(windowDidChange:) name:NSWindowDidBecomeKeyNotification object:newWindow];
        }
    }

#pragma mark - Drawing

    - (void)drawRect:(CGRect)rect
    {

        static NSColor *borderColor = nil;
        if ([[self window] isKeyWindow]) {
            borderColor = [NSColor colorWithCalibratedWhite:0.416 alpha:0.25f];
        } else {
            borderColor = [NSColor colorWithCalibratedWhite:0.651 alpha:0.25f];
        }
        
        [borderColor setStroke];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    }

// add noise pattern, see http://stackoverflow.com/questions/8766239
    - (void)drawNoisePattern
    {
        static CGImageRef noisePattern = nil;
        if (noisePattern == nil) {
            noisePattern = SMNoiseImageCreate(128, 128, 0.015);
        }

        [NSGraphicsContext saveGraphicsState];

        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositePlusLighter];
        CGRect noisePatternRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(noisePattern), CGImageGetHeight(noisePattern));
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextDrawTiledImage(context, noisePatternRect, noisePattern);

        [NSGraphicsContext restoreGraphicsState];
    }

    static CGImageRef SMNoiseImageCreate(NSUInteger width, NSUInteger height, CGFloat factor)
    {
        NSUInteger size = width * height;
        char *rgba = (char *) malloc(size);
        srand(124);
        for (NSUInteger i = 0 ; i < size ; i++) {
            rgba[i] = rand() % 256 * factor;
        }

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, kCGImageAlphaNone);
        CFRelease(colorSpace);
        free(rgba);

        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        CFRelease(bitmapContext);

        return image;
    }

    - (BOOL)isFlipped
    {
        return YES;
    }

#pragma mark - Notifications

    - (void)windowDidChange:(NSNotification *)notification
    {
        [self setNeedsDisplay:YES];
    }

@end
