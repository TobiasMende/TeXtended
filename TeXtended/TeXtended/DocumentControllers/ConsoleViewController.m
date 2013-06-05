//
//  ConsoleViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 05.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleViewController.h"
#import "DocumentModel.h"

@interface ConsoleViewController ()

@end

@implementation ConsoleViewController


- (id) initWithParent:(id<DocumentControllerProtocol>) parent {
    self = [super initWithNibName:@"ConsoleView" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (NSSet *) children {
    return [NSSet setWithObjects: nil];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    
}

- (void) documentHasChangedAction {
    
}

- (void) breakUndoCoalescing {
    
}

@end
