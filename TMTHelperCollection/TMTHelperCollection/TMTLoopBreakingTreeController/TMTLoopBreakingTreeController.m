//
//  TMTLoopBreakingTreeController.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTLoopBreakingTreeController.h"
#import "TMTLog.h"

@interface TMTLoopBreakingTreeController ()
- (BOOL)breakLoopsInContent:(id)content withPath:(NSMutableArray *)path;
- (void)finallySetContent:(id)content;
@end

@implementation TMTLoopBreakingTreeController


- (void)setContent:(id)content {
    NSMutableArray *path = [NSMutableArray new];
    if(![self breakLoopsInContent:content withPath:path]) {
        [self performSelectorOnMainThread:@selector(finallySetContent:) withObject:content waitUntilDone:YES];
    } else {
        DDLogError(@"Loop Detected. Can't set content");
    }
}

- (void)finallySetContent:(id)content {
    [super setContent:content];
}



- (BOOL)breakLoopsInContent:(id)content withPath:(NSMutableArray *)path {
    for(id obj in content) {
        if ([path containsObject:obj]) {
            return YES;
        }
        NSArray *childs = [obj valueForKeyPath:self.childrenKeyPath];
        if (childs) {
            [path addObject:obj];
            if([self breakLoopsInContent:childs withPath:path]) {
                return YES;
            }
        }
    }
    return NO;
}
@end
