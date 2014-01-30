//
//  StructureOutlineSectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentModel, TMTTableView;
@interface StructureOutlineSectionViewController : NSViewController<NSTableViewDelegate> {
}
@property (strong) IBOutlet TMTTableView *tableView;
@property DocumentModel *rootNode;
@property (nonatomic,assign) NSMutableArray *content;
- (id) initWithRootNode:(DocumentModel *)model;
@end
