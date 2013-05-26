//
//  DocumentController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentController.h"

@implementation DocumentController


- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document {
    //TODO: implement
    return nil;
}

- (id) initWithParent:(id<DocumentControllerProtocol>) parent {
    return nil;
}

- (id <DocumentControllerProtocol>) parent {
    return nil;
}

- (DocumentController * ) documentController {
    return self;
}

- (NSSet<DocumentControllerProtocol> *) children {
    NSSet<DocumentControllerProtocol> *children = [NSSet setWithObjects:
                       [self textViewController],
                       [self pdfViewsController],
                       [self consolViewsController],
                       [self outlineViewController], nil];
    return children;
}

- (void) documentHasChangedAction {
    //TODO: call on children
}

- (bool) saveDocument:(NSError *__autoreleasing *)outError {
    return nil;
}

- (void)breakUndoCoalescing {
    [self.textViewController breakUndoCoalescing];
}

@end
