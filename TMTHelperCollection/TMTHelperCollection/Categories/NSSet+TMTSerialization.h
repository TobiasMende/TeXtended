//
//  NSSet+TMTSerialization.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 01.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet(TMTSerialization)
- (NSString *)stringSerialization;
+ (NSSet *)setFromStringSerialization:(NSString *)string withObjectDeserializer:(id (^)(NSString *)) deserializer;
@end
