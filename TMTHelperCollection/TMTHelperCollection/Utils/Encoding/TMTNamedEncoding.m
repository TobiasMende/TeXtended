//
//  TMTNamedEncoding.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTNamedEncoding.h"

@implementation TMTNamedEncoding

    - (id)initWithEncoding:(NSNumber *)number
    {
        self = [super init];
        if (self) {
            self.encoding = number;
        }
        return self;
    }

    - (NSString *)description
    {
        return [NSString localizedNameOfStringEncoding:[self.encoding unsignedIntegerValue]];
    }
@end
