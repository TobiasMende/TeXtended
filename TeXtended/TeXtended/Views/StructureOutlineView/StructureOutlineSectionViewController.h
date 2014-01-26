//
//  StructureOutlineSectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentModel;
@interface StructureOutlineSectionViewController : NSViewController<NSOutlineViewDelegate>
@property DocumentModel *rootNode;
- (id) initWithRootNode:(DocumentModel *)model;
@end
