//
//  Compiler.m
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compiler.h"
#import "DocumentModel.h"

@implementation Compiler

- (id)initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    if (self) {
        [self setAutoCompile:NO];
        documentController = controller;
        
        // get the settings and observe them
        _draftSettings = [[controller model] draftCompiler];
        _liveSettings = [[controller model] liveCompiler];
        _finalSettings = [[controller model] finalCompiler];
        
        [[[controller model] draftCompiler] addObserver:self forKeyPath:@"draftSetting" options:0 context:NULL];
        [[[controller model] liveCompiler] addObserver:self forKeyPath:@"liveSetting" options:0 context:NULL];
        [[[controller model] finalCompiler] addObserver:self forKeyPath:@"finalSetting" options:0 context:NULL];
    }
    return self;
}


- (void) compile:(bool)draft {
    // todo compiler
    NSLog(@"Compile: %@", [NSNumber numberWithBool:draft]);
    [documentController documentHasChangedAction];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void*)context {
    
}

@end
