//
//  EditorService.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"
#import "HighlightingTextView.h"
@implementation EditorService
- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super init];
    if (self) {
        view = tv;
    }
    return self;
}

- (void)dealloc {
}

@end
