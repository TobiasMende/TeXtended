//
//  GraphController.m
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "GraphController.h"
#import "GraphNode.h"
#import "GraphEdge.h"

@implementation GraphController

    - (id)init
    {
        self = [super init];
        if (self) {
            nodes = [NSMutableDictionary new];
            edges = [NSMutableArray new];
        }
        return self;
    }

    - (void)addNodeForNodeKey:(NSString *)nodeKey
    {
        GraphNode *node = [nodes objectForKey:nodeKey];

        if (!node) {
            node = [GraphNode new];
            [nodes setObject:node forKey:nodeKey];
        }
    }

    - (void)addEdgeForHead:(NSString *)head toTail:(NSString *)tail
    {
        GraphNode *headNode = [nodes objectForKey:head];
        GraphNode *tailNode = [nodes objectForKey:tail];

        if (!headNode) {
            return;
        }

        if (!tailNode) {
            return;
        }

        GraphEdge *edge = [[GraphEdge alloc] initWithHead:headNode andTail:tailNode];
        [edges addObject:edge];
        [headNode.successors addObject:tailNode];
        [tailNode.predecessors addObject:headNode];
    }

    - (BOOL)hasCycleFromNode:(NSString *)nodeKey
    {
        GraphNode *node = [nodes objectForKey:nodeKey];

        if (!node) {
            return NO;
        }

        NSMutableSet *visited = [NSMutableSet setWithObject:node];
        NSMutableSet *visit = [NSMutableSet setWithSet:node.successors];

        while ([visit count]) {
            GraphNode *temp = [visit anyObject];
            if ([visited containsObject:temp]) {
                return YES;
            }
            else {
                [visit removeObject:temp];
                [visited addObject:temp];
                [visit unionSet:temp.successors];
            }
        }

        return NO;
    }

    - (void)reset
    {
        [nodes removeAllObjects];
        [edges removeAllObjects];
    }

@end
