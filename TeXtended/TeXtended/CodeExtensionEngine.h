//
//  CodeExtensionEngine.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

@interface CodeExtensionEngine : EditorService
- (void)addLinksForRange:(NSRange) range;
- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex;
@end
