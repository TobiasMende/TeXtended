//
//  ShareDialogController.h
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShareDialogController : NSWindowController

@property (assign) IBOutlet NSTableView* table;
@property (nonatomic) NSArray* content;
@property (readonly) NSArray* fileNames;
@property (nonatomic,readonly) NSArray* choice;
@property IBOutlet NSButton* okButton;

@end
