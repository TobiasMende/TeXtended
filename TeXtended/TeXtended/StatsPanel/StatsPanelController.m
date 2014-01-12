//
//  StatsPanelController.m
//  TeXtended
//
//  Created by Tobias Hecht on 05.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "StatsPanelController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "Constants.h"
#import "NSString+RNTextStatistics.h"

@interface StatsPanelController ()

@end

@implementation StatsPanelController

- (id)init {
    self = [super initWithWindowNibName:@"StatsPanel"];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)showStatistics:(NSString*)content
{
    NSInteger words = [content wordCount];
    NSInteger sentences = [content sentenceCount];
    NSInteger letters = [content letterCount];
    NSInteger symbols = [content length];
    self.words = [NSString stringWithFormat:@"%ld",(long)words];
    self.sentences = [NSString stringWithFormat:@"%ld",(long)sentences];
    self.letters = [NSString stringWithFormat:@"%ld",(long)letters];
    self.symbols = [NSString stringWithFormat:@"%ld",(long)symbols];
    self.wordsPerSentence = [NSString stringWithFormat:@"%f",(float)words/(float)sentences];
    self.lettersPerSentence = [NSString stringWithFormat:@"%f",(float)letters/(float)sentences];
    self.symbolsPerSentence = [NSString stringWithFormat:@"%f",(float)symbols/(float)sentences];
}

- (IBAction)OKSheet:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet: self.window];
    [self.window orderOut: self];
}


@end
