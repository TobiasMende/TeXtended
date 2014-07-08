//
//  TMTTreeController.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 22.06.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTTreeController.h"

@implementation TMTTreeController

- (void)filterContentBy:(NSPredicate *)predicate {
    searchResults = [NSMutableArray new];
    [self search:predicate inSection:[self.arrangedObjects childNodes]];
    if (searchResults.count > 0) {
        self.selectionIndexPaths = searchResults.copy;
    } else {
        self.selectionIndexPaths = @[];
    }
}

- (void) search:(NSPredicate *)predicate inSection:(NSArray *)selection
{
    //iterate through the roots
    for (NSTreeNode* item in selection)
    {
        //fetch children
        NSArray* children = [item childNodes];
        if ([children count] > 0)
        {
            //get a level deeper if you have children
            [self search:predicate inSection:children];
        }
    
        
        //add to record if matched
        if ([predicate evaluateWithObject:item.representedObject])
        {
            [searchResults addObject:[item indexPath]];
        }
    }
    
}

@end
