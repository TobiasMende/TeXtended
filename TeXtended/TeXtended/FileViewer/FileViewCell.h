//
//  FileViewCell.h
//  TeXtended
//
//  Created by Tobias Hecht on 11.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kImageOriginXOffset     0//3
#define kImageOriginYOffset     0//1

#define kTextOriginXOffset      0//2
#define kTextOriginYOffset      0
#define kTextHeightAdjust       0

@interface FileViewCell : NSTextFieldCell <NSTextDelegate>

@property (readwrite, strong) NSImage *image;

@end
