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
    NSLog(@"Failed to fetch: %@", error.userInfo);
}


- (void)controlTextDidChange:(NSNotification *)obj {
    if (self.authorField.stringValue.length >= 2) {
        [self.publicationsController setContent:nil];
        [interface searchAuthor:self.authorField.stringValue];
        
    }
}

- (IBAction)clickedAuthorTable:(id)sender {
    NSUInteger row = [self.authorTable selectedRow];
    if (row < [self.authorsController.arrangedObjects count]) {
        NSString *urlpt = [[self.authorsController.arrangedObjects objectAtIndex:row] key];
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
            path = [self.bibFilePaths objectAtIndex:index];
        }
        [self.handler executeCitation:[selection objectAtIndex:0] forBibFile:path];
    }
}

- (void)abortDBLPSearch {
    if ([self.handler respondsToSelector:@selector(dblpSearchAborted)]) {
        [self.handler dblpSearchAborted];
    }
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification.object isEqualTo:self.publicationTable]) {
        NSUInteger index = [self.publicationTable selectedRow];
        if (index < [self.publicationsController.arrangedObjects count]) {
            TMTBibTexEntry *pub = [self.publicationsController.arrangedObjects objectAtIndex:index];
            if (pub.dictionary) {
                
            }
        }
    } else if([notification.object isEqualTo:self.authorTable]) {
        [self clickedAuthorTable:self];
    }
}


- (void)finishedFetchingKeys:(NSMutableArray *)authors {
    [self.publicationsController setContent:authors];
}

- (void)failedFetchingKeys:(NSError *)error {
    NSLog(@"Failed to fetch keys: %@", error.userInfo);
}

- (void)startedFetchingKeys:(NSString *)urlpt {
    
}

@end
