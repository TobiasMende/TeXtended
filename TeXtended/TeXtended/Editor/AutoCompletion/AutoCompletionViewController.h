//
//  AutoCompletionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 23.07.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AutoCompletionViewController : NSViewController <NSTableViewDataSource>
@property (strong) IBOutlet NSTableView *tableView;

@property (nonatomic) NSArray *content;

@end
