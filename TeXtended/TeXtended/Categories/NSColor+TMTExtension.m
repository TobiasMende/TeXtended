//
//  NSColor+TMTExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 27.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSColor+TMTExtension.h"

@implementation NSColor (TMTExtension)

- (NSColor *)slightlyDarkerColor {
    return [NSColor colorWithCalibratedHue:self.hueComponent saturation:self.saturationComponent brightness:self.brightnessComponent-0.15 alpha:self.alphaComponent];
}

- (NSColor *)slightlyLighterColor {
    return [NSColor colorWithCalibratedHue:self.hueComponent saturation:self.saturationComponent brightness:self.brightnessComponent+0.15 alpha:self.alphaComponent];
}
@end
