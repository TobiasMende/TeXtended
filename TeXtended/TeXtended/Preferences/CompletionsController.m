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


@interface CompletionsController()

/**
 Method for loading the completions and creating appropriate completion objects.
 
 The method tries to load the completions from the application support folder. If no completion lists where found it loads the default lists from the application bundle
 */
- (void) loadCompletions;

/** Loads command completions from a specific path
 @param path the path to load from
 */
- (void) loadCommandCompletionsFromPath:(NSString*) path;

/** Loads environment completions from a specific path
 @param path the path to load from
 */
- (void) loadEnvironmentCompletionsFromPath:(NSString* )path;

/**
 Scrolls a table view until the given row is visible
 @param rowIndex index of the row to scroll to
 @param view the table view to scroll
 */
- (void) scrollRowToVisible:(NSUInteger) rowIndex inTableView:(NSTableView*) view;

// From here: Only IBAction handling for specific buttons

- (void) removeItemFromCommands;
- (void) removeItemFromEnvironments;
- (void) addItemToEnvironments;
- (void) addItemToCommands;

// To here: IBAction handling for specific buttons

// Frome here: Only NSTableViewDataSource method handling

- (id) commandObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id) environmentObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void) commandSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void) environmentSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

// To here: NSTableViewDataSource method handling
@end
NSInteger commandTag = 1;
NSInteger environmentTag = 2;
CompletionsController *instance;
@implementation CompletionsController

- (id)init {
    if (instance) {
        return instance;
    }
    self = [super init];
    if (self) {
        [self loadCompletions];
        instance = self;
    }
    return self;
}

#pragma mark -
#pragma mark Loading & Saving

- (void) loadCompletions {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    NSString *commandPath, *envPath;
    if (applicationSupport) {
       commandPath = [applicationSupport stringByAppendingPathComponent:@"CommandCompletions.plist"];
        envPath = [applicationSupport stringByAppendingPathComponent:@"EnvironmentCompletions.plist"];
        if (![fm fileExistsAtPath:commandPath]) {
            commandPath = nil;
        }
        if (![fm fileExistsAtPath:envPath]) {
        envPath = nil;
        }
    }

if(!commandPath) {
    commandPath = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
}
if(!envPath) {
    envPath = [[NSBundle mainBundle] pathForResource:@"EnvironmentCompletions" ofType:@"plist"];
}
    
    [self loadCommandCompletionsFromPath:commandPath];
    [self loadEnvironmentCompletionsFromPath:envPath];
}


- (void)loadCommandCompletionsFromPath:(NSString *)path {
    NSArray *commandDicts = [NSArray arrayWithContentsOfFile:path];
    _commandCompletions = [[NSMutableDictionary alloc] initWithCapacity:commandDicts.count];
    commandKeys = [[NSMutableArray alloc] initWithCapacity:commandDicts.count];
    
    for(NSDictionary *d in commandDicts) {
        Completion *c = [[CommandCompletion alloc] initWithDictionary:d];
        [_commandCompletions setObject:c forKey:[c key]];
        [commandKeys addObject:[c key]];
    }
    [commandKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (void)loadEnvironmentCompletionsFromPath:(NSString *)path {
    NSArray *envDicts = [NSArray arrayWithContentsOfFile:path];
    _environmentCompletions = [[NSMutableDictionary alloc] initWithCapacity:envDicts.count];
    environmentKeys = [[NSMutableArray alloc] initWithCapacity:envDicts.count];
    
    for(NSDictionary *d in envDicts) {
        Completion *c = [[EnvironmentCompletion alloc] initWithDictionary:d];
        [_environmentCompletions setObject:c forKey:[c key]];
        [environmentKeys addObject:[c key]];
    }
    [environmentKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (void) saveCompletions {
    NSString *commandPath;// = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
    NSString *envPath;// = [[NSBundle mainBundle] pathForResource:@"EnvironmentCompletions" ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    if (applicationSupport) {
        commandPath = [applicationSupport stringByAppendingPathComponent:@"CommandCompletions.plist"];
        envPath = [applicationSupport stringByAppendingPathComponent:@"EnvironmentCompletions.plist"];
        if (![fm fileExistsAtPath:commandPath]) {
            [fm createFileAtPath:commandPath contents:nil attributes:nil];
        }
        if (![fm fileExistsAtPath:envPath]) {
           [fm createFileAtPath:envPath contents:nil attributes:nil];
        }
        // Storing Command Completions:
        NSMutableArray *commandSaving = [[NSMutableArray alloc] initWithCapacity:self.commandCompletions.count];
        for(CommandCompletion *c in [self.commandCompletions allValues]) {
            [commandSaving addObject:[c dictionaryRepresentation]];
        }
        [commandSaving writeToFile:commandPath atomically:YES];
        // Storing Environment Completions:
        NSMutableArray *envSaving = [[NSMutableArray alloc] initWithCapacity:self.commandCompletions.count];
        for(EnvironmentCompletion *c in [self.environmentCompletions allValues]) {
            [envSaving addObject:[c dictionaryRepresentation]];
        }
        [envSaving writeToFile:envPath atomically:YES];
    } else {
        NSLog(@"Can't store user completions");
    }
    
    
}

#pragma mark -
#pragma mark Table View Delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView.tag == commandTag ) {
        return self.commandCompletions.count;
    } else if(tableView.tag == environmentTag) {
        return self.environmentCompletions.count;
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == commandTag) {
        return [self commandObjectValueForTableColumn:tableColumn row:row];
    } else if(tableView.tag == environmentTag) {
        return [self environmentObjectValueForTableColumn:tableColumn row:row];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == commandTag) {
        [self commandSetObjectValue:object forTableColumn:tableColumn row:row];
    } else if(tableView.tag == environmentTag) {
        [self environmentSetObjectValue:object forTableColumn:tableColumn row:row];
    }
    [tableView reloadData];
}

- (id)commandObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = [commandKeys objectAtIndex:row];
    CommandCompletion *c = [self.commandCompletions objectForKey:key];
    return [c valueForKey:tableColumn.identifier];
    
}

