//
//  CompletionsController.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompletionsController : NSObject <NSTableViewDataSource> {
    NSMutableArray *commandKeys;
    NSMutableArray *environmentKeys;
}
@property (weak) IBOutlet NSTableView *environmentView;
@property (weak) IBOutlet NSTableView *commandsView;
@property (strong) NSMutableDictionary *commandCompletions;
@property (strong) NSMutableDictionary *environmentCompletions;
@property  (strong) NSIndexSet *selectedCommandIndexes;
@property  (strong) NSIndexSet *selectedEnvironmentIndexes;
- (IBAction)removeItem:(id)sender;
- (IBAction)addItem:(id)sender;
- (void) saveCompletions;
@end
