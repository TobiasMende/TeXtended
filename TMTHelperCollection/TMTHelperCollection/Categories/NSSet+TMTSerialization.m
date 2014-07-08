//
//  NSSet+TMTSerialization.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 01.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSSet+TMTSerialization.h"

@implementation NSSet(TMTSerialization)
- (NSString *)stringSerialization {
    if (self.count == 0) {
        return @"";
    }
    NSMutableString *serialization = [NSMutableString new];
    [serialization appendFormat:@"{"];
    for(id obj in self) {
        [serialization appendFormat:@"%@, ", obj];
    }
    [serialization deleteCharactersInRange:NSMakeRange(serialization.length-2, 2)];
    [serialization appendFormat:@"}"];
    
    return serialization;
}

+ (NSSet *)setFromStringSerialization:(NSString *)string withObjectDeserializer:(id (^)(NSString *))deserializer {
    NSMutableSet *set = [NSMutableSet new];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanString:@"{" intoString:NULL];
    while (true) {
        NSString *objString;
        if (![scanner scanUpToString:@", " intoString:&objString]) {
            [scanner scanUpToString:@"}" intoString:&objString];
        }
        id obj = deserializer(objString);
        [set addObject:obj];
        if (![scanner scanString:@", " intoString:nil]) {
            break;
        }
    }
    return set;
}
@end
