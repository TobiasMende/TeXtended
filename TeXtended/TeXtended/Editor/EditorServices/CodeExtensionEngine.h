//
//  CodeExtensionEngine.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

@interface CodeExtensionEngine : EditorService

@property (strong,nonatomic) NSColor *texdocColor;
@property (nonatomic)BOOL shouldLinkTexdoc;
@property (nonatomic)BOOL shouldUnderlineTexdoc;

- (void)addLinksForRange:(NSRange) range;
- (void) addTexdocLinksForRange:(NSRange) range;
- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex;
@end
