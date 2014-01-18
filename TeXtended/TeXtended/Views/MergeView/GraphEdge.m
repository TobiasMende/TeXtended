//
//  GraphEdge.m
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "GraphEdge.h"

@implementation GraphEdge

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(id)initWithHead:(GraphNode*)head andTail:(GraphNode*)tail {
    self = [super init];
    if (self) {
        self.head = head;
        self.tail = tail;
    }
    return self;
}

@end
