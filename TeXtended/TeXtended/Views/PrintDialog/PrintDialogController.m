//
//  PrintDialogController.m
//  TeXtended
//
//  Created by Tobias Hecht on 04.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "PrintDialogController.h"

@interface PrintDialogController ()

@end

@implementation PrintDialogController

-(id)init
{
    self = [super initWithWindowNibName:@"PrintDialog"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.documentType addItemWithTitle:@"PDF"];
    [self.documentType addItemWithTitle:@"TEX"];
}

@end