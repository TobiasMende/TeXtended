//
//  UndoSupport.m
//  TeXtended
//
//  Created by Tobias Mende on 25.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "UndoSupport.h"
#import "HighlightingTextView.h"

@implementation UndoSupport
- (void)insertText:(NSAttributedString *)insertion
           atIndex:(NSUInteger)index
    withActionName:(NSString *)name {
   
    [view.textStorage insertAttributedString:insertion atIndex:index];
    [[view.undoManager prepareWithInvocationTarget:self] deleteTextInRange:[NSValue valueWithRange:NSMakeRange(index, insertion.length)] withActionName:name];
    [view.undoManager setActionName:name];
    
}

- (void)insertString:(NSString *)insertion atIndex:(NSUInteger)index withActionName:(NSString *)name {
    NSDictionary *attributes = [view.textStorage attributesAtIndex:index effectiveRange:NULL];
    NSAttributedString *final = [[NSAttributedString alloc]initWithString:insertion attributes:attributes];
    [self insertText:final atIndex:index withActionName:name];
}

- (void)deleteTextInRange:(NSValue *)rangeObject
           withActionName:(NSString *)name {
    NSRange range = [rangeObject rangeValue];
    NSString *insertion = [view.string substringWithRange:range];
    
    [view.textStorage deleteCharactersInRange:range];
    [[view.undoManager prepareWithInvocationTarget:self] insertString:insertion atIndex:range.location withActionName:name];
    [view.undoManager setActionName:name];
}
@end
