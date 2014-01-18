//
//  GraphNode.m
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "GraphNode.h"

@implementation GraphNode

-(id)init {
    self = [super init];
    if (self) {
        self.predecessors = [NSMutableSet new];
        self.successors = [NSMutableSet new];
    }
    return self;
}

@end
