//
//  DirectoryFilePresenter.h
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilePresenterObserver.h"

@interface DirectoryFilePresenter : NSObject<NSFilePresenter> {
    NSMutableSet *observers;
}


@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;

- (void) addObserver:(id<FilePresenterObserver>) observer;
- (void) removeObserver:(id<FilePresenterObserver>) observer;
- (id) initWithPath:(NSString *)path;
@end
