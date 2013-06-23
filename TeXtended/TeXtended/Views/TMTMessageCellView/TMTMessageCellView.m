//
//  TMTMessageCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTMessageCellView.h"
#import "TrackingMessage.h"

@implementation TMTMessageCellView

- (NSImage *)image {
    //FIXME: return image;
    NSImage *image = [TrackingMessage imageForType:self.message.type];
    [image setFlipped:NO];
    return image;
}

- (NSString *)lineString {
    return [NSLocalizedString(@"Line", @"line") stringByAppendingFormat:@" %li", self.message.line];
}

- (TrackingMessage *)message {
    return self.objectValue;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"image"]) {
        keys = [keys setByAddingObject:@"objectValue"];
    } else if ([key isEqualToString:@"lineString"]){
         keys = [keys setByAddingObject:@"objectValue"];
    }
    return keys;
}
@end
