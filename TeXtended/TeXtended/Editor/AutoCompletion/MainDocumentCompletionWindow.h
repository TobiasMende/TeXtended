//
//  MainDocumentCompletionWindow.h
//  TeXtended
//
//  Created by Tobias Hecht on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainDocumentCompletionWindow : NSWindowController <NSTableViewDataSource>

@property (nonatomic) NSArray* content;
@property NSTextView *parent;
@property IBOutlet NSTableView* tableView;

- (void)positionWindowWithContent:(NSArray *)content;

#pragma mark - Key Events
- (void) arrowDown;
- (void) arrowUp;
- (void) enter;

@end
