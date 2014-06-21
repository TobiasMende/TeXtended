//
//  EditorPlaceholder.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorPlaceholder.h"
#import "EditorPlaceholderCell.h"

@implementation EditorPlaceholder

    - (id)initWithName:(NSString *)name
    {
        NSFileWrapper *fw = [[NSFileWrapper alloc] init];
        [fw setPreferredFilename:@"placeholder"];
        self = [super initWithFileWrapper:fw];
        if (self) {
            EditorPlaceholderCell *aCell = [[EditorPlaceholderCell alloc] initTextCell:name];
            [self setAttachmentCell:aCell];
        }

        return self;

    }

    + (NSAttributedString *)placeholderAsAttributedStringWithName:(NSString *)name
    {
        EditorPlaceholder *attachment = [[EditorPlaceholder alloc] initWithName:name];
        return [NSAttributedString attributedStringWithAttachment:attachment];
    }
@end
