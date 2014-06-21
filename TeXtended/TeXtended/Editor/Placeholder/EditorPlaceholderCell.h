//
//  EditorPlaceholderCell.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditorPlaceholderCell : NSTextAttachmentCell

    - (BOOL)isSelectedInRect:(NSRect)cellFrame ofView:(NSView *)controlView;
@end
