//
//  AppDelegate.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
#import "DBLPInterface.h"
#import "BibtexWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    dblp = [[DBLPInterface alloc] initWithHandler:self];
}

- (void)finishedFetcheingAuthors:(NSMutableDictionary *)authors {
    self.searchinAuthor = NO;
    [self.authorsController setContent:authors];
}

- (void)startedFetcheingAuthors:(NSString *)authorName {
    self.searchinAuthor = YES;
}

- (void)failedFetchingAuthors {
    self.searchinAuthor = NO;
    NSLog(@"Failed to fetch");
}


- (void)controlTextDidChange:(NSNotification *)obj {
    if (self.authorField.stringValue.length >= 2) {
        [self.publicationsController setContent:nil];
        [dblp searchAuthor:self.authorField.stringValue];
    }
}
- (IBAction)clickedAuthorTable:(id)sender {
    NSUInteger row = [self.authorTable selectedRow];
    if (row < [self.authorsController.arrangedObjects count]) {
        NSString *name = [[self.authorsController.arrangedObjects objectAtIndex:row] value];
        NSString *urlpt = [[self.authorsController.arrangedObjects objectAtIndex:row] key];
        self.resultLabel.stringValue = [@"Results for " stringByAppendingFormat:@"%@:", name];
        [dblp publicationsForAuthor:urlpt];
    }
}

- (IBAction)clickedPublicationTable:(id)sender {
    NSUInteger index = [self.publicationTable selectedRow];
    if (index < [self.publicationsController.arrangedObjects count]) {
        DBLPPublication *pub = [self.publicationsController.arrangedObjects objectAtIndex:index];
        if (!bc) {
            bc = [[BibtexWindowController alloc] initWithPublication:pub];
        }
        [bc showPublication:pub];
    }
}


- (void)finishedFetchingKeys:(NSMutableArray *)authors {
    [self.publicationsController setContent:authors];
}

- (void)failedFetchingKeys {
    
}

- (void)startedFetchingKeys:(NSString *)urlpt {
    
}
@end
