//
//  CompletionWhiteSpaceValueTransformer.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "CompletionWhiteSpaceValueTransformer.h"

@implementation CompletionWhiteSpaceValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return value;
    }
    NSString *string = (NSString *)value;
   return [[string stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
}

- (id)reverseTransformedValue:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return value;
    }
    NSString *string = (NSString *)value;
    NSString *result = [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    return result;
}


@end
