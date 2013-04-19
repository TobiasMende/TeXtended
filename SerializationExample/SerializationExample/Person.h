//
//  Person.h
//  SerializationExample
//
//  Created by Tobias Mende on 19.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>
@property (strong) NSString* name;
@property BOOL isMale;
@end
