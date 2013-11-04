//
//  ConsoleWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ConsoleManager;
@interface ConsoleWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSBox *contentView;
@property NSMutableArray *consoleDatas;
@property NSMutableArray *consoleViews;

@property (weak) ConsoleManager *manager;
- (IBAction)unhideConsoles:(id)sender;

@end
