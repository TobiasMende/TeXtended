//
//  NewTemplateController.m
//  TeXtended
//
//  Created by Max Bannach on 16.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NewTemplateController.h"
#import "TemplateController.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation NewTemplateController

- (id) initWithTemplateController:(TemplateController*) tempalteController {
    DDLogVerbose(@"initWithTemplateController");
    self.tempalteController = tempalteController;
    return self;
}

- (void)openSheetIn:(NSWindow*)window {
    if (!_sheet) {
        [NSBundle loadNibNamed:@"NewTemplateSheet" owner:self];
    }
    
    [NSApp beginSheet:self.sheet
        modalForWindow:window
        modalDelegate:self
        didEndSelector:nil
        contextInfo:nil
     ];
}

- (void) closeSheet:(id)sender {
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

- (IBAction)addTemplate:(id)sender {
    NSString* templateName = [self.templateName stringValue];
    if ([templateName length] == 0) return;
    [self.tempalteController addTemplateWithName:templateName andContent:[self.createWithContent state]];
    [self closeSheet:nil];
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
}

@end
