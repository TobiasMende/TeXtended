//
//  DirectoryFilePresenter.m
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DirectoryFilePresenter.h"

@implementation DirectoryFilePresenter

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _presentedItemURL = [NSURL URLWithString:path];
    }
return self;
}

- (void)addObserver:(id<FilePresenterObserver>)observer {
    [observers addObject:observer];
}

- (void)removeObserver:(id<FilePresenterObserver>)observer {
    [observers removeObject:observer];
}

@end
