//
//  StatsPanelController.h
//  TeXtended
//
//  Created by Tobias Hecht on 05.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatsPanelController : NSWindowController

@property IBOutlet NSString* panelTitle;
@property IBOutlet NSString* wordsInText;
@property IBOutlet NSString* wordsInHeader;
@property IBOutlet NSString* wordsInCaption;
- (void)showStatistics:(NSString*)filename;

@end
