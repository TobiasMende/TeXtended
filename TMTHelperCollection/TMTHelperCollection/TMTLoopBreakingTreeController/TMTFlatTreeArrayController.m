//
//  TMTFlatTreeArrayController.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTFlatTreeArrayController.h"

@interface TMTFlatTreeArrayController ()
- (NSMutableArray *)flatten:(NSArray *)currentLevel;
@end

@implementation TMTFlatTreeArrayController

- (id)arrangedObjects {
    NSArray *rootElements = [[self.treeController arrangedObjects] childNodes];
    NSMutableArray *objects = [self flatten:rootElements];
    return objects;
}

- (NSMutableArray *)flatten:(NSArray *)currentLevel {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:currentLevel.count];
    for(id obj in currentLevel) {
        [result addObject:[obj representedObject]];
        if ([obj childNodes] && [obj childNodes].count > 0) {
            [result addObjectsFromArray:[self flatten:[obj childNodes]]];
        }
    }
    return result;
}

+(NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"arrangedObjects"]) {
        keys = [keys setByAddingObject:@"self.treeController.arrangedObjects"];
    }
    return keys;
}
@end
