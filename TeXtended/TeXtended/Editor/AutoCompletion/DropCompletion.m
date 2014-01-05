//
//  DropCompletion.m
//  TeXtended
//
//  Created by Tobias Hecht on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "DropCompletion.h"

@implementation DropCompletion

-(id)init {
    return [self initWithInsertion:@"ext" containingPlaceholders:YES andExtension:@"@@destination@@"];
}

-(NSAttributedString*)getCompletion:(NSString*)path {
    NSString* retValue = [self.extension stringByReplacingOccurrencesOfString:@"@@destination@@" withString:path];
    return [self substitutePlaceholdersInString:retValue];
}

@end
