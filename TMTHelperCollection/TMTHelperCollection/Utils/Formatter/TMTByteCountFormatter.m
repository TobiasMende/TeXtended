//
//  TMTByteCountFormatter.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 09.06.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTByteCountFormatter.h"

@implementation TMTByteCountFormatter


- (NSString *)stringForObjectValue:(id)obj {
    if (![obj isKindOfClass:[NSNumber class]]) {
        return @"<<invalid type>>";
    }
    NSString *unit = @"B";
    CGFloat size = [obj doubleValue];
    if (size >= 1024) {
        unit = @"KB";
        size /= 1024;
    }
    if (size >= 1024) {
        unit = @"MB";
        size /= 1024;
    }
    if (size >= 1024) {
        unit = @"GB";
        size /= 1024;
    }
    if (size >= 1024) {
        unit = @"TB";
        size /= 1024;
    }
    
    return [NSString stringWithFormat:@"%li %@", (NSUInteger)(size+0.5), unit];
}
@end
