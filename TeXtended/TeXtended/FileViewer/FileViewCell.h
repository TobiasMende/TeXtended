//
//  FileViewCell.h
//  TeXtended
//
//  Created by Tobias Hecht on 11.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 The FileViewCell is used to display the content of the FileViewModel in the FileOutlineView. It is able to display an image and to be editable in an intuitive behavior.
 
 **Author:** Tobias Hecht
 */

@interface FileViewCell : NSTextFieldCell <NSTextDelegate>

/** Image for the fileicon */
@property (readwrite, strong) NSImage *image;

@end
