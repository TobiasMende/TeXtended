//
//  CompletionsController.m
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionsController.h"
#import "CommandCompletion.h"
#import "EnvironmentCompletion.h"
#import "ApplicationController.h"
#import "Constants.h"
#import <TMTHelperCollection/TMTLog.h>
#import "CompletionManager.h"



@interface CompletionsController()


/**
 Scrolls a table view until the given row is visible
 @param rowIndex index of the row to scroll to
 @param view the table view to scroll
 */
- (void) scrollRowToVisible:(NSUInteger) rowIndex inTableView:(NSTableView*) view;

// From here: Only IBAction handling for specific buttons

- (void) removeItemFromCommands;
- (void) removeItemFromEnvironments;
- (void) removeItemFromDrops;
- (void) addItemToEnvironments;
- (void) addItemToCommands;
- (void) addItemToDrops;

// To here: IBAction handling for specific buttons

// Frome here: Only NSTableViewDataSource method handling

- (id) commandObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id) environmentObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id) dropObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void) commandSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void) environmentSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void) dropSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// To here: NSTableViewDataSource method handling
@end
NSInteger commandTag = 1;
NSInteger environmentTag = 2;
NSInteger dropTag = 3;
CompletionsController *instance;
@implementation CompletionsController

- (id)init {
    if (instance) {
        return instance;
    }
    self = [super init];
    if (self) {
        self.manager = [CompletionManager sharedInstance];
        instance = self;
    }
    return self;
}

+ (CompletionsController *)sharedInstance {
    if (!instance) {
        instance = [CompletionsController new];
    }
    return instance;
}



#pragma mark -
#pragma mark Table View Delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView.tag == commandTag ) {
        return self.manager.commandCompletions.count;
    } else if(tableView.tag == environmentTag) {
        return self.manager.environmentCompletions.count;
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == commandTag) {
        return [self commandObjectValueForTableColumn:tableColumn row:row];
    } else if(tableView.tag == environmentTag) {
        return [self environmentObjectValueForTableColumn:tableColumn row:row];
    } else if (tableView.tag == dropTag) {
        return [self dropObjectValueForTableColumn:tableColumn row:row];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == commandTag) {
        [self commandSetObjectValue:object forTableColumn:tableColumn row:row];
    } else if(tableView.tag == environmentTag) {
        [self environmentSetObjectValue:object forTableColumn:tableColumn row:row];
    } else if (tableView.tag == dropTag) {
        [self dropSetObjectValue:object forTableColumn:tableColumn row:row];
    }
    [tableView reloadData];
}

- (id)commandObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = (self.manager.commandKeys)[row];
    CommandCompletion *c = (self.manager.commandCompletions)[key];
    return [c valueForKey:tableColumn.identifier];
    
}

- (id)environmentObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = (self.manager.environmentKeys)[row];
    EnvironmentCompletion *c = (self.manager.environmentCompletions)[key];
    return [c valueForKey:tableColumn.identifier];
}

- (id)dropObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Not implemented yet.
    return nil;
}

- (void)commandSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
   NSString *key = (self.manager.commandKeys)[row];
   CommandCompletion *c = (self.manager.commandCompletions)[key];
    if ((!c.insertion && [object isEqualToString:@""])|| [c.insertion isEqualTo:object]) {
        return;
    }
    [self.manager.commandCompletions removeObjectForKey:key];
    [c setValue:object forKey:tableColumn.identifier];
    [self.manager setCommandCompletion:c forIndex:row];
    NSUInteger index = [self.manager.commandKeys indexOfObject:[c key]];
    self.selectedCommandIndexes = [NSIndexSet indexSetWithIndex:index];
    [self scrollRowToVisible:index inTableView:self.commandsView];
}

- (void)environmentSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = (self.manager.environmentKeys)[row];
    EnvironmentCompletion *c = (self.manager.environmentCompletions)[key];
    if ((!c.insertion && [object isEqualToString:@""])|| [c.insertion isEqualTo:object]) {
        return;
    }
    [self.manager.environmentCompletions removeObjectForKey:key];
    [c setValue:object forKey:tableColumn.identifier];
    [self.manager setEnvironmentCompletion:c forIndex:row];
    NSUInteger index = [self.manager.environmentKeys indexOfObject:[c key]];
    self.selectedEnvironmentIndexes = [NSIndexSet indexSetWithIndex:index];
    [self scrollRowToVisible:index inTableView:self.environmentView];
}

