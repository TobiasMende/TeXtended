//
//  Compiler.m
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compiler.h"

@implementation Compiler

- (id) initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    if (self) {
        [self setAutoCompile:NO];
        documentController = controller;
    }
    return self;
}


- (void) compile:(bool)draft {
    //TODO: compile here
    [documentController documentHasChangedAction];
}

@end
