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
#import "DBLPPublication.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    dblp = [[DBLPInterface alloc] initWithHandler:self];
}

- (void)finishedFetchingAuthors:(NSMutableDictionary *)authors {
    self.searchinAuthor = NO;
    [self.authorsController setContent:authors];
    [self clickedAuthorTable:self];
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
        [dblp searchAuthor:self.authorField.stringValue];
        
    }
}
- (IBAction)clickedAuthorTable:(id)sender {
    NSUInteger row = [self.authorTable selectedRow];
    if (row < [self.authorsController.arrangedObjects count]) {
        NSString *urlpt = [[self.authorsController.arrangedObjects objectAtIndex:row] key];
        [dblp publicationsForAuthor:urlpt];
    }
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification.object isEqualTo:self.publicationTable]) {
        NSUInteger index = [self.publicationTable selectedRow];
        if (index < [self.publicationsController.arrangedObjects count]) {
            DBLPPublication *pub = [self.publicationsController.arrangedObjects objectAtIndex:index];
            if (pub.dictionary) {
                if (!bc) {
                    bc = [[BibtexWindowController alloc] initWithPublication:pub];
                }
                [bc showPublication:pub];
                [self.window makeKeyWindow];
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
