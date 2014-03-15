//
//  TMTMessageCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTMessageCellView.h"
#import "TrackingMessage.h"
#import "DocumentModel.h"

@implementation TMTMessageCellView

- (NSImage *)image {
    NSImage *image = [TrackingMessage imageForType:self.message.type];
    [image setFlipped:NO];
    return image;
}

- (NSString *)lineString {
    if (self.message.column > 0) {
        return [NSString stringWithFormat:@"%li:%li", self.message.line, self.message.column];
    } else{
        return [NSString stringWithFormat:@"%li", self.message.line];
    }
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
        
    } else if ([key isEqualToString:@"message"]){
        keys = [keys setByAddingObject:@"objectValue"];
    } else if ([key isEqualToString:@"isExternal"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"self.model", @"self.message.document"]];
    }
    return keys;
}


- (BOOL)isExternal {
    return !self.model;
}
@end
