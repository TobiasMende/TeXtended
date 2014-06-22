//
//  TMTTreeController.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 22.06.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMTTreeController : NSTreeController {
    NSMutableArray *searchResults;
}
- (void) filterContentBy:(NSPredicate *)predicate;
@end
