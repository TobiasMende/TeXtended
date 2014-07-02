//
//  StartScreenWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 01.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StartScreenWindowController : NSWindowController


#pragma mark - Outlets

@property (strong) IBOutlet NSButton *recentDocumentsButton;
@property (strong) IBOutlet NSButton *recentProjectsButton;


#pragma mark - Actions
- (IBAction)openNewDocument:(id)sender;
- (IBAction)openNewProject:(id)sender;
- (IBAction)openTemplate:(id)sender;
- (IBAction)showRecentDocuments:(id)sender;
- (IBAction)showRecentProjects:(id)sender;
- (IBAction)openExistingDocumentOrProject:(id)sender;


#pragma mark - Methods
- (void) close;
- (NSArray *)recentProjects;
- (NSArray *)recentDocuments;
- (void)openRecent:(id)sender;
@end
