//
//  OutlineHelper.m
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "OutlineHelper.h"
#import "OutlineElement.h"
#import <TMTHelperCollection/TMTLog.h>
@implementation OutlineHelper



+ (NSMutableArray *)flatten:(NSArray *)currentLevel withPath:(NSMutableSet *)path{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:currentLevel.count];
    for(OutlineElement *obj in currentLevel) {
        [result addObject:obj];
        if ([obj children] && [obj children].count > 0) {
            if (![path containsObject:obj]) {
                [path addObject:obj];
                [result addObjectsFromArray:[self flatten:[obj children] withPath:path]];
                [path removeObject:obj];
            }else {
                DDLogError(@"Tree contains loop. Breaking loop");
            }
        }
    }
    return result;
}
@end
