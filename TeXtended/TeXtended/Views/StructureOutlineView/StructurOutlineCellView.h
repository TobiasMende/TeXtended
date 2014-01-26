//
//  StructurOutlineCellView.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OutlineElement;
@interface StructurOutlineCellView : NSTableCellView
@property NSColor *textColor;

- (OutlineElement *)element;
- (NSImage *)image;
@end
