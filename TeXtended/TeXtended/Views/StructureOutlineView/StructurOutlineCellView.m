//
//  StructurOutlineCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructurOutlineCellView.h"
#import "OutlineElement.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "NSColor+TMTExtension.h"

@interface StructurOutlineCellView ()
- (void)updateTextColor;
@end
@implementation StructurOutlineCellView



- (OutlineElement *)element {
    return [self objectValue];
}

- (void)setObjectValue:(id)objectValue {
    if (super.objectValue) {
        [self unbind:@"textColor"];
    }
    super.objectValue = objectValue;
    if (super.objectValue) {
        [self updateTextColor];
    }
}

- (void)updateTextColor {
    NSDictionary *option = @{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName};
    
    switch (self.element.type) {
        case TODO:
            [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_COMMENT_COLOR] options:option];
            
            break;
        case SECTION:
        case SUBSECTION:
        case CHAPTER:
            [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_COMMAND_COLOR] options:option];
            break;
        case REF:
        case INCLUDE:
        case INPUT:
            [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_TEXDOC_LINK_COLOR] options:option];
            break;
        case LABEL:
            [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_INLINE_MATH_COLOR] options:option];
            break;
        default:
            self.textColor = [NSColor blackColor];
            break;
    }
}

- (NSColor *)textColor {
    switch (self.element.type) {
        case CHAPTER:
            return [_textColor slightlyDarkerColor];
        case SUBSECTION:
            return [_textColor slightlyLighterColor];
            
        default:
            return _textColor;
            break;
    }
}

- (NSImage *)image {
    NSImage *image = nil;
    switch (self.element.type) {
        case TODO:
            image = [NSImage imageNamed:@"hammer"];
            
            break;
        case SECTION:
        case SUBSECTION:
            image = [NSImage imageNamed:@"arrow-right-c"];
            break;
        case CHAPTER:
            image = [NSImage imageNamed:@"bookmark"];
            image.backgroundColor = self.textColor;
            break;
        case REF:
        case LABEL:
            image = [NSImage imageNamed:@"link"];
            break;
        case INCLUDE:
        case INPUT:
            image = [NSImage imageNamed:@"forward"];
            break;
            
        default:
            return nil;
            break;
    }
    
    NSImage *newImage = [image copy];
        [newImage lockFocus];
        [self.textColor set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [newImage unlockFocus];
    return newImage;
}


- (NSString *)toolTip {
    return [NSString stringWithFormat:@"%@: %@ (%@ [%li])", [OutlineElement localizedNameForType:self.element.type],self.element.info, self.element.document.texName, self.element.line];
}




+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"image"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"objectValue.type",@"textColor"]];
    } else if([key isEqualToString:@"toolTip"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"element.info", @"element.document.texName", @"element.line", @"element.type"]];
    } else if([key isEqualToString:@"element"]) {
        keys = [keys setByAddingObject:@"objectValue"];
    }
    return keys;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"%@", self.objectValue);
}

@end
