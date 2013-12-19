//
//  GenericFilePresenter.h
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileObserver.h"

@interface GenericFilePresenter : NSObject<NSFilePresenter>

- (void)setPath:(NSString*)path;
- (id)initWithOperationQueue:(NSOperationQueue *)queue;
- (void)terminate;

@property (readonly) NSURL *presentedItemURL;

@property (readonly) NSOperationQueue *presentedItemOperationQueue;
@property (weak) id<FileObserver> observer;
@end