- (id)environmentObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = [environmentKeys objectAtIndex:row];
    EnvironmentCompletion *c = [self.environmentCompletions objectForKey:key];
    return [c valueForKey:tableColumn.identifier];
}

- (void)commandSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
   NSString *key = [commandKeys objectAtIndex:row];
   CommandCompletion *c = [self.commandCompletions objectForKey:key];
    if ((!c.insertion && [object isEqualToString:@""])|| [c.insertion isEqualTo:object]) {
        return;
    }
    [self.commandCompletions removeObjectForKey:key];
    [c setValue:object forKey:tableColumn.identifier];
    [self.commandCompletions setObject:c forKey:[c key]];

    [commandKeys setObject:[c key] atIndexedSubscript:row];
    [commandKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSUInteger index = [commandKeys indexOfObject:[c key]];
    self.selectedCommandIndexes = [NSIndexSet indexSetWithIndex:index];
    [self scrollRowToVisible:index inTableView:self.commandsView];
    if (c.insertion && [c.insertion length] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCommandCompletionsDidChangeNotification object:self];
    }
}

- (void)environmentSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *key = [environmentKeys objectAtIndex:row];
    EnvironmentCompletion *c = [self.environmentCompletions objectForKey:key];
    if ((!c.insertion && [object isEqualToString:@""])|| [c.insertion isEqualTo:object]) {
        return;
    }
    [self.environmentCompletions removeObjectForKey:key];
    [c setValue:object forKey:tableColumn.identifier];
    [self.environmentCompletions setObject:c forKey:[c key]];
    [environmentKeys setObject:[c key] atIndexedSubscript:row];
    [environmentKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSUInteger index = [environmentKeys indexOfObject:[c key]];
    self.selectedEnvironmentIndexes = [NSIndexSet indexSetWithIndex:index];
    [self scrollRowToVisible:index inTableView:self.environmentView];
    if (c.insertion && [c.insertion length] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTEnvironmentCompletionsDidChangeNotification object:self];
    }
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
    NSArray *keys = [commandKeys objectsAtIndexes:self.selectedCommandIndexes];
    [self.commandCompletions removeObjectsForKeys:keys];
    [commandKeys removeObjectsInArray:keys];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCommandCompletionsDidChangeNotification object:self];
}

- (void)removeItemFromEnvironments {
    NSArray *keys = [environmentKeys objectsAtIndexes:self.selectedEnvironmentIndexes];
    [self.environmentCompletions removeObjectsForKeys:keys];
    [environmentKeys removeObjectsInArray:keys];
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
    [self loadEnvironmentCompletionsFromPath:path];
    [self.environmentView reloadData];
}

- (IBAction)resetCommandCompletions:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
    [self loadCommandCompletionsFromPath:path];
    [self.commandsView reloadData];
}

- (void)addItemToCommands {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *temporaryKey = [NSString stringWithFormat:@"%lf", timeStamp];
    [commandKeys addObject:temporaryKey];
    [self.commandCompletions setObject:[[CommandCompletion alloc] init] forKey:temporaryKey];
    [self.commandsView reloadData];
    [self scrollRowToVisible:self.commandCompletions.count-1 inTableView:self.commandsView];
    [self.commandsView editColumn:0 row:self.commandCompletions.count-1 withEvent:nil select:YES];
}

- (void)addItemToEnvironments {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *temporaryKey = [NSString stringWithFormat:@"%lf", timeStamp];
    [environmentKeys addObject:temporaryKey];
    [self.environmentCompletions setObject:[[EnvironmentCompletion alloc] init] forKey:temporaryKey];
    [self.environmentView reloadData];
    [self scrollRowToVisible:self.environmentCompletions.count-1 inTableView:self.environmentView];
    [self.environmentView editColumn:0 row:self.environmentCompletions.count-1 withEvent:nil select:YES];
}

@end
