//
//  ConsoleInputField.m
//  TeXtended
//
//  Created by Tobias Mende on 07.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleInputField.h"
#import "Constants.h"

@implementation ConsoleInputField

    - (id)initWithFrame:(NSRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            // Initialization code here.

        }

        return self;
    }

    - (void)awakeFromNib
    {
        NSDictionary *option = @{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName};
        [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
        [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    }

@end
