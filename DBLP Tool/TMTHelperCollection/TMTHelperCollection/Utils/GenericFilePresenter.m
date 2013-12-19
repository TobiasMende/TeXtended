//
//  GenericFilePresenter.m
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "GenericFilePresenter.h"

@implementation GenericFilePresenter

# pragma mark - Live Cycle Handling
- (id)initWithOperationQueue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _presentedItemOperationQueue = queue;
        [NSFileCoordinator addFilePresenter:self];
    }
    return self;
}

- (void)setPath:(NSString *)path {
    _presentedItemURL = [NSURL fileURLWithPath:path];
}


- (void)terminate {
    [NSFileCoordinator removeFilePresenter:self];
}

# pragma mark - Observer Methods

- (void)presentedItemDidChange {
    if ([self.observer respondsToSelector:@selector(presentedItemDidChange)]) {
        [self.observer presentedItemDidChange];
    }
}

- (void)presentedItemDidMoveToURL:(NSURL *)newURL {
    if ([self.observer respondsToSelector:@selector(presentedItemDidMoveToURL:)]) {
        [self.observer presentedItemDidMoveToURL:newURL];
    }
}

@end
