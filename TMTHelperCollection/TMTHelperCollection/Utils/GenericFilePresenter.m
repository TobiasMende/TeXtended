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
    - (id)initWithOperationQueue:(NSOperationQueue *)queue;
    {
        self = [super init];
        if (self) {
            lock = [NSObject new];
            _presentedItemOperationQueue = queue;
            [NSFileCoordinator addFilePresenter:self];
        }
        return self;
    }

    - (void)setPath:(NSString *)path
    {
        [NSFileCoordinator removeFilePresenter:self];
        _presentedItemURL = [NSURL fileURLWithPath:path];
        [NSFileCoordinator addFilePresenter:self];
    }


    - (void)terminate
    {
        [NSFileCoordinator removeFilePresenter:self];
    }

# pragma mark - Observer Methods

    - (void)presentedItemDidChange
    {
        @synchronized (lock) {
            if ([self.observer respondsToSelector:@selector(presentedItemDidChange)]) {
                [self.observer presentedItemDidChange];
            }
        }
    }

    - (void)presentedItemDidMoveToURL:(NSURL *)newURL
    {
        @synchronized (lock) {
            if ([self.observer respondsToSelector:@selector(presentedItemDidMoveToURL:)]) {
                [self.observer presentedItemDidMoveToURL:newURL];
            }
        }
    }

@end
