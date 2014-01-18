//
//  GraphController.h
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphController : NSObject{
    NSMutableDictionary* nodes;
    NSMutableArray* edges;
}

-(void)addNodeForNodeKey:(NSString*)nodeKey;
-(void)addEdgeForHead:(NSString*)head toTail:(NSString*)tail;
-(BOOL)hasCycleFromNode:(NSString*)nodeKey;
@end
