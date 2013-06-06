//
//  SyntaxHighlighterStub.h
//  TeXtended
//
//  Created by Tobias Mende on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyntaxHighlighter.h"
#import "EditorService.h"

/**
 A syntax highlighter stub which only prints messages when methods are called.
 
 **Author:** Tobias Mende
 
 */
@interface SyntaxHighlighterStub : EditorService <SyntaxHighlighter>

@end
