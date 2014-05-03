//
//  FileViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileViewController : NSViewController <NSOutlineViewDelegate>
@property (strong) IBOutlet NSTreeController *fileTree;
@property (nonatomic) NSString *path;
@property (assign,nonatomic) NSDocument *document;
@property NSMutableArray *contents;

- (void) updatePath;
- (void) buildTree;
@end
