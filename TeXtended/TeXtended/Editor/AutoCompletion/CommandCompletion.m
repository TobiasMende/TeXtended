//
//  CommandCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CommandCompletion.h"

@implementation CommandCompletion

- (void)setInsertion:(NSString *)insertion {
    if (![[insertion substringToIndex:1] isEqualToString:@"\\"]) {
        [super setInsertion:[@"\\" stringByAppendingString:insertion]];
    }else {
        [super setInsertion:insertion];
    }
}
@end
