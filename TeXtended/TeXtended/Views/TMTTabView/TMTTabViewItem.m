//
//  DemoFakeModel.m
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewItem.h"

@implementation TMTTabViewItem


    - (id)init
    {
        if (self = [super init]) {
            self.hasCloseButton = YES;
        }
        return self;
    }


@end