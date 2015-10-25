//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConsoleData;


@interface CompilerArgumentBuilder : NSObject

- (id)initWithData:(ConsoleData *)data;

- (NSArray *)build;
@end