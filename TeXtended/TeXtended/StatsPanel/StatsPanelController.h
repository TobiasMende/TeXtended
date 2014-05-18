//
//  StatsPanelController.h
//  TeXtended
//
//  Created by Tobias Hecht on 05.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatsPanelController : NSWindowController

    @property IBOutlet NSString *panelTitle;

    @property IBOutlet NSString *words;

    @property IBOutlet NSString *sentences;

    @property IBOutlet NSString *letters;

    @property IBOutlet NSString *symbols;

    @property IBOutlet NSString *wordsPerSentence;

    @property IBOutlet NSString *symbolsPerSentence;

    @property IBOutlet NSString *lettersPerSentence;

    - (void)showStatistics:(NSString *)content;

@end
