//
//  GraphNode.h
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphNode : NSObject

    @property NSMutableSet *predecessors;

    @property NSMutableSet *successors;

@end
