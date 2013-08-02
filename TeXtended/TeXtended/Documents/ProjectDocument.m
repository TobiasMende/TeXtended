//
//  ProjectDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectDocument.h"
#import "MainWindowController.h"
#import "DocumentController.h"
#import "ProjectModel.h"

@implementation ProjectDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)makeWindowControllers {
    _mainWindowController = [[MainWindowController alloc] init];
    
    [self addWindowController:self.mainWindowController];
    
    for (DocumentController* dc in self.documentControllers) {
        if ([[[self.projectModel.documents allObjects] objectAtIndex:0] isEqual:dc.model]) {
            [dc setWindowController:self.mainWindowController];
        }
    }
}

- (BOOL)save:(NSError **)error {

    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ProjectDocument dealloc");
#endif
}

@end
