//
//  FileViewCell.h
//  TeXtended
//
//  Created by Tobias Hecht on 11.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileViewCell : NSTextFieldCell <NSTextDelegate>

/** Image for the fileicon */
@property (readwrite, strong) NSImage *image;

@end
