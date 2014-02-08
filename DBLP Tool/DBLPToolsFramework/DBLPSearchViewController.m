//
//  DBLPSearchViewController.m
//  DBLP Tool
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPSearchViewController.h"
#import "DBLPInterface.h"
#import "TMTBibTexEntry.h"
#import <TMTHelperCollection/TMTTableView.h>

@interface DBLPSearchViewController ()
- (void)abortDBLPSearch;
@end

@implementation DBLPSearchViewController

- (id)init {
    
    self = [super initWithNibName:@"DBLPSearchView" bundle:[NSBundle bundleForClass:[self class]]];
    interface = [[DBLPInterface alloc] initWithHandler:self];
    return self;
}

- (void)finishInitialization {
    [self.view.window makeFirstResponder:self.authorField];
    
}

- (void)loadView {
    [super loadView];
    self.publicationTable.enterAction = @selector(executeCitation:);
}


- (void)performDoubleClick {
    if ([self.publicationTable clickedRow] < 0) {
        return;
    }
    [self executeCitation:self];
}


- (void)finishedFetchingAuthors:(NSMutableDictionary *)authors {
    [self.authorsController setContent:authors];
    [self clickedAuthorTable:self];
    
    self.searchinAuthor = NO;
}

- (void)startedFetchingAuthors:(NSString *)authorName {
    self.searchinAuthor = YES;
}

- (void)failedFetchingAuthors:(NSError *)error {
    self.searchinAuthor = NO;
    if ([self.handler respondsToSelector:@selector(failedFetchingAuthors:)]) {
        [self.handler failedFetchingAuthors:error];
    }
    NSLog(@"Failed to fetch: %@", error.userInfo);
}


- (void)controlTextDidChange:(NSNotification *)obj {
    if (self.authorField.stringValue.length >= 2) {
        [self.publicationsController setContent:nil];
        [interface searchAuthor:self.authorField.stringValue];
        
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification.object isEqualTo:self.publicationTable]) {
        // Nothing to do ATM
    } else if([notification.object isEqualTo:self.authorTable]) {
        [self clickedAuthorTable:self];
    }
}


- (IBAction)clickedAuthorTable:(id)sender {
    NSUInteger row = [self.authorsController selectionIndex];
    NSString *urlpt;
    if (row < [self.authorsController.arrangedObjects count]) {
        urlpt = [(self.authorsController.arrangedObjects)[row] key];
    } else if ([self.authorsController.arrangedObjects count] > 0) {
        self.authorsController.selectionIndex = 0;
        urlpt = [(self.authorsController.arrangedObjects)[0] key];
    }
    if (urlpt) {
        [interface publicationsForAuthor:urlpt];
    }
}

- (IBAction)executeCitation:(id)sender {
    if (![self.handler respondsToSelector:@selector(executeCitation:forBibFile:)]) {
        return;
    }
    NSArray *selection = self.publicationsController.selectedObjects;
    if (selection.count > 0) {
        NSInteger index = self.bibFileSelector.indexOfSelectedItem;
        NSString *path = nil;
        if (index >= 0 && index < self.bibFilePaths.count) {
            path = (self.bibFilePaths)[index];
        }
        [self.handler executeCitation:selection[0] forBibFile:path];
    }
}

- (void)abortDBLPSearch {
    if ([self.handler respondsToSelector:@selector(dblpSearchAborted)]) {
        [self.handler dblpSearchAborted];
    }
}

- (void)finishedFetchingKeys:(NSMutableArray *)authors {
    [self.publicationsController setContent:authors];
}

- (void)failedFetchingKeys:(NSError *)error {
    if ([self.handler respondsToSelector:@selector(failedFetchingKeys:)]) {
        [self.handler failedFetchingKeys:error];
    }
}

- (void)startedFetchingKeys:(NSString *)urlpt {
    
}

@end
