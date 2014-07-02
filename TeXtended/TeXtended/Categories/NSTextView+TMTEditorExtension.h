//
//  NSTextView+TMTEditorExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TMTEditorExtension)

- (NSAttributedString *)expandWhiteSpaces:(NSAttributedString *)string;
@end
