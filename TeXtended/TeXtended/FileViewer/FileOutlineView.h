//
//  FileOutLineView.h
//  TeXtended
//
//  Created by Tobias Hecht on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 The FileOutlineView makes the outline view within the FileView draggable.
 
 **Author:** Tobias Hecht
 
 */

@interface FileOutlineView : NSOutlineView <NSDraggingDestination>

@end
