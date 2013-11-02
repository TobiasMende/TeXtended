//
//  TMTTabViewWindowManager.m
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewWindowManager.h"
static TMTTabViewWindowManager* tabViewWindowManager = nil;
@implementation TMTTabViewWindowManager

- (id)init {
    self = [super init];
    windowSet = [NSMutableSet new];
    
    return self;
}

+ (TMTTabViewWindowManager *)sharedTabViewWindowManager {
    if(!tabViewWindowManager) {
        tabViewWindowManager = [TMTTabViewWindowManager new];
    }
    return tabViewWindowManager;
}


- (void)addTabViewWindow:(TMTTabViewWindow *)window {
    [windowSet addObject:window];
}

- (void)removeTabViewWindow:(TMTTabViewWindow *)window {
    [windowSet removeObject:window];
}


@end
