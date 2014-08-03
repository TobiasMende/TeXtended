//
//  TMTLatexTableViewController.h
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TMTLatexTableModel, TMTLatexTableView;

@interface TMTLatexTableViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet TMTLatexTableView *tableView;

@property TMTLatexTableModel *model;

- (void)addRowBelow:(TMTLatexTableView*)sender;
- (void)addRowAbove:(TMTLatexTableView*)sender;
- (void)addColumnRight:(TMTLatexTableView*)sender;
- (void)addColumnLeft:(TMTLatexTableView*)sender;
@end
