//
//  NSRegularExpression+LatexExtensions.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 03.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSRegularExpression+LatexExtensions.h"

static NSRegularExpression *COMMAND_REGEX;

@implementation NSRegularExpression (LatexExtensions)


__attribute__((constructor))
static void initialize_NSRegularExpression_LatexExtensions()
{
    COMMAND_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\\\[a-zA-Z0-9@_]+|\\\\\\\\" options:0 error:NULL];
}




+ (NSRegularExpression *)commandExpression
{
    return COMMAND_REGEX;
}


@end
