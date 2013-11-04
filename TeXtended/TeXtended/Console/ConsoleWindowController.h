//
//  ConsoleWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ConsoleManager, ConsoleViewController;
@interface ConsoleWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSBox *contentView;
@property IBOutlet ConsoleViewController *viewController;
@property NSMutableArray *consoleDatas;

@property (weak) ConsoleManager *manager;
- (IBAction)unhideConsoles:(id)sender;

@end
