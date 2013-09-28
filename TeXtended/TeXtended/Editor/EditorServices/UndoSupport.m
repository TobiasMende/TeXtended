//
//  UndoSupport.m
//  TeXtended
//
//  Created by Tobias Mende on 25.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "UndoSupport.h"
#import "HighlightingTextView.h"
#import "TMTLog.h"

@implementation UndoSupport
- (void)insertText:(NSAttributedString *)insertion
           atIndex:(NSUInteger)index
    withActionName:(NSString *)name {
    if (index >= view.string.length) {
        [view.textStorage appendAttributedString:insertion];
    } else {
        [view.textStorage insertAttributedString:insertion atIndex:index];
    }
    [[view.undoManager prepareWithInvocationTarget:self] deleteTextInRange:[NSValue valueWithRange:NSMakeRange(index, insertion.length)] withActionName:name];
    [view.undoManager setActionName:name];
    [view didChangeText];
    
}

- (void)insertString:(NSString *)insertion atIndex:(NSUInteger)index withActionName:(NSString *)name {
    NSDictionary *attributes;
    if (view.textStorage.length > 0 &&  index < view.string.length) {
        // Do nothing
        attributes= [view.textStorage attributesAtIndex:index effectiveRange:NULL];
    } else if (view.textStorage.length > 0 &&  index-1 < view.string.length && index > 0){
         attributes= [view.textStorage attributesAtIndex:index-1 effectiveRange:NULL];
    } else {
        attributes = [[NSDictionary alloc] init];
    }
    NSAttributedString *final = [[NSAttributedString alloc]initWithString:insertion attributes:attributes];
    [self insertText:final atIndex:index withActionName:name];
}

- (void)deleteTextInRange:(NSValue *)rangeObject
           withActionName:(NSString *)name {
    NSRange range = [rangeObject rangeValue];
    NSAttributedString *insertion = [view.textStorage attributedSubstringFromRange:range];
    
    [view.textStorage deleteCharactersInRange:range];
    [[view.undoManager prepareWithInvocationTarget:self] insertText:insertion atIndex:range.location withActionName:name];
    [view.undoManager setActionName:name];
    [view didChangeText];
}

- (void)setString:(NSString *)string withActionName:(NSString *)name {
    [[view.undoManager prepareWithInvocationTarget:self] setString:[view.string copy] withActionName:name];
    [view.undoManager setActionName:name];
    [view setString:string];
}



- (void)dealloc {
    DDLogVerbose(@"UndoSupport dealloc");
}
@end