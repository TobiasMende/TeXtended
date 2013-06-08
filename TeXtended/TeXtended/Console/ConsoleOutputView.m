//
//  ConsoleView.m
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleOutputView.h"
#import "Constants.h"

@implementation ConsoleOutputView
- (void)awakeFromNib {
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:NSUnarchiveFromDataTransformerName,NSValueTransformerNameBindingOption, nil];
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    [self bind:@"font" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT] options:option];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ConsoleOutputView dealloc");
#endif
}

@end
