//
//  CompletionHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

@interface CompletionHandler : EditorService
/**
 @see [NSTextViewDelegate textView:completions:forPartialWordRange: indexOfSelectedItem:]
 */
- (NSArray*) completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;
/**
 @see [NSTextView completionsForPartialWordRange:indexOfSelectedItem:];
 */
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;
@end