-(void)dropSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    //Not implemented yet.
}


-(void)scrollRowToVisible:(NSUInteger)rowIndex inTableView:(NSTableView *)view {
    NSRect rowRect = [view rectOfRow:rowIndex];
    NSRect viewRect = [[view superview] frame];
    NSPoint scrollOrigin = rowRect.origin;
    scrollOrigin.y = scrollOrigin.y + (rowRect.size.height - viewRect.size.height) / 2;
    if (scrollOrigin.y < 0) scrollOrigin.y = 0;
    [[[view superview] animator] setBoundsOrigin:scrollOrigin];
}

#pragma mark -
#pragma mark Actions

- (IBAction)removeItem:(id)sender {
    if (![sender isKindOfClass:[NSControl class]]) {
        return;
    }
    NSControl *c = (NSControl *)sender;
    if (c.tag == commandTag) {
        [self removeItemFromCommands];
        [self.commandsView reloadData];
    } else if(c.tag == environmentTag) {
        [self removeItemFromEnvironments];
        [self.environmentView reloadData];
    }
    
}

- (void)removeItemFromCommands {
    NSArray *keys = [self.manager.commandKeys objectsAtIndexes:self.selectedCommandIndexes];
    [self.manager removeCommandsForKeys:keys];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCommandCompletionsDidChangeNotification object:self];
}

- (void)removeItemFromEnvironments {
    NSArray *keys = [self.manager.environmentKeys objectsAtIndexes:self.selectedEnvironmentIndexes];
    [self.manager removeEnvironmentsForKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTEnvironmentCompletionsDidChangeNotification object:self];
}

- (IBAction)addItem:(id)sender {
    if (![sender isKindOfClass:[NSControl class]]) {
        return;
    }
    NSControl *c = (NSControl *)sender;
    if (c.tag == commandTag) {
        [self addItemToCommands];
    } else if(c.tag == environmentTag) {
        [self addItemToEnvironments];
    }
}

- (IBAction)resetEnvironmentCompletions:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EnvironmentCompletions" ofType:@"plist"];
    [self.manager loadEnvironmentCompletionsFromPath:path];
    [self.environmentView reloadData];
}

- (IBAction)resetCommandCompletions:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
    [self.manager loadCommandCompletionsFromPath:path];
    [self.commandsView reloadData];
}

-(IBAction)resetDropCompletions:(id)sender {
    // Not implemented yet.
}

- (void)addItemToCommands {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *temporaryKey = [NSString stringWithFormat:@"%lf", timeStamp];
    [self.manager addCommandCompletion:[CommandCompletion new] forKey:temporaryKey];
    [self.commandsView reloadData];
    [self scrollRowToVisible:self.manager.commandCompletions.count-1 inTableView:self.commandsView];
    [self.commandsView editColumn:0 row:self.manager.commandCompletions.count-1 withEvent:nil select:YES];
}

- (void)addItemToEnvironments {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *temporaryKey = [NSString stringWithFormat:@"%lf", timeStamp];
    [self.manager addEnvironmentCompletion:[EnvironmentCompletion new] forKey:temporaryKey];
    [self.environmentView reloadData];
    [self scrollRowToVisible:self.manager.environmentCompletions.count-1 inTableView:self.environmentView];
    [self.environmentView editColumn:0 row:self.manager.environmentCompletions.count-1 withEvent:nil select:YES];
}

- (void)addItemToDrops {
    // Not implemented yet.
}

- (IBAction)resetCommandCompletionRanking:(id)sender {
    for (NSString *key in self.manager.commandCompletions) {
        [(self.manager.commandCompletions)[key] setCounter:0];
    }
}

- (IBAction)resetEnvironmentCompletionRanking:(id)sender {
    for (NSString *key in self.manager.environmentCompletions) {
        [(self.manager.environmentCompletions)[key] setCounter:0];
    }
}

- (IBAction)resetDropCompletionRanking:(id)sender {
    // Not impllemented yet.
}

@end
