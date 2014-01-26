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
        default:
            self.textColor = [NSColor blackColor];
            break;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"%@", self.objectValue);
}

@end
