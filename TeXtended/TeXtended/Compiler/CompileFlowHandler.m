//
//  CompileFlowHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompileFlowHandler.h"
static CompileFlowHandler* instance;
@implementation CompileFlowHandler

- (id)init {
    if (!instance) {
        self = [super init];
        return self;
    }
    return instance;
}

+ (CompileFlowHandler *)sharedInstance {
    if(!instance) {
        instance = [[CompileFlowHandler alloc] init];
    }
    return instance;
}
@end
