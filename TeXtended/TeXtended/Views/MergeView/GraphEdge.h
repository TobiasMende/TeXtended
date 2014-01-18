//
//  GraphEdge.h
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GraphNode;

@interface GraphEdge : NSObject

@property GraphNode* head;
@property GraphNode* tail;

-(id)initWithHead:(GraphNode*)head andTail:(GraphNode*)tail;

@end
