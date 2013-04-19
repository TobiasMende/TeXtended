//
//  CompletionHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

@interface CompletionHandler : EditorService





- (NSArray*) completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

- (void) complete;
- (BOOL) willHandleCompletionForPartialWordRange:(NSRange)charRange;
- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;
@end
