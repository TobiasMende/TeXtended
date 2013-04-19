//
//  Person.m
//  SerializationExample
//
//  Created by Tobias Mende on 19.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _isMale = [[aDecoder decodeObjectForKey:@"male"] boolValue];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isMale] forKey:@"male"];
}


@end
