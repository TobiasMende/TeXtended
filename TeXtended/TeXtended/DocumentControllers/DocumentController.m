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
    return nil;
}

- (void) documentHasChangedAction {
    
}

@end
