//
//  NSAttributedString+Replace.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSAttributedString+Replace.h"
#import "EditorPlaceholder.h"
#import "EditorPlaceholderCell.h"
@implementation NSAttributedString (Replace)


- (NSString *)stringByReplacingPlaceholders {
    NSMutableString *string = [self.string mutableCopy];
    [self enumerateAttributesInRange:NSMakeRange(0, self.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if (attachment && [attachment isKindOfClass:[EditorPlaceholder class]]) {
            EditorPlaceholderCell *cell = (EditorPlaceholderCell *)attachment.attachmentCell;
            NSString *placeholder = [NSString stringWithFormat:@"@@%@@@", cell.attributedStringValue.string];
            [string replaceCharactersInRange:range
                                  withString:placeholder];
        }
    }];
    return string;
}
@end
