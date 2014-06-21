//
//  GenericFilePresenter.h
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileObserver.h"

@interface GenericFilePresenter : NSObject <NSFilePresenter>
    {
        NSObject *lock;
    }

    - (void)setPath:(NSString *)path;

    - (void)terminate;

    - (id)initWithOperationQueue:(NSOperationQueue *)queue;

    @property (readonly) NSURL *presentedItemURL;

    @property (readonly) NSOperationQueue *presentedItemOperationQueue;

    @property (assign) id <FileObserver> observer;
@end
