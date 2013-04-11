//
//  Stack.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Stack.h"

@implementation Stack 

- (id)init {
    self = [super init];
    if (self) {
        container = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(id)obj {
    [container insertObject:obj atIndex:container.count];
}

- (id)pop {
    NSUInteger idx = container.count-1;
    id obj = [container objectAtIndex:idx];
    [container removeObjectAtIndex:idx];
    return obj;
}

- (BOOL)isEmpty {
    return [container count] == 0;
}

- (id)last {
    NSUInteger idx = container.count-1;
    id obj = [container objectAtIndex:idx];
    return obj;
}
@end
