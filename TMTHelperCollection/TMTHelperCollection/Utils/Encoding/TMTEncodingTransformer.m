//
//  TMTEncodingTransformer.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTEncodingTransformer.h"
#import "TMTNamedEncoding.h"

@implementation TMTEncodingTransformer

    + (Class)transformedValueClass
    {
        return [TMTNamedEncoding class];
    }

    + (BOOL)allowsReverseTransformation
    {
        return YES;
    }


    - (id)transformedArrayValue:(NSArray *)array
    {
        NSMutableArray *result = [NSMutableArray array];
        for (id value in array) {
            [result addObject:[self transformedValue:value]];
        }
        return result;
    }


    - (id)transformedValue:(id)value
    {
        if ([value isKindOfClass:[NSArray class]]) {
            return [self transformedArrayValue:value];
        }
        if ([value isKindOfClass:[TMTNamedEncoding class]]) {
            return value;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            return [[TMTNamedEncoding alloc] initWithEncoding:value];
        }
        return nil;
    }

    - (id)reverseTransformedValue:(id)value
    {
        return [value encoding];
    }
@end
